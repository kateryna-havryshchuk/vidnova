using Microsoft.EntityFrameworkCore;
using Vidnova.Domain.Common;
using Vidnova.Domain.Entities;
using Vidnova.Domain.Entities.Journal.Abc;

namespace Vidnova.Infrastructure.Persistence;

public class AppDbContext: DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }
    public DbSet<User> Users => Set<User>();
    public DbSet<DailyCheckIn> DailyCheckIns => Set<DailyCheckIn>();
    public DbSet<DailyCheckInEmotion> DailyCheckInEmotions => Set<DailyCheckInEmotion>();
    public DbSet<DailyCheckInAiInsight> DailyCheckInAiInsights => Set<DailyCheckInAiInsight>();
    
    public DbSet<AbcEntry> AbcEntries => Set<AbcEntry>();
    public DbSet<AbcEntryEmotion> AbcEntryEmotions => Set<AbcEntryEmotion>();
    public DbSet<AbcEvidence> AbcEvidence => Set<AbcEvidence>();

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        foreach (var entry in ChangeTracker.Entries<BaseEntity>())
        {
            switch (entry.State)
            {
                case EntityState.Added:
                    entry.Entity.CreatedDate = DateTime.UtcNow;
                    break;
                case EntityState.Modified:
                    entry.Entity.UpdatedDate = DateTime.UtcNow;
                    break;
            }
        }
        return base.SaveChangesAsync(cancellationToken);    
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);
    }
}