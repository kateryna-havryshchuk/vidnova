namespace Vidnova.Application.DTOs.Auth;

public sealed record ChangePasswordRequestDto
{
    public string CurrentPassword { get; init; } = string.Empty;
    public string NewPassword { get; init; } = string.Empty;
}
