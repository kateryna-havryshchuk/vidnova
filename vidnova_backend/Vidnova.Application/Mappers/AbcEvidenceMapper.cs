using Vidnova.Application.DTOs.Journal.Abc;
using Vidnova.Domain.Entities.Journal.Abc;

namespace Vidnova.Application.Mappers;

public static class AbcEvidenceMapper
{
    public static List<AbcEvidence> MapFromRequest(SaveAbcEntryRequestDto request, Guid? abcEntryId = null)
    {
        var evidence = new List<AbcEvidence>();

        evidence.AddRange((request.EvidenceFor ?? new List<string>())
            .Where(x => !string.IsNullOrWhiteSpace(x))
            .Select(x => new AbcEvidence
            {
                AbcEntryId = abcEntryId ?? Guid.Empty,
                IsFor = true,
                Text = x.Trim()
            }));

        evidence.AddRange((request.EvidenceAgainst ?? new List<string>())
            .Where(x => !string.IsNullOrWhiteSpace(x))
            .Select(x => new AbcEvidence
            {
                AbcEntryId = abcEntryId ?? Guid.Empty,
                IsFor = false,
                Text = x.Trim()
            }));

        return evidence;
    }
}
