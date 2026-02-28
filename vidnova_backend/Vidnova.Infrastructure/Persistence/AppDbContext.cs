using Microsoft.EntityFrameworkCore;
using Vidnova.Application.Common.Interfaces;

namespace Vidnova.Infrastructure.Persistence;

public class AppDbContext: DbContext, IAppDbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }
}