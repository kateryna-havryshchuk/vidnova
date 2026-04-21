using Vidnova.Domain.Common;

namespace Vidnova.Domain.Entities.Journal.Abc;

public sealed class AbcEvidence : BaseEntity
{
    public Guid AbcEntryId { get; set; }
    public AbcEntry? AbcEntry { get; set; }

    public bool IsFor { get; set; }
    public string Text { get; set; } = string.Empty;
}