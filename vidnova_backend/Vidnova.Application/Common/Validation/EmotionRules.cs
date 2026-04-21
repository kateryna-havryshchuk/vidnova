using Vidnova.Domain.Entities;

namespace Vidnova.Application.Common.Validation;

public static class EmotionRules
{
    private static readonly IReadOnlyDictionary<EmotionType, EmotionType[]> Incompatible =
        new Dictionary<EmotionType, EmotionType[]>
        {
            [EmotionType.Calm] = new[]
            {
                EmotionType.Sadness,
                EmotionType.Anxiety,
                EmotionType.Anger,
                EmotionType.Guilt,
                EmotionType.Shame,
                EmotionType.Fear,
                EmotionType.Disgust,
                EmotionType.Stress
            },
            [EmotionType.Joy] = new[]
            {
                EmotionType.Sadness,
                EmotionType.Anxiety,
                EmotionType.Anger,
                EmotionType.Guilt,
                EmotionType.Shame,
                EmotionType.Fear,
                EmotionType.Disgust,
                EmotionType.Stress
            },

            [EmotionType.Sadness] = new[] { EmotionType.Calm, EmotionType.Joy },
            [EmotionType.Anxiety] = new[] { EmotionType.Calm, EmotionType.Joy },
            [EmotionType.Anger] = new[] { EmotionType.Calm, EmotionType.Joy },
            [EmotionType.Guilt] = new[] { EmotionType.Calm, EmotionType.Joy },
            [EmotionType.Shame] = new[] { EmotionType.Calm, EmotionType.Joy },
            [EmotionType.Fear] = new[] { EmotionType.Calm, EmotionType.Joy },
            [EmotionType.Disgust] = new[] { EmotionType.Calm, EmotionType.Joy },
            [EmotionType.Stress] = new[] { EmotionType.Calm, EmotionType.Joy },
        };

    public static void ValidateEmotionList<T>(
        IReadOnlyList<T> emotions,
        Func<T, EmotionType> getEmotion,
        Func<T, int> getIntensity,
        int maxCount = 20)
    {
        if (emotions is null) throw new ArgumentException("Emotions is required.");
        if (emotions.Count == 0) throw new ArgumentException("At least one emotion is required.");
        if (emotions.Count > maxCount) throw new ArgumentException($"Too many emotions selected (max {maxCount}).");

        var duplicate = emotions
            .GroupBy(getEmotion)
            .FirstOrDefault(g => g.Count() > 1);

        if (duplicate != null)
            throw new ArgumentException($"Emotion '{duplicate.Key}' selected multiple times.");

        foreach (var e in emotions)
        {
            var intensity = getIntensity(e);
            if (intensity < 0 || intensity > 100)
                throw new ArgumentException($"Intensity for '{getEmotion(e)}' must be between 0 and 100.");
        }

        ValidateCompatibility(emotions.Select(getEmotion));
    }

    private static void ValidateCompatibility(IEnumerable<EmotionType> emotions)
    {
        var selected = emotions.ToHashSet();

        foreach (var emotion in selected)
        {
            if (!Incompatible.TryGetValue(emotion, out var conflicts)) continue;

            foreach (var conflict in conflicts)
            {
                if (selected.Contains(conflict))
                    throw new ArgumentException($"Emotions conflict: '{emotion}' cannot be combined with '{conflict}'.");
            }
        }
    }
}