namespace Vidnova.Infrastructure.AI;

public sealed class GeminiOptions
{
    public string ApiKey { get; init; } = string.Empty;
    public string Model { get; init; } = "gemini-flash-lite-latest";

    /// <summary>
    /// Base URL for Gemini API (do not include path).
    /// </summary>
    public string BaseUrl { get; init; } = "https://generativelanguage.googleapis.com";
}
