namespace Vidnova.Application.DTOs.CheckIns;

public sealed record DailyCheckInAiInsightResponseDto(
    Guid Id,
    DateOnly Date,
    string Model,
    DateTime SourceUpdatedAtUtc,
    string PromptText,
    string ResponseText
);
