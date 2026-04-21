namespace Vidnova.Application.DTOs.Auth;

public sealed record LoginRequestDto
{
    public string Username { get; init; } = string.Empty;
    public string Password { get; init; } = string.Empty;
}