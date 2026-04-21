using Vidnova.Application.DTOs.CheckIns;

namespace Vidnova.Application.Services.CheckIns;

public interface IDailyCheckInService
{
    Task<DailyCheckInResponseDto> CreateAsync(
        Guid userId,
        DateOnly date,
        SaveDailyCheckInRequestDto request,
        CancellationToken ct = default
    );

    Task<DailyCheckInResponseDto> UpdateAsync(
        Guid userId,
        DateOnly date,
        SaveDailyCheckInRequestDto request,
        CancellationToken ct = default
    );
    
    Task<DailyCheckInResponseDto> GetByDateAsync(
        Guid userId, 
        DateOnly date, 
        CancellationToken ct = default
        );
    
    Task<List<DailyCheckInResponseDto>> ListRangeAsync(
        Guid userId, 
        DateOnly from, 
        DateOnly to, 
        CancellationToken ct = default
        );
}