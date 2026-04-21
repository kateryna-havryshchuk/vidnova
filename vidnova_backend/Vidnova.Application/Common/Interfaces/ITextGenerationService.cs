using Vidnova.Application.Common.Models;

namespace Vidnova.Application.Common.Interfaces;

public interface ITextGenerationService
{
    Task<TextGenerationResult> GenerateAsync(string prompt, CancellationToken ct = default);
}
