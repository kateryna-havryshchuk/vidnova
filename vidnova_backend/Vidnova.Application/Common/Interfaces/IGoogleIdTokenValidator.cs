using Vidnova.Application.DTOs.Auth;

namespace Vidnova.Application.Common.Interfaces;

public interface IGoogleIdTokenValidator
{
    Task<GoogleIdTokenPayload> ValidateAsync(string idToken, CancellationToken ct = default);
}