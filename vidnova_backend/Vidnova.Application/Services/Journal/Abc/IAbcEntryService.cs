using Vidnova.Application.DTOs.Journal.Abc;

namespace Vidnova.Application.Services.Journal.Abc;

public interface IAbcEntryService
{
    Task<AbcEntryResponseDto> CreateAsync(
        Guid userId, 
        SaveAbcEntryRequestDto request, 
        CancellationToken ct = default);

    Task<AbcEntryResponseDto> GetByIdAsync(
        Guid userId, 
        Guid id, 
        CancellationToken ct = default);

    Task<List<AbcEntryListItemDto>> ListAsync(
        Guid userId, 
        CancellationToken ct = default);
    
    Task<AbcEntryResponseDto> UpdateAsync(
        Guid userId,
        Guid id,
        SaveAbcEntryRequestDto request,
        CancellationToken ct = default);

    Task DeleteAsync(
        Guid userId, 
        Guid id, 
        CancellationToken ct = default);
}