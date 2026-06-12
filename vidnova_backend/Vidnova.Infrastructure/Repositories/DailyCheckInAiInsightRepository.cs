using Microsoft.EntityFrameworkCore;
using Vidnova.Application.Common.Interfaces;
using Vidnova.Domain.Entities;
using Vidnova.Infrastructure.Persistence;

namespace Vidnova.Infrastructure.Repositories;

public sealed class DailyCheckInAiInsightRepository : IDailyCheckInAiInsightRepository
{
    private readonly AppDbContext _db;

    public DailyCheckInAiInsightRepository(AppDbContext db) => _db = db;

    public void Add(DailyCheckInAiInsight entity) => _db.DailyCheckInAiInsights.Add(entity);

    public void Remove(DailyCheckInAiInsight entity) => _db.DailyCheckInAiInsights.Remove(entity);

    public Task<DailyCheckInAiInsight?> GetByUserAndDateAsync(Guid userId, DateOnly date, CancellationToken ct = default)
        => _db.DailyCheckInAiInsights
            .FirstOrDefaultAsync(x => x.UserId == userId && x.Date == date, ct);
}
