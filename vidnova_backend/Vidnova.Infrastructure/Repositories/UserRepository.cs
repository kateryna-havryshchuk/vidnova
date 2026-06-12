using Microsoft.EntityFrameworkCore;
using Vidnova.Application.Common.Interfaces;
using Vidnova.Infrastructure.Persistence;
using Vidnova.Domain.Entities;

namespace Vidnova.Infrastructure.Repositories;

public sealed class UserRepository : IUserRepository
{
    private readonly AppDbContext _dbContext;
    
    public UserRepository(AppDbContext dbContext) => _dbContext = dbContext;
    
    public void Add(User entity) => _dbContext.Users.Add(entity);
    public void Remove(User entity) => _dbContext.Users.Remove(entity);

    public Task<bool> EmailExistsAsync(string email, CancellationToken ct = default)
        => _dbContext.Users.AnyAsync(x => x.Email == email, ct);
    
    public Task<bool> UsernameExistsAsync(string username, CancellationToken ct = default)
        => _dbContext.Users.AnyAsync(x => x.Username == username, ct);
    
    public Task<User?> FindByLoginAsync(string login, CancellationToken ct = default)
        =>  _dbContext.Users.FirstOrDefaultAsync(x => x.Email == login || x.Username == login, ct);
    
    public Task<User?> GetByIdAsync(Guid id, CancellationToken ct = default)
        => _dbContext.Users.FirstOrDefaultAsync(x => x.Id == id, ct);
    
    public Task<User?> FindByEmailAsync(string email, CancellationToken ct = default)
        => _dbContext.Users.FirstOrDefaultAsync(x => x.Email == email, ct);

    public Task<User?> FindByGoogleSubjectAsync(string googleSubject, CancellationToken ct = default)
        => _dbContext.Users.FirstOrDefaultAsync(x => x.GoogleSubject == googleSubject, ct);
}