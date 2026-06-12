using Vidnova.Application.DTOs.Auth;

namespace Vidnova.Application.Services.Auth;

public interface IMeService
{
    Task<MeResponseDto> GetMeAsync(Guid userId, CancellationToken ct = default);
}