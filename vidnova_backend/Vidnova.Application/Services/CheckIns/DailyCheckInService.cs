using MapsterMapper;
using Vidnova.Application.Common.Interfaces;
using Vidnova.Application.Common.Validation;
using Vidnova.Application.DTOs.CheckIns;
using Vidnova.Domain.Entities;

namespace Vidnova.Application.Services.CheckIns;

public sealed class DailyCheckInService: IDailyCheckInService
{
    private readonly IUnitOfWork _uow;
    private readonly IDailyCheckInRepository _repo;
    private readonly IMapper _mapper;

    public DailyCheckInService(IUnitOfWork uow, IDailyCheckInRepository repo, IMapper mapper)
    {
        _uow = uow;
        _repo = repo;
        _mapper = mapper;
    }
    
    public async Task<DailyCheckInResponseDto> CreateAsync(
        Guid userId,
        DateOnly date,
        SaveDailyCheckInRequestDto request,
        CancellationToken ct = default)
    {
        ValidateRequest(request);

        var existing = await _repo.GetByUserAndDateForUpdateAsync(userId, date, ct);
        if (existing is not null)
            throw new InvalidOperationException("Check-in already exists for this date.");

        var entity = _mapper.Map<DailyCheckIn>(request);
        entity.UserId = userId;
        entity.Date = date;

        _repo.Add(entity);
        await _uow.SaveChangesAsync(ct);

        return _mapper.Map<DailyCheckInResponseDto>(entity);
    }

    public async Task<DailyCheckInResponseDto> UpdateAsync(
        Guid userId,
        DateOnly date,
        SaveDailyCheckInRequestDto request,
        CancellationToken ct = default)
    {
        ValidateRequest(request);

        var entity = await _repo.GetByUserAndDateForUpdateAsync(userId, date, ct);
        if (entity is null)
            throw new InvalidOperationException("Check-in not found for this date.");

        entity.Description = (request.Description ?? string.Empty).Trim();
        entity.CalmScore = request.CalmScore;

        await _repo.DeleteEmotionsByCheckInIdAsync(entity.Id, ct);
        var emotions = _mapper.Map<List<DailyCheckInEmotion>>(request.Emotions);
        foreach (var emotion in emotions)
        {
            emotion.DailyCheckInId = entity.Id;
        }
        _repo.AddEmotions(emotions);

        await _uow.SaveChangesAsync(ct);

        var reloaded = await _repo.GetByUserAndDateAsync(userId, date, ct);
        if (reloaded is null)
            throw new InvalidOperationException("Check-in not found after update.");

        return _mapper.Map<DailyCheckInResponseDto>(reloaded);
    }
    
    public async Task<DailyCheckInResponseDto> GetByDateAsync(Guid userId, DateOnly date, CancellationToken ct = default)
    {
        var entity = await _repo.GetByUserAndDateAsync(userId, date, ct);
        if (entity is null)
            throw new InvalidOperationException("Check-in not found for this date.");

        return _mapper.Map<DailyCheckInResponseDto>(entity);
    }

    public async Task<List<DailyCheckInResponseDto>> ListRangeAsync(Guid userId, DateOnly from, DateOnly to, CancellationToken ct = default)
    {
        if (to < from) throw new ArgumentException("Invalid date range.");

        var items = await _repo.ListByUserAndRangeAsync(userId, from, to, ct);
        return _mapper.Map<List<DailyCheckInResponseDto>>(items);
    }

    private static void ValidateRequest(SaveDailyCheckInRequestDto request)
    {
        if (request.CalmScore < 0 || request.CalmScore > 100)
            throw new ArgumentException("CalmScore must be between 0 and 100.");

        var description = request.Description ?? string.Empty;
        if (description.Length > 1500)
            throw new ArgumentException("Description is too long (max 1500 chars).");

        EmotionRules.ValidateEmotionList(
            emotions: request.Emotions,
            getEmotion: e => e.Emotion,
            getIntensity: e => e.Intensity
        );
    }
}