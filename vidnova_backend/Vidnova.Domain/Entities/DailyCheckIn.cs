using Vidnova.Domain.Common;

namespace Vidnova.Domain.Entities;

public class DailyCheckIn: BaseEntity
{
    public Guid UserId { get; set; }
    public DateOnly Date { get; set; }
    public string Description { get; set; } = string.Empty;
    public int CalmScore { get; set; }
    public List<DailyCheckInEmotion> Emotions { get; set; } = new();
}