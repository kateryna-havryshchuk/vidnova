using Mapster;
using Vidnova.Application.DTOs.Auth;
using Vidnova.Domain.Entities;

namespace Vidnova.Application.Mappers;

public sealed class UserMappingConfig : IRegister
{
    public void Register(TypeAdapterConfig config)
    {
        config.NewConfig<User, MeResponseDto>()
            .Map(dest => dest.UserId, src => src.Id)
            .Map(dest => dest.UserName, src => src.Username)
            .Map(dest => dest.HasPassword, src => !string.IsNullOrWhiteSpace(src.PasswordHash))
            .Map(dest => dest.IsGoogleAccount, src => !string.IsNullOrWhiteSpace(src.GoogleSubject));
    }
}
