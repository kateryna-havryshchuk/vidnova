using Vidnova.Domain.Entities.Journal.Abc;

namespace Vidnova.Application.Common.Interfaces;

public interface IAbcEntryRepository : IRepository<AbcEntry>
{
    Task<AbcEntry?> GetByIdAsync(Guid userId, Guid id, CancellationToken ct = default);

    Task<List<AbcEntry>> ListByUserAsync(Guid userId, CancellationToken ct = default);
    
    Task<AbcEntry?> GetByIdForUpdateAsync(Guid userId, Guid id, CancellationToken ct = default);

    Task DeleteEmotionsByEntryIdAsync(Guid abcEntryId, CancellationToken ct = default);
    Task DeleteEvidenceByEntryIdAsync(Guid abcEntryId, CancellationToken ct = default);

    void AddEmotions(IEnumerable<AbcEntryEmotion> emotions);
    void AddEvidence(IEnumerable<AbcEvidence> evidence);
}