using MapsterMapper;
using Vidnova.Application.Common.Interfaces;
using Vidnova.Application.Common.Validation;
using Vidnova.Application.DTOs.Journal.Abc;
using Vidnova.Application.Mappers;
using Vidnova.Domain.Entities;
using Vidnova.Domain.Entities.Journal.Abc;

namespace Vidnova.Application.Services.Journal.Abc;

public sealed class AbcEntryService : IAbcEntryService
{
    private readonly IUnitOfWork _uow;
    private readonly IAbcEntryRepository _repo;
    private readonly IMapper _mapper;

    public AbcEntryService(IUnitOfWork uow, IAbcEntryRepository repo, IMapper mapper)
    {
        _uow = uow;
        _repo = repo;
        _mapper = mapper;
    }

    public async Task<AbcEntryResponseDto> CreateAsync(Guid userId, SaveAbcEntryRequestDto request, CancellationToken ct = default)
    {
        ValidateRequest(request);

        var entry = _mapper.Map<AbcEntry>(request);
        entry.UserId = userId;
        entry.Evidence = AbcEvidenceMapper.MapFromRequest(request);

        _repo.Add(entry);
        await _uow.SaveChangesAsync(ct);

        return _mapper.Map<AbcEntryResponseDto>(entry);
    }

    public async Task<AbcEntryResponseDto> GetByIdAsync(Guid userId, Guid id, CancellationToken ct = default)
    {
        var entity = await _repo.GetByIdAsync(userId, id, ct);
        if (entity is null)
            throw new InvalidOperationException("ABC entry not found.");

        return _mapper.Map<AbcEntryResponseDto>(entity);
    }

    public async Task<List<AbcEntryListItemDto>> ListAsync(Guid userId, CancellationToken ct = default)
    {
        var items = await _repo.ListByUserAsync(userId, ct);
        return _mapper.Map<List<AbcEntryListItemDto>>(items);
    }
    
    public async Task<AbcEntryResponseDto> UpdateAsync(
        Guid userId,
        Guid id,
        SaveAbcEntryRequestDto request,
        CancellationToken ct = default)
    {
        ValidateRequest(request);

        var entity = await _repo.GetByIdForUpdateAsync(userId, id, ct);
        if (entity is null)
            throw new InvalidOperationException("ABC entry not found.");

        entity.Situation = request.Situation.Trim();
        entity.AutomaticThought = request.AutomaticThought.Trim();
        entity.ThoughtBelief = request.ThoughtBelief;
        entity.AlternativeThought = request.AlternativeThought.Trim();
        entity.AlternativeThoughtBelief = request.AlternativeThoughtBelief;
        entity.FinalEmotionIntensity = request.FinalEmotionIntensity;

        await _repo.DeleteEmotionsByEntryIdAsync(entity.Id, ct);
        var emotions = _mapper.Map<List<AbcEntryEmotion>>(request.Emotions);
        foreach (var emotion in emotions)
        {
            emotion.AbcEntryId = entity.Id;
        }
        _repo.AddEmotions(emotions);

        await _repo.DeleteEvidenceByEntryIdAsync(entity.Id, ct);
        _repo.AddEvidence(AbcEvidenceMapper.MapFromRequest(request, entity.Id));

        await _uow.SaveChangesAsync(ct);

        var reloaded = await _repo.GetByIdAsync(userId, id, ct);
        if (reloaded is null)
            throw new InvalidOperationException("ABC entry not found after update.");

        return _mapper.Map<AbcEntryResponseDto>(reloaded);
    }

    public async Task DeleteAsync(Guid userId, Guid id, CancellationToken ct = default)
    {
        var entity = await _repo.GetByIdForUpdateAsync(userId, id, ct);
        if (entity is null)
            throw new InvalidOperationException("ABC entry not found.");

        _repo.Remove(entity);
        await _uow.SaveChangesAsync(ct);
    }

    private static void ValidateRequest(SaveAbcEntryRequestDto request)
    {
        if (string.IsNullOrWhiteSpace(request.Situation))
            throw new ArgumentException("Situation is required.");
        if (string.IsNullOrWhiteSpace(request.AlternativeThought))
            throw new ArgumentException("AlternativeThought is required.");

        var isPositiveFlow = request.Emotions is { Count: > 0 } &&
                             request.Emotions.All(x => x.Emotion is EmotionType.Calm or EmotionType.Joy);

        
        if (!isPositiveFlow && string.IsNullOrWhiteSpace(request.AutomaticThought))
            throw new ArgumentException("AutomaticThought is required.");

        ValidatePercent(request.ThoughtBelief, "ThoughtBelief");
        ValidatePercent(request.AlternativeThoughtBelief, "AlternativeThoughtBelief");
        ValidatePercent(request.FinalEmotionIntensity, "FinalEmotionIntensity");

        if (request.Situation.Length > 2000) throw new ArgumentException("Situation is too long (max 2000 chars).");
        if (request.AutomaticThought.Length > 2000) throw new ArgumentException("AutomaticThought is too long (max 2000 chars).");
        if (request.AlternativeThought.Length > 2000) throw new ArgumentException("AlternativeThought is too long (max 2000 chars).");

        var totalEvidence = (request.EvidenceFor?.Count ?? 0) + (request.EvidenceAgainst?.Count ?? 0);
        if (totalEvidence > 50) throw new ArgumentException("Too many evidence items (max 50).");

        EmotionRules.ValidateEmotionList(
            request.Emotions,
            getEmotion: x => x.Emotion,
            getIntensity: x => x.InitialIntensity,
            maxCount: 20);
    }

    private static void ValidatePercent(int value, string name)
    {
        if (value < 0 || value > 100)
            throw new ArgumentException($"{name} must be between 0 and 100.");
    }
}