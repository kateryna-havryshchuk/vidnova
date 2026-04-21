using Vidnova.Application.Common.Interfaces;
using Vidnova.Application.DTOs.Auth;

namespace Vidnova.Application.Services.Auth;

public sealed class UserAccountService : IUserAccountService
{
    private readonly IUnitOfWork _uow;
    private readonly IUserRepository _users;
    private readonly IPasswordHasher _passwordHasher;

    public UserAccountService(IUnitOfWork uow, IUserRepository users, IPasswordHasher passwordHasher)
    {
        _uow = uow;
        _users = users;
        _passwordHasher = passwordHasher;
    }

    public async Task ChangeEmailAsync(Guid userId, ChangeEmailRequestDto request, CancellationToken ct = default)
    {
        if (request is null)
            throw new ArgumentException("Request body is required.");

        var newEmail = Normalize(request.NewEmail);
        if (string.IsNullOrWhiteSpace(newEmail))
            throw new ArgumentException("NewEmail is required.", nameof(request.NewEmail));

        if (string.IsNullOrWhiteSpace(request.CurrentPassword))
            throw new ArgumentException("CurrentPassword is required.", nameof(request.CurrentPassword));

        var user = await _users.GetByIdAsync(userId, ct);
        if (user is null)
            throw new UnauthorizedAccessException("User not found");

        if (!string.IsNullOrWhiteSpace(user.GoogleSubject))
            throw new InvalidOperationException("Email change is not available for Google accounts.");

        if (string.IsNullOrWhiteSpace(user.PasswordHash))
            throw new InvalidOperationException("Password is not set for this account. Use set-password first.");

        if (!_passwordHasher.VerifyHashedPassword(request.CurrentPassword, user.PasswordHash))
            throw new UnauthorizedAccessException("Invalid credentials.");

        if (!string.Equals(user.Email, newEmail, StringComparison.OrdinalIgnoreCase))
        {
            if (await _users.EmailExistsAsync(newEmail, ct))
                throw new InvalidOperationException("Email already registered");

            user.Email = newEmail;
            user.EmailVerified = false;
        }

        await _uow.SaveChangesAsync(ct);
    }

    public async Task ChangePasswordAsync(Guid userId, ChangePasswordRequestDto request, CancellationToken ct = default)
    {
        if (request is null)
            throw new ArgumentException("Request body is required.");

        if (string.IsNullOrWhiteSpace(request.CurrentPassword))
            throw new ArgumentException("CurrentPassword is required.", nameof(request.CurrentPassword));

        if (string.IsNullOrWhiteSpace(request.NewPassword) || request.NewPassword.Length < 8)
            throw new ArgumentException("Password must be at least 8 characters.", nameof(request.NewPassword));

        var user = await _users.GetByIdAsync(userId, ct);
        if (user is null)
            throw new UnauthorizedAccessException("User not found");

        if (string.IsNullOrWhiteSpace(user.PasswordHash))
            throw new InvalidOperationException("Password is not set for this account. Use set-password first.");

        if (!_passwordHasher.VerifyHashedPassword(request.CurrentPassword, user.PasswordHash))
            throw new UnauthorizedAccessException("Invalid credentials.");

        user.PasswordHash = _passwordHasher.HashPassword(request.NewPassword);
        await _uow.SaveChangesAsync(ct);
    }

    private static string Normalize(string value) => (value ?? string.Empty).Trim().ToLowerInvariant();
}
