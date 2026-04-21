namespace Vidnova.Application.DTOs.CheckIns;

public sealed record DailyCheckInResponseDto(
    Guid Id,
    DateOnly Date,
    string Description,
    int CalmScore,
    List<CheckInEmotionDto> Emotions
);