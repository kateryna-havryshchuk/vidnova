using Vidnova.Application.Common.Interfaces;
using Vidnova.Application.DTOs.Auth;

namespace Vidnova.Application.Services.Auth;

public sealed class UserCredentialsService : IUserCredentialsService
{
    private readonly IUnitOfWork _uow;
    private readonly IUserRepository _userRepository;
    private readonly IPasswordHasher _passwordHasher;

    public UserCredentialsService(
        IUnitOfWork uow,
        IUserRepository userRepository,
        IPasswordHasher passwordHasher)
    {
        _uow = uow;
        _userRepository = userRepository;
        _passwordHasher = passwordHasher;
    }

    public async Task SetPasswordAsync(Guid userId, SetPasswordRequestDto request, CancellationToken ct = default)
    {
        if (request is null)
            throw new ArgumentException("Request body is required.");

        if (string.IsNullOrWhiteSpace(request.NewPassword) || request.NewPassword.Length < 8)
            throw new ArgumentException("Password must be at least 8 characters.", nameof(request.NewPassword));

        if (request.NewPassword != request.ConfirmPassword)
            throw new ArgumentException("Passwords do not match.", nameof(request.ConfirmPassword));

        var user = await _userRepository.GetByIdAsync(userId, ct);
        if (user is null)
            throw new UnauthorizedAccessException("User not found");

        if (!string.IsNullOrWhiteSpace(user.PasswordHash))
            throw new InvalidOperationException("Password is already set.");

        user.PasswordHash = _passwordHasher.HashPassword(request.NewPassword);
        await _uow.SaveChangesAsync(ct);
    }
}
