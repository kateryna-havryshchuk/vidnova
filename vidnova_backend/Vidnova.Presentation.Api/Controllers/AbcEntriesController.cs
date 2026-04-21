using System.IdentityModel.Tokens.Jwt;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Vidnova.Application.DTOs.Journal.Abc;
using Vidnova.Application.Services.Journal.Abc;

namespace Vidnova.Presentation.Api.Controllers;

[ApiController]
[Route("api/journal/abc")]
[Authorize]
public sealed class AbcEntriesController : ControllerBase
{
    private readonly IAbcEntryService _service;

    public AbcEntriesController(IAbcEntryService service)
    {
        _service = service;
    }

    [HttpPost]
    public async Task<ActionResult<AbcEntryResponseDto>> Create([FromBody] SaveAbcEntryRequestDto request, CancellationToken ct)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(new ProblemDetails { Title = "Unauthorized", Detail = "Invalid token subject (sub)." });

        try
        {
            var result = await _service.CreateAsync(userId, request, ct);
            return Ok(result);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new ProblemDetails { Title = "Validation error", Detail = ex.Message });
        }
    }

    [HttpGet]
    public async Task<ActionResult<List<AbcEntryListItemDto>>> List(CancellationToken ct)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(new ProblemDetails { Title = "Unauthorized", Detail = "Invalid token subject (sub)." });

        var result = await _service.ListAsync(userId, ct);
        return Ok(result);
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult<AbcEntryResponseDto>> GetById(Guid id, CancellationToken ct)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(new ProblemDetails { Title = "Unauthorized", Detail = "Invalid token subject (sub)." });

        try
        {
            var result = await _service.GetByIdAsync(userId, id, ct);
            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new ProblemDetails { Title = "Not found", Detail = ex.Message });
        }
    }
    
    [HttpPut("{id:guid}")]
    public async Task<ActionResult<AbcEntryResponseDto>> Update(Guid id, [FromBody] SaveAbcEntryRequestDto request, CancellationToken ct)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(new ProblemDetails { Title = "Unauthorized", Detail = "Invalid token subject (sub)." });

        try
        {
            var result = await _service.UpdateAsync(userId, id, request, ct);
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
    }

    [HttpDelete("{id:guid}")]
    public async Task<IActionResult> Delete(Guid id, CancellationToken ct)
    {
        if (!TryGetUserId(out var userId))
            return Unauthorized(new ProblemDetails { Title = "Unauthorized", Detail = "Invalid token subject (sub)." });

        try
        {
            await _service.DeleteAsync(userId, id, ct);
            return NoContent();
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(new ProblemDetails { Title = "Not found", Detail = ex.Message });
        }
    }

    private bool TryGetUserId(out Guid userId)
    {
        var sub = User.FindFirst(JwtRegisteredClaimNames.Sub)?.Value;
        return Guid.TryParse(sub, out userId);
    }
}