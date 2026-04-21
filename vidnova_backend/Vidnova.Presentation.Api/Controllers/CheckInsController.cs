using System.IdentityModel.Tokens.Jwt;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Vidnova.Application.DTOs.CheckIns;
using Vidnova.Application.Services.CheckIns;

namespace Vidnova.Presentation.Api.Controllers;

[ApiController]
[Route("api/checkins")]
[Authorize]
public sealed class CheckInsController : ControllerBase
{
    private readonly IDailyCheckInService _service;
    private readonly IDailyCheckInAiInsightService _aiInsights;

    public CheckInsController(IDailyCheckInService service, IDailyCheckInAiInsightService aiInsights)
    {
        _service = service;
        _aiInsights = aiInsights;
    }

    [HttpGet("{date}")]
    public async Task<ActionResult<DailyCheckInResponseDto>> GetByDate(DateOnly date, CancellationToken ct)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(new ProblemDetails { Title = "Unauthorized", Detail = "Invalid token subject (sub)." });

        try
        {
            var result = await _service.GetByDateAsync(userId, date, ct);
            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new ProblemDetails { Title = "Not found", Detail = ex.Message });
        }
    }

    [HttpPost("{date}")]
    public async Task<ActionResult<DailyCheckInResponseDto>> Create(
        DateOnly date,
        [FromBody] SaveDailyCheckInRequestDto request,
        CancellationToken ct)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(new ProblemDetails { Title = "Unauthorized", Detail = "Invalid token subject (sub)." });

        try
        {
            var result = await _service.CreateAsync(userId, date, request, ct);
            return CreatedAtAction(nameof(GetByDate), new { date = result.Date }, result);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new ProblemDetails { Title = "Validation error", Detail = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return Conflict(new ProblemDetails { Title = "Conflict", Detail = ex.Message });
        }
        catch (DbUpdateException)
        {
            return Conflict(new ProblemDetails
            {
                Title = "Conflict",
                Detail = "Check-in already exists for this date."
            });
        }
    }

    [HttpPut("{date}")]
    public async Task<ActionResult<DailyCheckInResponseDto>> Update(DateOnly date, [FromBody] SaveDailyCheckInRequestDto request, CancellationToken ct)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(new ProblemDetails { Title = "Unauthorized", Detail = "Invalid token subject (sub)." });

        try
        {
            var result = await _service.UpdateAsync(userId, date, request, ct);
            return Ok(result);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new ProblemDetails { Title = "Validation error", Detail = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new ProblemDetails { Title = "Not found", Detail = ex.Message });
        }
        catch (DbUpdateConcurrencyException)
        {
            return Conflict(new ProblemDetails
            {
                Title = "Concurrency conflict",
                Detail = "The check-in was modified concurrently. Please retry the request."
            });
        }
    }

    [HttpGet]
    public async Task<ActionResult<List<DailyCheckInResponseDto>>> ListRange([FromQuery] DateOnly from, [FromQuery] DateOnly to, CancellationToken ct)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(new ProblemDetails { Title = "Unauthorized", Detail = "Invalid token subject (sub)." });

        try
        {
            var result = await _service.ListRangeAsync(userId, from, to, ct);
            return Ok(result);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new ProblemDetails { Title = "Validation error", Detail = ex.Message });
        }
    }

    [HttpGet("{date}/insight")]
    public async Task<ActionResult<DailyCheckInAiInsightResponseDto>> GetInsight(DateOnly date, CancellationToken ct)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(new ProblemDetails { Title = "Unauthorized", Detail = "Invalid token subject (sub)." });

        try
        {
            var result = await _aiInsights.GetOrGenerateAsync(userId, date, ct);
            return Ok(result);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new ProblemDetails { Title = "Not found", Detail = ex.Message });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new ProblemDetails { Title = "Validation error", Detail = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return StatusCode(502, new ProblemDetails { Title = "AI error", Detail = ex.Message });
        }
    }

    private bool TryGetUserId(out Guid userId)
    {
        var sub = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value;
        return Guid.TryParse(sub, out userId);
    }
}