using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Vidnova.Domain.Entities.Journal.Abc;

namespace Vidnova.Infrastructure.Persistence.Configuration;

public sealed class AbcEntryEmotionConfiguration : IEntityTypeConfiguration<AbcEntryEmotion>
{
    public void Configure(EntityTypeBuilder<AbcEntryEmotion> builder)
    {
        builder.ToTable("AbcEntryEmotions");
        builder.HasKey(x => x.Id);

        builder.Property(x => x.Emotion).HasConversion<int>().IsRequired();
        builder.Property(x => x.InitialIntensity).IsRequired();

        builder.HasIndex(x => x.AbcEntryId);
    }
}