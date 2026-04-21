using Vidnova.Application.DTOs.CheckIns;

namespace Vidnova.Application.Services.CheckIns;

public interface IDailyCheckInAiInsightService
{
    Task<DailyCheckInAiInsightResponseDto> GetOrGenerateAsync(Guid userId, DateOnly date, CancellationToken ct = default);
}
