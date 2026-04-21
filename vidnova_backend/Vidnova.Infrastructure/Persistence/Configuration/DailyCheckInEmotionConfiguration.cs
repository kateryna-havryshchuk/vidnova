using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Vidnova.Domain.Entities;

namespace Vidnova.Infrastructure.Persistence.Configuration;

public sealed class DailyCheckInEmotionConfiguration : IEntityTypeConfiguration<DailyCheckInEmotion>
{
    public void Configure(EntityTypeBuilder<DailyCheckInEmotion> builder)
    {
        builder.ToTable("DailyCheckInEmotions");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Emotion)
            .HasConversion<int>()
            .IsRequired();

        builder.Property(x => x.Intensity).IsRequired();

        builder.HasIndex(x => x.DailyCheckInId);
    }
}