using Microsoft.EntityFrameworkCore;
using Vidnova.Application.Common.Interfaces;
using Vidnova.Domain.Entities;
using Vidnova.Infrastructure.Persistence;

namespace Vidnova.Infrastructure.Repositories;

public sealed class DailyCheckInRepository : IDailyCheckInRepository
{
    private readonly AppDbContext _db;

    public DailyCheckInRepository(AppDbContext db) => _db = db;

    public void Add(DailyCheckIn entity) => _db.DailyCheckIns.Add(entity);
    public void Remove(DailyCheckIn entity) => _db.DailyCheckIns.Remove(entity);

    public void AddEmotions(IEnumerable<DailyCheckInEmotion> emotions)
        => _db.DailyCheckInEmotions.AddRange(emotions);

    public Task DeleteEmotionsByCheckInIdAsync(Guid dailyCheckInId, CancellationToken ct = default)
        => _db.DailyCheckInEmotions
            .Where(x => x.DailyCheckInId == dailyCheckInId)
            .ExecuteDeleteAsync(ct);

    public Task<DailyCheckIn?> GetByUserAndDateAsync(Guid userId, DateOnly date, CancellationToken ct = default)
        => _db.DailyCheckIns
            .Include(x => x.Emotions)
            .FirstOrDefaultAsync(x => x.UserId == userId && x.Date == date, ct);

    public Task<DailyCheckIn?> GetByUserAndDateForUpdateAsync(Guid userId, DateOnly date, CancellationToken ct = default)
        => _db.DailyCheckIns
            .FirstOrDefaultAsync(x => x.UserId == userId && x.Date == date, ct);

    public Task<List<DailyCheckIn>> ListByUserAndRangeAsync(Guid userId, DateOnly from, DateOnly to, CancellationToken ct = default)
        => _db.DailyCheckIns
            .Include(x => x.Emotions)
            .Where(x => x.UserId == userId && x.Date >= from && x.Date <= to)
            .OrderBy(x => x.Date)
            .ToListAsync(ct);
}