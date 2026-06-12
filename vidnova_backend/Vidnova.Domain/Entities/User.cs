using Vidnova.Domain.Common;

namespace Vidnova.Domain.Entities;

public class User : BaseEntity
{
    public string Email { get; set; } = string.Empty;
    public string? PasswordHash { get; set; }

    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string Username { get; set; } = string.Empty;

    public string? GoogleSubject { get; set; }
    public bool EmailVerified { get; set; }
}