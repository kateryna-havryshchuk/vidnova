using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Vidnova.Domain.Entities.Journal.Abc;

namespace Vidnova.Infrastructure.Persistence.Configuration;

public sealed class AbcEvidenceConfiguration : IEntityTypeConfiguration<AbcEvidence>
{
    public void Configure(EntityTypeBuilder<AbcEvidence> builder)
    {
        builder.ToTable("AbcEvidence");
        builder.HasKey(x => x.Id);

        builder.Property(x => x.IsFor).IsRequired();
        builder.Property(x => x.Text).IsRequired().HasMaxLength(1000);

        builder.HasIndex(x => x.AbcEntryId);
    }
}