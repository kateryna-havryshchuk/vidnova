namespace Vidnova.Application.DTOs.Journal.Abc;

public sealed record AbcEntryListItemDto(
    Guid Id,
    DateTime CreatedDate,
    string Situation,
    int FinalEmotionIntensity,
    List<AbcEntryEmotionDto> Emotions
);