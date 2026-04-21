namespace Vidnova.Application.DTOs.Auth;

public sealed record GoogleIdTokenPayload(
    string Subject,
    string Email,
    bool EmailVerified,
    string? GivenName,
    string? FamilyName
);