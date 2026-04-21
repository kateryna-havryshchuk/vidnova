using Vidnova.Domain.Common;

namespace Vidnova.Domain.Entities;

public class DailyCheckInAiInsight : BaseEntity
{
    public Guid UserId { get; set; }
    public DateOnly Date { get; set; }

    public Guid DailyCheckInId { get; set; }

    public DateTime SourceUpdatedAtUtc { get; set; }

    public string Model { get; set; } = string.Empty;

    public string PromptText { get; set; } = string.Empty;

    public string ResponseText { get; set; } = string.Empty;
}
