using Vidnova.Domain.Entities;

namespace Vidnova.Application.Common.Interfaces;

public interface IUserRepository: IRepository<User>
{
    Task<bool> EmailExistsAsync(string email, CancellationToken ct = default);
    Task<bool> UsernameExistsAsync(string username, CancellationToken ct = default);
    
    Task<User?> FindByLoginAsync(string login, CancellationToken ct = default);  
    Task<User?> GetByIdAsync(Guid id, CancellationToken ct = default);
    
    Task<User?> FindByEmailAsync(string email, CancellationToken ct = default);
    Task<User?> FindByGoogleSubjectAsync(string googleSubject, CancellationToken ct = default);
}