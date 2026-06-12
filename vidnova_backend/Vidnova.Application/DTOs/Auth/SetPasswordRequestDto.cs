namespace Vidnova.Application.DTOs.Auth;

public sealed record SetPasswordRequestDto
{
    public string NewPassword { get; init; } = string.Empty;
    public string ConfirmPassword { get; init; } = string.Empty;
}
