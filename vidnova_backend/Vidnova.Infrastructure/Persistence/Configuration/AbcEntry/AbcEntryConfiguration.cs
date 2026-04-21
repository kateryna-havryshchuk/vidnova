using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Vidnova.Domain.Entities.Journal.Abc;

namespace Vidnova.Infrastructure.Persistence.Configuration;

public sealed class AbcEntryConfiguration : IEntityTypeConfiguration<AbcEntry>
{
    public void Configure(EntityTypeBuilder<AbcEntry> builder)
    {
        builder.ToTable("AbcEntries");
        builder.HasKey(x => x.Id);

        builder.Property(x => x.UserId).IsRequired();

        builder.Property(x => x.Situation).IsRequired().HasMaxLength(2000);

        builder.Property(x => x.AutomaticThought).IsRequired().HasMaxLength(2000);
        builder.Property(x => x.ThoughtBelief).IsRequired();

        builder.Property(x => x.AlternativeThought).IsRequired().HasMaxLength(2000);
        builder.Property(x => x.AlternativeThoughtBelief).IsRequired();

        builder.Property(x => x.FinalEmotionIntensity).IsRequired();

        builder.HasIndex(x => new { x.UserId, x.CreatedDate });

        builder.HasMany(x => x.Emotions)
            .WithOne(x => x.AbcEntry!)
            .HasForeignKey(x => x.AbcEntryId)
            .IsRequired()
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(x => x.Evidence)
            .WithOne(x => x.AbcEntry!)
            .HasForeignKey(x => x.AbcEntryId)
            .IsRequired()
            .OnDelete(DeleteBehavior.Cascade);
    }
}