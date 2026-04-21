using Microsoft.EntityFrameworkCore;
using Vidnova.Application.Common.Interfaces;

namespace Vidnova.Infrastructure.Persistence;

public sealed class EfUnitOfWork: IUnitOfWork
{
    private readonly AppDbContext _dbContext;
    
    public EfUnitOfWork(AppDbContext dbContext)
    {
        _dbContext = dbContext;
    }
    
    public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        => _dbContext.SaveChangesAsync(cancellationToken);
}