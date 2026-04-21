import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/score_color_scale.dart';
import '../../../checkins/data/models/checkin_models.dart';
import '../../../checkins/presentation/widgets/daily_checkin_tile.dart' show EmotionUi;

class HomeTodayInsightCard extends StatelessWidget {
  final DailyCheckInResponseDto? dto;
  final bool hasError;
  final String? aiText;
  final bool isAiLoading;
  final bool aiHasError;

  const HomeTodayInsightCard({
    super.key,
    required this.dto,
    required this.hasError,
    required this.aiText,
    required this.isAiLoading,
    required this.aiHasError,
  });

  Color _scoreColor(int score) {
    return ScoreColorScale.discrete(score);
  }

  bool _isAiTextShown() {
    return !hasError &&
        dto != null &&
        !isAiLoading &&
        !aiHasError &&
        aiText != null &&
        aiText!.trim().isNotEmpty;
  }

  String _fallbackText(int score) {
    if (score >= 75) {
      return 'Схоже, ви в ресурсі. Зафіксуйте, що сьогодні підтримало вас.';
    } else if (score >= 55) {
      return 'Загалом стабільно. Маленька пауза або прогулянка можуть підсилити стан.';
    } else if (score >= 35) {
      return 'Є напруга. Спробуйте 1–2 хвилини повільного дихання або короткий відпочинок.';
    }
    return 'Схоже, зараз важко. Підтримайте себе: вода, їжа, сон і розмова з близькою людиною можуть допомогти.';
  }

  String _homeInsightText() {
    if (hasError) {
      return 'Не вдалося завантажити дані. Потягніть вниз, щоб спробувати ще раз.';
    }

    if (dto == null) {
      return 'Зробіть короткий чек-ін: оберіть емоції та оцініть загальний стан.';
    }

    final score = dto!.calmScore;

    if (isAiLoading) {
      return 'Генерую підтримку…';
    }

    final base = (aiHasError || (aiText == null) || aiText!.trim().isEmpty)
        ? _fallbackText(score)
        : aiText!.trim();

    final hasEmotions = dto!.emotions.isNotEmpty;

    String? topEmotion;
    int? topIntensity;
    if (hasEmotions) {
      final sorted = [...dto!.emotions]..sort((a, b) => b.intensity.compareTo(a.intensity));
      topEmotion = EmotionUi.title(sorted.first.emotion);
      topIntensity = sorted.first.intensity;
    }

    if (topEmotion == null || topIntensity == null) return base;
    return '$base\n\nДомінує: $topEmotion ($topIntensity/100).';
  }

  @override
  Widget build(BuildContext context) {
    final score = dto?.calmScore;
    final aiShown = _isAiTextShown();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Сьогодні',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (aiShown) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome_outlined, size: 14, color: AppColors.textSecondary),
                          SizedBox(width: 4),
                          Text(
                            'AI',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              if (score != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _scoreColor(score),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$score/100',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _homeInsightText(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
