using Google.Apis.Auth;
using Microsoft.Extensions.Options;
using Vidnova.Application.Common.Interfaces;
using Vidnova.Application.DTOs.Auth;

namespace Vidnova.Infrastructure.Security;

public sealed class GoogleIdTokenValidator : IGoogleIdTokenValidator
{
    private readonly GoogleAuthOptions _options;

    public GoogleIdTokenValidator(IOptions<GoogleAuthOptions> options)
    {
        _options = options.Value;
    }

    public async Task<GoogleIdTokenPayload> ValidateAsync(string idToken, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(idToken))
            throw new ArgumentException("Google idToken is required.", nameof(idToken));

        var settings = new GoogleJsonWebSignature.ValidationSettings
        {
            Audience = new[] { _options.ClientId }
        };

        
        var payload = await GoogleJsonWebSignature.ValidateAsync(idToken, settings);

        return new GoogleIdTokenPayload(
            Subject: payload.Subject,
            Email: payload.Email,
            EmailVerified: payload.EmailVerified,
            GivenName: payload.GivenName,
            FamilyName: payload.FamilyName
        );
    }
}