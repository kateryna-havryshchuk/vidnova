using System.Text;
using Vidnova.Application.Common.Interfaces;
using Vidnova.Application.DTOs.CheckIns;
using Vidnova.Domain.Entities;

namespace Vidnova.Application.Services.CheckIns;

public sealed class DailyCheckInAiInsightService : IDailyCheckInAiInsightService
{
    private readonly IUnitOfWork _uow;
    private readonly IDailyCheckInRepository _checkIns;
    private readonly IDailyCheckInAiInsightRepository _insights;
    private readonly ITextGenerationService _ai;

    public DailyCheckInAiInsightService(
        IUnitOfWork uow,
        IDailyCheckInRepository checkIns,
        IDailyCheckInAiInsightRepository insights,
        ITextGenerationService ai)
    {
        _uow = uow;
        _checkIns = checkIns;
        _insights = insights;
        _ai = ai;
    }

    public async Task<DailyCheckInAiInsightResponseDto> GetOrGenerateAsync(Guid userId, DateOnly date, CancellationToken ct = default)
    {
        var checkIn = await _checkIns.GetByUserAndDateAsync(userId, date, ct);
        if (checkIn is null)
            throw new KeyNotFoundException("Check-in not found for this date.");

        var sourceUpdatedAtUtc = checkIn.UpdatedDate ?? checkIn.CreatedDate;

        var existing = await _insights.GetByUserAndDateAsync(userId, date, ct);
        if (existing is not null &&
            existing.DailyCheckInId == checkIn.Id &&
            existing.SourceUpdatedAtUtc == sourceUpdatedAtUtc &&
            !string.IsNullOrWhiteSpace(existing.ResponseText) &&
            !string.IsNullOrWhiteSpace(existing.PromptText))
        {
            return Map(existing);
        }

        var prompt = BuildPrompt(checkIn);
        var result = await _ai.GenerateAsync(prompt, ct);

        if (existing is null)
        {
            existing = new DailyCheckInAiInsight
            {
                UserId = userId,
                Date = date,
                DailyCheckInId = checkIn.Id,
                SourceUpdatedAtUtc = sourceUpdatedAtUtc,
                Model = result.Model,
                PromptText = prompt,
                ResponseText = result.Text
            };
            _insights.Add(existing);
        }
        else
        {
            existing.UserId = userId;
            existing.Date = date;
            existing.DailyCheckInId = checkIn.Id;
            existing.SourceUpdatedAtUtc = sourceUpdatedAtUtc;
            existing.Model = result.Model;
            existing.PromptText = prompt;
            existing.ResponseText = result.Text;
        }

        try
        {
            await _uow.SaveChangesAsync(ct);
        }
        catch (Microsoft.EntityFrameworkCore.DbUpdateException)
        {
            // In rare cases multiple requests can try to generate at the same time.
            // Unique index (UserId, Date) will reject duplicates — just return the already stored record.
            var stored = await _insights.GetByUserAndDateAsync(userId, date, ct);
            if (stored is not null) return Map(stored);
            throw;
        }

        return Map(existing);
    }

    private static DailyCheckInAiInsightResponseDto Map(DailyCheckInAiInsight e)
        => new(
            e.Id,
            e.Date,
            e.Model,
            e.SourceUpdatedAtUtc,
            e.PromptText,
            e.ResponseText
        );

    private static string BuildPrompt(DailyCheckIn checkIn)
    {
        var description = (checkIn.Description ?? string.Empty).Trim();
        if (description.Length == 0) description = "(користувач не додав опис)";

        var (emotionUa, intensity) = GetDominantEmotion(checkIn.Emotions);

        var calm = checkIn.CalmScore;

        var sb = new StringBuilder();
        sb.AppendLine("Ти — емпатичний помічник для щоденної підтримки.");
        sb.AppendLine();
        sb.Append("Дані: Користувач описав день так: «")
            .Append(description)
            .AppendLine("». ");
        sb.Append("Його домінуюча емоція: ")
            .Append(emotionUa)
            .Append(" (")
            .Append(intensity.HasValue ? intensity.Value.ToString() : "—")
            .AppendLine("%).");
        sb.Append("Його загальний спокій: ")
            .Append(calm)
            .AppendLine("% зі 100.");
        sb.AppendLine();
        sb.AppendLine("Ти — емпатичний КПТ-помічник Vidnova. Твоє завдання: сформулюй підтримуючу відповідь (до 40 слів) залежно від показника 'Стан' (0-100):");
        sb.AppendLine("1. 0-20 (Критично): Валідація болю + техніка заземлення (напр. 5-4-3-2-1 або дихання 4-6) або щось інше.");
        sb.AppendLine("2. 21-40 (Складно): Порадь дистанціюватися від думок або перевірити їх фактами, також порадь щось приємне(придумай).");
        sb.AppendLine("3. 41-60 (Стабільно): Запропонуй поведінкову активацію (коротка прогулянка, чашка чаю, зміна діяльності) або щось інше.");
        sb.AppendLine("4. 61-80 (Добре): Підкріпи цей ресурсний стан(придумай як це зробити), нагадай про важливість турботи про себе.");
        sb.AppendLine("5. 81-100 (Чудово): Фокус на майстерності — запитай, які саме дії допомогли досягти такого спокою.");
        sb.AppendLine("Стиль: Емпатичний, без критики. Українською. Без медичних діагнозів і без згадок про те, що ти штучний інтелект.");
        sb.AppendLine("Формат: один-два абзаци.");

        return sb.ToString().Trim();
    }

    private static (string EmotionUa, int? Intensity) GetDominantEmotion(List<DailyCheckInEmotion> emotions)
    {
        if (emotions is null || emotions.Count == 0)
            return ("не вказано", null);

        var top = emotions.OrderByDescending(x => x.Intensity).First();
        return (ToUkrainian(top.Emotion), top.Intensity);
    }

    private static string ToUkrainian(EmotionType e) => e switch
    {
        EmotionType.Sadness => "Сум",
        EmotionType.Anxiety => "Тривога",
        EmotionType.Anger => "Злість",
        EmotionType.Joy => "Радість",
        EmotionType.Guilt => "Провина",
        EmotionType.Shame => "Сором",
        EmotionType.Fear => "Страх",
        EmotionType.Disgust => "Відраза",
        EmotionType.Calm => "Спокій",
        EmotionType.Stress => "Стрес",
        _ => e.ToString()
    };
}
