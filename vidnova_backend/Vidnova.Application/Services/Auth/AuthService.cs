using Microsoft.EntityFrameworkCore;
using Vidnova.Application.Common.Interfaces;
using Vidnova.Application.DTOs.Auth;
using Vidnova.Domain.Entities;

namespace Vidnova.Application.Services.Auth;

public sealed class AuthService: IAuthService
{
    private readonly IUnitOfWork _UofWork;
    private readonly IUserRepository _userRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtTokenGenerator _jwtTokenGenerator;
    private readonly IGoogleIdTokenValidator _googleTokenValidator;

    public AuthService(
        IUnitOfWork uofWork,
        IPasswordHasher passwordHasher,
        IJwtTokenGenerator jwtTokenGenerator,
        IUserRepository userRepository,
        IGoogleIdTokenValidator googleTokenValidator)
    {
        _UofWork = uofWork;
        _passwordHasher = passwordHasher;
        _jwtTokenGenerator = jwtTokenGenerator;
        _userRepository = userRepository;
        _googleTokenValidator = googleTokenValidator;
    }

    public async Task<AuthResponseDto> RegisterAsync(RegisterRequestDto request, CancellationToken ct = default)
    {
        var email = Normalize(request.Email);
        var userName = Normalize(request.Username);

        if (string.IsNullOrWhiteSpace(email)) 
            throw new ArgumentException("Email is required", nameof(request.Email));
        
        if(string.IsNullOrWhiteSpace(userName)) 
            throw new ArgumentException("Username is required", nameof(request.Username));
        
        if(string.IsNullOrWhiteSpace(request.Password) || request.Password.Length < 8) 
            throw new ArgumentException("Password must be at least 8 characters.", nameof(request.Password));

        if (await _userRepository.EmailExistsAsync(email, ct))
            throw new InvalidOperationException("Email already registered");
        
        if (await _userRepository.UsernameExistsAsync(userName, ct))
            throw new InvalidOperationException("Username already registered");
        
        var hash = _passwordHasher.HashPassword(request.Password);

        var user = new User
        {
            Email = email,
            Username = userName,
            FirstName = request.FirstName?.Trim() ?? string.Empty,
            LastName = request.LastName?.Trim() ?? string.Empty,
            PasswordHash = hash
        };
        
        _userRepository.Add(user);

        await _UofWork.SaveChangesAsync(ct);

        var (token, expiresAtUtc) = _jwtTokenGenerator.GenerateAccessToken(user);

        return new AuthResponseDto
        {
            UserId = user.Id,
            Email = user.Email,
            UserName = user.Username,
            AccessToken = token,
            ExpiresAtUtc = expiresAtUtc
        };
    }

    public async Task<AuthResponseDto> LoginAsync(LoginRequestDto request, CancellationToken ct = default)
    {
        var login = Normalize(request.Username);
        if(string.IsNullOrWhiteSpace(login)) throw new ArgumentException("Username is required", nameof(request.Username));

        const string invalidCreds = "Invalid credentials.";
        
        var user = await _userRepository.FindByLoginAsync(login, ct);
        if (user is null) throw new UnauthorizedAccessException(invalidCreds);

        // google-only accounts have no password until they explicitly set one
        if (string.IsNullOrWhiteSpace(user.PasswordHash))
            throw new UnauthorizedAccessException(invalidCreds);
        
        if(!_passwordHasher.VerifyHashedPassword(request.Password, user.PasswordHash))
            throw new UnauthorizedAccessException(invalidCreds);
        
        var (token, expiresAtUtc) = _jwtTokenGenerator.GenerateAccessToken(user);

        return new AuthResponseDto
        {
            UserId = user.Id,
            Email = user.Email,
            UserName = user.Username,
            AccessToken = token,
            ExpiresAtUtc = expiresAtUtc
        };
    }
    
    public async Task<AuthResponseDto> GoogleLoginAsync(GoogleLoginRequestDto request, CancellationToken ct = default)
    {
        if (request is null)
            throw new ArgumentException("Request body is required.");

        if (string.IsNullOrWhiteSpace(request.IdToken))
            throw new ArgumentException("IdToken is required.", nameof(request.IdToken));

        GoogleIdTokenPayload payload;
        try
        {
            payload = await _googleTokenValidator.ValidateAsync(request.IdToken, ct);
        }
        catch (Exception ex)
        {
            throw new UnauthorizedAccessException("Invalid Google token.", ex);
        }

        var email = Normalize(payload.Email);

        if (string.IsNullOrWhiteSpace(email))
            throw new UnauthorizedAccessException("Google account has no email.");

        var user = await _userRepository.FindByGoogleSubjectAsync(payload.Subject, ct);
        
        if (user is null)
        {
            var byEmail = await _userRepository.FindByEmailAsync(email, ct);
            if (byEmail is not null)
            {
                if (!payload.EmailVerified)
                    throw new UnauthorizedAccessException("Google email is not verified.");
                
                byEmail.GoogleSubject = payload.Subject;
                byEmail.EmailVerified = byEmail.EmailVerified || payload.EmailVerified;

                await _UofWork.SaveChangesAsync(ct);
                user = byEmail;
            }
        }

        if (user is null)
        {
            var baseUsername = BuildUsernameFromEmail(email);
            var username = await EnsureUniqueUsernameAsync(baseUsername, ct);

            user = new User
            {
                Email = email,
                Username = username,
                FirstName = payload.GivenName?.Trim() ?? string.Empty,
                LastName = payload.FamilyName?.Trim() ?? string.Empty,

                // google-only account: no password until user sets it explicitly
                PasswordHash = null,

                GoogleSubject = payload.Subject,
                EmailVerified = payload.EmailVerified
            };

            _userRepository.Add(user);
            await _UofWork.SaveChangesAsync(ct);
        }

        var (token, expiresAtUtc) = _jwtTokenGenerator.GenerateAccessToken(user);

        return new AuthResponseDto
        {
            UserId = user.Id,
            Email = user.Email,
            UserName = user.Username,
            AccessToken = token,
            ExpiresAtUtc = expiresAtUtc
        };
    }

    private static string BuildUsernameFromEmail(string email)
    {
        // "name.surname@gmail.com" -> "name.surname"
        var at = email.IndexOf('@');
        var local = at > 0 ? email[..at] : email;

        var cleaned = new string(local.Where(ch =>
            char.IsLetterOrDigit(ch) || ch == '_' || ch == '.'
        ).ToArray());

        cleaned = cleaned.Trim('.', '_');
        return string.IsNullOrWhiteSpace(cleaned) ? "user" : cleaned.ToLowerInvariant();
    }

    private async Task<string> EnsureUniqueUsernameAsync(string baseUsername, CancellationToken ct)
    {
        if (!await _userRepository.UsernameExistsAsync(baseUsername, ct))
            return baseUsername;

        for (var i = 2; i <= 9999; i++)
        {
            var candidate = $"{baseUsername}{i}";
            if (!await _userRepository.UsernameExistsAsync(candidate, ct))
                return candidate;
        }

        return $"{baseUsername}_{Guid.NewGuid():N}".Substring(0, Math.Min(30, baseUsername.Length + 1 + 8));
    }
    
    public static string Normalize(string value) 
        => (value ?? string.Empty).Trim().ToLowerInvariant();
}