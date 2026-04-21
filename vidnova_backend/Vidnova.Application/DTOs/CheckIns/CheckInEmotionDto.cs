using Vidnova.Domain.Entities;

namespace Vidnova.Application.DTOs.CheckIns;

public sealed record CheckInEmotionDto(
    EmotionType Emotion,
    int Intensity
);