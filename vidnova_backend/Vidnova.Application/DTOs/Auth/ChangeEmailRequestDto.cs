namespace Vidnova.Application.DTOs.Auth;

public sealed record ChangeEmailRequestDto
{
    public string NewEmail { get; init; } = string.Empty;
    public string CurrentPassword { get; init; } = string.Empty;
}
