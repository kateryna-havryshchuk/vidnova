using Vidnova.Domain.Entities;
namespace Vidnova.Application.Common.Interfaces;

public interface IJwtTokenGenerator
{
    (string AccessToken, DateTime ExpiresAtUtc) GenerateAccessToken(User user);
}