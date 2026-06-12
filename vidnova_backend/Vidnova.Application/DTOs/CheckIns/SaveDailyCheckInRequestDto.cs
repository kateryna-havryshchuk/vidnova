namespace Vidnova.Application.DTOs.CheckIns;

public sealed record SaveDailyCheckInRequestDto(
    string? Description,
    int CalmScore,
    List<CheckInEmotionDto> Emotions
);
