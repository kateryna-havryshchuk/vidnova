using Microsoft.EntityFrameworkCore;
using Vidnova.Application.Common.Interfaces;
using Vidnova.Domain.Entities.Journal.Abc;
using Vidnova.Infrastructure.Persistence;

namespace Vidnova.Infrastructure.Repositories;

public sealed class AbcEntryRepository : IAbcEntryRepository
{
    private readonly AppDbContext _db;
    public AbcEntryRepository(AppDbContext db) => _db = db;

    public void Add(AbcEntry entity) => _db.Set<AbcEntry>().Add(entity);
    public void Remove(AbcEntry entity) => _db.Set<AbcEntry>().Remove(entity);

    public Task<AbcEntry?> GetByIdAsync(Guid userId, Guid id, CancellationToken ct = default)
        => _db.Set<AbcEntry>()
            .Include(x => x.Emotions)
            .Include(x => x.Evidence)
            .FirstOrDefaultAsync(x => x.UserId == userId && x.Id == id, ct);

    public Task<List<AbcEntry>> ListByUserAsync(Guid userId, CancellationToken ct = default)
        => _db.Set<AbcEntry>()
            .Include(x => x.Emotions)
            .Where(x => x.UserId == userId)
            .OrderByDescending(x => x.CreatedDate)
            .ToListAsync(ct);
    
    public Task<AbcEntry?> GetByIdForUpdateAsync(Guid userId, Guid id, CancellationToken ct = default)
        => _db.Set<AbcEntry>()
            .FirstOrDefaultAsync(x => x.UserId == userId && x.Id == id, ct);

    public Task DeleteEmotionsByEntryIdAsync(Guid abcEntryId, CancellationToken ct = default)
        => _db.Set<AbcEntryEmotion>()
            .Where(x => x.AbcEntryId == abcEntryId)
            .ExecuteDeleteAsync(ct);

    public Task DeleteEvidenceByEntryIdAsync(Guid abcEntryId, CancellationToken ct = default)
        => _db.Set<AbcEvidence>()
            .Where(x => x.AbcEntryId == abcEntryId)
            .ExecuteDeleteAsync(ct);

    public void AddEmotions(IEnumerable<AbcEntryEmotion> emotions)
        => _db.Set<AbcEntryEmotion>().AddRange(emotions);

    public void AddEvidence(IEnumerable<AbcEvidence> evidence)
        => _db.Set<AbcEvidence>().AddRange(evidence);
}