using Vidnova.Domain.Entities;

namespace Vidnova.Application.DTOs.Journal.Abc;

public sealed record AbcEntryEmotionDto(
    EmotionType Emotion,
    int InitialIntensity
);