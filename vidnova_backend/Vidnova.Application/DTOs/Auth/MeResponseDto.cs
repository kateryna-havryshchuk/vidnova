namespace Vidnova.Application.DTOs.Auth;

public sealed record MeResponseDto
{
    public Guid UserId { get; init; }
    public string Email { get; init; } = string.Empty;
    public string UserName { get; init; } = string.Empty;

    public string FirstName { get; init; } = string.Empty;
    public string LastName { get; init; } = string.Empty;

    public bool HasPassword { get; init; }
    public bool IsGoogleAccount { get; init; }
}