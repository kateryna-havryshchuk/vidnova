using MapsterMapper;
using Vidnova.Application.Common.Interfaces;
using Vidnova.Application.DTOs.Auth;

namespace Vidnova.Application.Services.Auth;

public sealed class MeService: IMeService
{
    private readonly IUserRepository _userRepository;
    private readonly IMapper _mapper;

    public MeService(IUserRepository userRepository, IMapper mapper)
    {
        _userRepository = userRepository;
        _mapper = mapper;
    }

    public async Task<MeResponseDto> GetMeAsync(Guid userId, CancellationToken ct = default)
    {
        var user = await _userRepository.GetByIdAsync(userId, ct);

        if (user is null)
            throw new UnauthorizedAccessException("User not found");

        return _mapper.Map<MeResponseDto>(user);
    }
}