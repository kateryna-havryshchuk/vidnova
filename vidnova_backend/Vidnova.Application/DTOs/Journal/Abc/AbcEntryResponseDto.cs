namespace Vidnova.Application.DTOs.Journal.Abc;

public sealed record AbcEntryResponseDto(
    Guid Id,
    DateTime CreatedDate,
    string Situation,
    string AutomaticThought,
    int ThoughtBelief,
    List<AbcEvidenceDto> EvidenceFor,
    List<AbcEvidenceDto> EvidenceAgainst,
    string AlternativeThought,
    int AlternativeThoughtBelief,
    int FinalEmotionIntensity,
    List<AbcEntryEmotionDto> Emotions
);