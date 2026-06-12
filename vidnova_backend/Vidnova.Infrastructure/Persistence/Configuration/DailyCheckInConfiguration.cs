using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Vidnova.Domain.Entities;

namespace Vidnova.Infrastructure.Persistence.Configuration;

public sealed class DailyCheckInConfiguration : IEntityTypeConfiguration<DailyCheckIn>
{
    public void Configure(EntityTypeBuilder<DailyCheckIn> builder)
    {
        builder.ToTable("DailyCheckIns");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.UserId).IsRequired();

        builder.Property(x => x.Date)
            .HasColumnType("date")
            .IsRequired();

        builder.Property(x => x.Description).HasMaxLength(1500);

        builder.Property(x => x.CalmScore).IsRequired();

        builder.HasIndex(x => new { x.UserId, x.Date }).IsUnique();

        builder.HasMany(x => x.Emotions)
            .WithOne(x => x.DailyCheckIn!)
            .HasForeignKey(x => x.DailyCheckInId)
            .IsRequired()
            .OnDelete(DeleteBehavior.Cascade);
    }
}