using Vidnova.Domain.Common;
using Vidnova.Domain.Entities;

namespace Vidnova.Domain.Entities.Journal.Abc;

public sealed class AbcEntryEmotion:BaseEntity
{
    public Guid AbcEntryId { get; set; }
    public AbcEntry? AbcEntry { get; set; }

    public EmotionType Emotion { get; set; }
    public int InitialIntensity { get; set; } 
}