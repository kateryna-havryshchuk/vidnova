using Microsoft.AspNetCore.Mvc;
using Vidnova.Application.DTOs.Auth;
using Vidnova.Application.Services.Auth;

namespace Vidnova.Presentation.Api.Controllers;

[ApiController]
[Route("api/auth")]
public sealed class AuthController: ControllerBase
{   
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    [HttpPost("register")]
    public async Task<ActionResult<AuthResponseDto>> Register(
        [FromBody] RegisterRequestDto registerRequestDto,
        CancellationToken cancellationToken)
    {
        try
        {
            var result = await _authService.RegisterAsync(registerRequestDto);
            return Ok(result);
        }
        catch (ArgumentException exception)
        {
            return BadRequest(new ProblemDetails
            {
                Title = "Register error",
                Detail = exception.Message,
            });
        }
        catch (InvalidOperationException exception)
        {
            return BadRequest(new ProblemDetails
            {
                Title = "Conflict",
                Detail = exception.Message,
            });
        }
    }

    [HttpPost("login")]
    public async Task<ActionResult<AuthResponseDto>> Login(
        [FromBody] LoginRequestDto loginRequestDto,
        CancellationToken cancellationToken)
    {
        try
        {
            var result = await _authService.LoginAsync(loginRequestDto);
            return Ok(result);
        }
        catch (ArgumentException exception)
        {
            return BadRequest(new ProblemDetails
            {
                Title = "Validation error",
                Detail = exception.Message,
            });
        }
        catch (UnauthorizedAccessException exception)
        {
            return Unauthorized(new ProblemDetails
            {
                Title = "Unauthorized",
                Detail = exception.Message,
            });
        }
    }
    
    [HttpPost("google")]
    public async Task<ActionResult<AuthResponseDto>> GoogleLogin(
        [FromBody] GoogleLoginRequestDto dto,
        CancellationToken cancellationToken)
    {
        try
        {
            var result = await _authService.GoogleLoginAsync(dto, cancellationToken);
            return Ok(result);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new ProblemDetails { Title = "Validation error", Detail = ex.Message });
        }
        catch (UnauthorizedAccessException ex)
        {
            return Unauthorized(new ProblemDetails { Title = "Unauthorized", Detail = ex.Message });
        }
    }
}
