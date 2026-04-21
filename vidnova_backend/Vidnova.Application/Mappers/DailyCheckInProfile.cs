using Mapster;
using Vidnova.Application.DTOs.CheckIns;
using Vidnova.Domain.Entities;

namespace Vidnova.Application.Mappers;

public sealed class DailyCheckInMappingConfig : IRegister
{
    public void Register(TypeAdapterConfig config)
    {
        config.NewConfig<DailyCheckIn, DailyCheckInResponseDto>()
            .Map(dest => dest.Emotions, src => src.Emotions.OrderBy(e => e.Emotion).ToList());

        config.NewConfig<DailyCheckInEmotion, CheckInEmotionDto>();

        config.NewConfig<CheckInEmotionDto, DailyCheckInEmotion>();

        config.NewConfig<SaveDailyCheckInRequestDto, DailyCheckIn>()
            .Map(dest => dest.Description, src => (src.Description ?? string.Empty).Trim())
            .Map(dest => dest.Emotions, src => src.Emotions);

        config.NewConfig<DailyCheckInAiInsight, DailyCheckInAiInsightResponseDto>();
    }
}
