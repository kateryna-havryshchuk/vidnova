namespace Vidnova.Application.DTOs.Journal.Abc;

public sealed record SaveAbcEntryRequestDto(
    string Situation,
    string AutomaticThought,
    int ThoughtBelief,
    List<string> EvidenceFor,
    List<string> EvidenceAgainst,
    string AlternativeThought,
    int AlternativeThoughtBelief,
    int FinalEmotionIntensity,
    List<AbcEntryEmotionDto> Emotions
);