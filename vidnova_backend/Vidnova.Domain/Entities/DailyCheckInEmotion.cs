using Vidnova.Domain.Common;

namespace Vidnova.Domain.Entities;

public class DailyCheckInEmotion: BaseEntity
{
    public Guid DailyCheckInId { get; set; }
    public DailyCheckIn? DailyCheckIn { get; set; }

    public EmotionType Emotion { get; set; }

    public int Intensity { get; set; }
}