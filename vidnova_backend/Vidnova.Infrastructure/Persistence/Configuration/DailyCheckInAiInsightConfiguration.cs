using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Vidnova.Domain.Entities;

namespace Vidnova.Infrastructure.Persistence.Configuration;

public sealed class DailyCheckInAiInsightConfiguration : IEntityTypeConfiguration<DailyCheckInAiInsight>
{
    public void Configure(EntityTypeBuilder<DailyCheckInAiInsight> builder)
    {
        builder.ToTable("DailyCheckInAiInsights");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.UserId).IsRequired();

        builder.Property(x => x.Date)
            .HasColumnType("date")
            .IsRequired();

        builder.Property(x => x.DailyCheckInId).IsRequired();

        builder.Property(x => x.SourceUpdatedAtUtc)
            .HasColumnType("datetime2")
            .IsRequired();

        builder.Property(x => x.Model)
            .HasMaxLength(64)
            .IsRequired();

        builder.Property(x => x.PromptText).IsRequired();
        builder.Property(x => x.ResponseText).IsRequired();

        builder.HasIndex(x => new { x.UserId, x.Date }).IsUnique();

        builder.HasOne<DailyCheckIn>()
            .WithMany()
            .HasForeignKey(x => x.DailyCheckInId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
