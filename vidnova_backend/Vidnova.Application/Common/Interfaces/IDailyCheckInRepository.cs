using Vidnova.Domain.Entities;

namespace Vidnova.Application.Common.Interfaces;

public interface IDailyCheckInRepository : IRepository<DailyCheckIn>
{
    Task<DailyCheckIn?> GetByUserAndDateAsync(
        Guid userId, 
        DateOnly date, 
        CancellationToken ct = default
        );

    Task<DailyCheckIn?> GetByUserAndDateForUpdateAsync(
        Guid userId,
        DateOnly date,
        CancellationToken ct = default
    );
    
    Task<List<DailyCheckIn>> ListByUserAndRangeAsync(
        Guid userId, 
        DateOnly from, 
        DateOnly to, 
        CancellationToken ct = default
        );

    Task DeleteEmotionsByCheckInIdAsync(Guid dailyCheckInId, CancellationToken ct = default);

    void AddEmotions(IEnumerable<DailyCheckInEmotion> emotions);
}