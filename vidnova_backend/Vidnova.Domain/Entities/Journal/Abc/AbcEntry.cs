using Vidnova.Domain.Common;

namespace Vidnova.Domain.Entities.Journal.Abc;

public sealed class AbcEntry: BaseEntity
{
    public Guid UserId { get; set; }

    public string Situation { get; set; } = string.Empty;

    public string AutomaticThought { get; set; } = string.Empty;
    public int ThoughtBelief { get; set; } 

    public string AlternativeThought { get; set; } = string.Empty;
    public int AlternativeThoughtBelief { get; set; }

    public int FinalEmotionIntensity { get; set; }

    public List<AbcEntryEmotion> Emotions { get; set; } = new();
    public List<AbcEvidence> Evidence { get; set; } = new();
}