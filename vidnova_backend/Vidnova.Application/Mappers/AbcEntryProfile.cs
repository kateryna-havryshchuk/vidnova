using Mapster;
using Vidnova.Application.DTOs.Journal.Abc;
using Vidnova.Domain.Entities.Journal.Abc;

namespace Vidnova.Application.Mappers;

public sealed class AbcEntryMappingConfig : IRegister
{
    public void Register(TypeAdapterConfig config)
    {
        config.NewConfig<AbcEntry, AbcEntryResponseDto>()
            .Map(dest => dest.EvidenceFor, src => src.Evidence.Where(e => e.IsFor).ToList())
            .Map(dest => dest.EvidenceAgainst, src => src.Evidence.Where(e => !e.IsFor).ToList())
            .Map(dest => dest.Emotions, src => src.Emotions.OrderBy(e => e.Emotion).ToList());

        config.NewConfig<AbcEntry, AbcEntryListItemDto>()
            .Map(dest => dest.Emotions, src => src.Emotions.OrderBy(e => e.Emotion).ToList());

        config.NewConfig<AbcEvidence, AbcEvidenceDto>();

        config.NewConfig<AbcEntryEmotion, AbcEntryEmotionDto>();

        config.NewConfig<AbcEntryEmotionDto, AbcEntryEmotion>();

        config.NewConfig<SaveAbcEntryRequestDto, AbcEntry>()
            .Map(dest => dest.Situation, src => src.Situation.Trim())
            .Map(dest => dest.AutomaticThought, src => src.AutomaticThought.Trim())
            .Map(dest => dest.AlternativeThought, src => src.AlternativeThought.Trim())
            .Map(dest => dest.Emotions, src => src.Emotions)
            .Ignore(dest => dest.Evidence);
    }
}
