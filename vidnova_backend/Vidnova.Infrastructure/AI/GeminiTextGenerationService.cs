using System.Net.Http.Json;
using System.Text.Json;
using Microsoft.Extensions.Options;
using Vidnova.Application.Common.Interfaces;
using Vidnova.Application.Common.Models;

namespace Vidnova.Infrastructure.AI;

public sealed class GeminiTextGenerationService : ITextGenerationService
{
    private readonly HttpClient _http;
    private readonly GeminiOptions _options;

    public GeminiTextGenerationService(HttpClient http, IOptions<GeminiOptions> options)
    {
        _http = http;
        _options = options.Value;
    }

    public async Task<TextGenerationResult> GenerateAsync(string prompt, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(_options.ApiKey))
            throw new InvalidOperationException("Gemini ApiKey is not configured. Set Gemini:ApiKey (or env Gemini__ApiKey).");

        var requestedModel = string.IsNullOrWhiteSpace(_options.Model) ? "gemini-flash-lite-latest" : _options.Model.Trim();
        var normalizedModel = NormalizeModel(requestedModel);

        var payload = new
        {
            contents = new[]
            {
                new
                {
                    parts = new[]
                    {
                        new { text = prompt }
                    }
                }
            },
            generationConfig = new
            {
                temperature = 0.4,
                maxOutputTokens = 300
            }
        };

        // First try the configured model.
        var firstAttempt = await TryGenerateAsync(normalizedModel, payload, ct);
        if (firstAttempt is not null) return firstAttempt;

        // If model is not supported/available for this API key, resolve a working model via ListModels and retry once.
        var (fallbackModel, available) = await ResolveFallbackModelAsync(normalizedModel, ct);
        if (fallbackModel is null)
        {
            var list = available.Count == 0 ? "(no models returned)" : string.Join(", ", available);
            throw new InvalidOperationException(
                $"Gemini model '{normalizedModel}' is not available for generateContent. Available models: {list}. " +
                "Set Gemini:Model (env Gemini__Model) to one of the available models.");
        }

        var secondAttempt = await TryGenerateAsync(fallbackModel, payload, ct);
        if (secondAttempt is not null) return secondAttempt;

        throw new InvalidOperationException(
            $"Gemini model '{normalizedModel}' failed, and fallback model '{fallbackModel}' also failed.");
    }

    private async Task<TextGenerationResult?> TryGenerateAsync(string model, object payload, CancellationToken ct)
    {
        var url = $"/v1beta/models/{Uri.EscapeDataString(model)}:generateContent?key={Uri.EscapeDataString(_options.ApiKey)}";

        using var res = await _http.PostAsJsonAsync(url, payload, cancellationToken: ct);
        var body = await res.Content.ReadAsStringAsync(ct);

        if (!res.IsSuccessStatusCode)
        {
            // For model mismatch errors we'll attempt model discovery, so just return null for retry.
            if ((int)res.StatusCode == 404 && body.Contains("is not found", StringComparison.OrdinalIgnoreCase))
                return null;

            throw new InvalidOperationException($"Gemini request failed ({(int)res.StatusCode}). {body}");
        }

        using var doc = JsonDocument.Parse(body);

        // candidates[0].content.parts[0].text
        if (!doc.RootElement.TryGetProperty("candidates", out var candidates) || candidates.ValueKind != JsonValueKind.Array)
            throw new InvalidOperationException("Gemini response: missing candidates.");

        var first = candidates.EnumerateArray().FirstOrDefault();
        if (first.ValueKind == JsonValueKind.Undefined)
            throw new InvalidOperationException("Gemini response: empty candidates.");

        if (!first.TryGetProperty("content", out var content))
            throw new InvalidOperationException("Gemini response: missing content.");

        if (!content.TryGetProperty("parts", out var parts) || parts.ValueKind != JsonValueKind.Array)
            throw new InvalidOperationException("Gemini response: missing parts.");

        var texts = parts.EnumerateArray()
            .Where(p => p.ValueKind == JsonValueKind.Object)
            .Select(p =>
            {
                if (!p.TryGetProperty("text", out var t) || t.ValueKind != JsonValueKind.String)
                    return string.Empty;
                return t.GetString() ?? string.Empty;
            })
            .Where(s => !string.IsNullOrWhiteSpace(s))
            .ToList();

        if (texts.Count == 0)
            throw new InvalidOperationException("Gemini response: missing text.");

        var text = string.Join("", texts).Trim();
        if (text.Length == 0)
            throw new InvalidOperationException("Gemini response: empty text.");

        return new TextGenerationResult(model, text);
    }

    private async Task<(string? Model, List<string> AvailableModels)> ResolveFallbackModelAsync(string requestedModel, CancellationToken ct)
    {
        var available = await ListGenerateContentModelsAsync(ct);

        if (available.Count == 0)
            return (null, available);

        // Exact match.
        if (available.Contains(requestedModel, StringComparer.OrdinalIgnoreCase))
            return (available.First(x => x.Equals(requestedModel, StringComparison.OrdinalIgnoreCase)), available);

        // Prefer the lightest/cheapest models first.
        var preferences = new[]
        {
            "gemini-flash-lite-latest",
            "gemini-2.0-flash-lite",
            "gemini-2.0-flash-lite-001",
            "gemini-2.5-flash-lite",
            "gemini-flash-latest",
            "gemini-2.0-flash",
            "gemini-2.5-flash",
        };

        foreach (var pref in preferences)
        {
            if (available.Contains(pref, StringComparer.OrdinalIgnoreCase))
                return (available.First(x => x.Equals(pref, StringComparison.OrdinalIgnoreCase)), available);
        }

        // Sometimes config contains "-latest" or other suffixes; try contains match.
        var contains = available.FirstOrDefault(x => x.Contains(requestedModel, StringComparison.OrdinalIgnoreCase));
        if (!string.IsNullOrWhiteSpace(contains))
            return (contains, available);

        // As a last resort, pick the first available generateContent model.
        return (available[0], available);
    }

    private async Task<List<string>> ListGenerateContentModelsAsync(CancellationToken ct)
    {
        var results = new List<string>();
        string? pageToken = null;

        while (true)
        {
            var url = $"/v1beta/models?key={Uri.EscapeDataString(_options.ApiKey)}" +
                      (string.IsNullOrWhiteSpace(pageToken) ? string.Empty : $"&pageToken={Uri.EscapeDataString(pageToken)}");

            using var res = await _http.GetAsync(url, ct);
            var body = await res.Content.ReadAsStringAsync(ct);

            if (!res.IsSuccessStatusCode)
                return results; // Don't block generation with secondary call errors.

            using var doc = JsonDocument.Parse(body);

            if (doc.RootElement.TryGetProperty("models", out var modelsEl) && modelsEl.ValueKind == JsonValueKind.Array)
            {
                foreach (var m in modelsEl.EnumerateArray())
                {
                    if (!m.TryGetProperty("name", out var nameEl) || nameEl.ValueKind != JsonValueKind.String)
                        continue;

                    var name = nameEl.GetString() ?? string.Empty; // e.g. "models/gemini-1.5-flash"

                    if (!m.TryGetProperty("supportedGenerationMethods", out var methodsEl) || methodsEl.ValueKind != JsonValueKind.Array)
                        continue;

                    var supportsGenerate = methodsEl.EnumerateArray()
                        .Where(x => x.ValueKind == JsonValueKind.String)
                        .Select(x => x.GetString() ?? string.Empty)
                        .Any(x => x.Equals("generateContent", StringComparison.OrdinalIgnoreCase));

                    if (!supportsGenerate) continue;

                    var normalized = NormalizeModel(name);
                    if (normalized.Length == 0) continue;

                    if (!results.Contains(normalized, StringComparer.OrdinalIgnoreCase))
                        results.Add(normalized);
                }
            }

            pageToken = null;
            if (doc.RootElement.TryGetProperty("nextPageToken", out var tokenEl) && tokenEl.ValueKind == JsonValueKind.String)
            {
                pageToken = tokenEl.GetString();
            }

            if (string.IsNullOrWhiteSpace(pageToken))
                break;

            if (results.Count >= 200)
                break;
        }

        return results;
    }

    private static string NormalizeModel(string model)
    {
        var m = (model ?? string.Empty).Trim();
        if (m.StartsWith("models/", StringComparison.OrdinalIgnoreCase))
            m = m["models/".Length..];
        return m;
    }
}
