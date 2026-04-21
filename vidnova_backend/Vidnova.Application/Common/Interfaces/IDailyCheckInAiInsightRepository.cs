using Vidnova.Domain.Entities;

namespace Vidnova.Application.Common.Interfaces;

public interface IDailyCheckInAiInsightRepository : IRepository<DailyCheckInAiInsight>
{
    Task<DailyCheckInAiInsight?> GetByUserAndDateAsync(Guid userId, DateOnly date, CancellationToken ct = default);
}
