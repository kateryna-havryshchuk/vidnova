using Vidnova.Application.Common.Interfaces;

namespace Vidnova.Infrastructure.Security;

public sealed class BCryptPasswordHasher: IPasswordHasher
{
    public string HashPassword(string password)
        => BCrypt.Net.BCrypt.HashPassword(password);
    
    public bool  VerifyHashedPassword(string providedPassword, string hashedPassword)
        => BCrypt.Net.BCrypt.Verify(providedPassword, hashedPassword);
}