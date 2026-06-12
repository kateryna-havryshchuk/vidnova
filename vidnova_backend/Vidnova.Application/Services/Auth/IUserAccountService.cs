using Vidnova.Application.DTOs.Auth;

namespace Vidnova.Application.Services.Auth;

public interface IUserAccountService
{
    Task ChangeEmailAsync(Guid userId, ChangeEmailRequestDto request, CancellationToken ct = default);
    Task ChangePasswordAsync(Guid userId, ChangePasswordRequestDto request, CancellationToken ct = default);
}
