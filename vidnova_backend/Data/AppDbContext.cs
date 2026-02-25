using Microsoft.EntityFrameworkCore;

namespace Vidnova.Presentation.Api.Data;

public class AppDbContext: DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }
}