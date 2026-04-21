using Vidnova.Application.DTOs.Auth;

namespace Vidnova.Application.Services.Auth;

public interface IUserCredentialsService
{
    Task SetPasswordAsync(Guid userId, SetPasswordRequestDto request, CancellationToken ct = default);
}
