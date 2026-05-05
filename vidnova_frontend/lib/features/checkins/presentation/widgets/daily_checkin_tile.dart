import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/score_color_scale.dart';
import '../../data/models/checkin_models.dart';

class EmotionUi {
  static const List<String> all = <String>[
    'Sadness',
    'Anxiety',
    'Anger',
    'Joy',
    'Guilt',
    'Shame',
    'Fear',
    'Disgust',
    'Calm',
    'Stress',
  ];

  static const Map<String, String> emoji = <String, String>{
    'Sadness': '😢',
    'Anxiety': '😰',
    'Anger': '😡',
    'Joy': '😄',
    'Guilt': '😔',
    'Shame': '😳',
    'Fear': '😨',
    'Disgust': '🤢',
    'Calm': '😌',
    'Stress': '😫',
  };

  static const Map<String, IconData> icon = <String, IconData>{
    'Sadness': Icons.sentiment_dissatisfied,
    'Anxiety': Icons.psychology_alt,
    'Anger': Icons.local_fire_department,
    'Joy': Icons.sentiment_satisfied,
    'Guilt': Icons.report_gmailerrorred,
    'Shame': Icons.visibility_off,
    'Fear': Icons.warning_amber,
    'Disgust': Icons.sick,
    'Calm': Icons.spa,
    'Stress': Icons.bolt,
  };

  static const Map<String, Set<String>> incompatible = <String, Set<String>>{
    // Rule: Calm/Joy are "positive" and cannot be mixed with any other emotions.
    // Calm and Joy can be selected together.
    'Calm': {'Sadness', 'Anxiety', 'Anger', 'Guilt', 'Shame', 'Fear', 'Disgust', 'Stress'},
    'Joy': {'Sadness', 'Anxiety', 'Anger', 'Guilt', 'Shame', 'Fear', 'Disgust', 'Stress'},

    // Keep the rule symmetric so the order of selection doesn't matter.
    'Sadness': {'Calm', 'Joy'},
    'Anxiety': {'Calm', 'Joy'},
    'Anger': {'Calm', 'Joy'},
    'Guilt': {'Calm', 'Joy'},
    'Shame': {'Calm', 'Joy'},
    'Fear': {'Calm', 'Joy'},
    'Disgust': {'Calm', 'Joy'},
    'Stress': {'Calm', 'Joy'},
  };

  static String title(String emotion) {
    switch (emotion) {
      case 'Sadness':
        return 'Смуток';
      case 'Anxiety':
        return 'Тривога';
      case 'Anger':
        return 'Злість';
      case 'Joy':
        return 'Радість';
      case 'Guilt':
        return 'Провина';
      case 'Shame':
        return 'Сором';
      case 'Fear':
        return 'Страх';
      case 'Disgust':
        return 'Огида';
      case 'Calm':
        return 'Спокій';
      case 'Stress':
        return 'Стрес';
      default:
        return emotion;
    }
  }
}

class DailyCheckInTile extends StatelessWidget {
  final DailyCheckInResponseDto? checkIn;
  final bool isLoading;
  final String? error;
  final VoidCallback onTap;

  const DailyCheckInTile({
    super.key,
    required this.checkIn,
    required this.isLoading,
    required this.error,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final borderRadius = BorderRadius.circular(24);
    final score = checkIn?.calmScore;
    final scoreColor = score == null ? null : _scoreColor(score);
    final scoreLabel = score == null ? null : _scoreLabel(score);

    return Material(
      type: MaterialType.transparency,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.secondary],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final showScore = !isLoading && error == null && score != null;
                    final scorePill = showScore
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(38),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: Colors.white.withAlpha(60)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: scoreColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$score/100',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                  ),
                                ),
                                if (scoreLabel != null) const SizedBox(width: 6),
                                if (scoreLabel != null)
                                  Text(
                                    scoreLabel,
                                    style: TextStyle(
                                      color: Colors.white.withAlpha(230),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : null;

                    final trailing = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (scorePill != null) scorePill,
                        if (scorePill != null) const SizedBox(width: 10),
                        const Icon(Icons.chevron_right, color: Colors.white),
                      ],
                    );

                    return Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Щоденний стан',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: trailing,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                    ),
                  )
                else if (error != null)
                  Text(
                    error!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  )
                else if (checkIn == null)
                  Text(
                    'Додайте короткий опис та емоції — це займе 1 хвилину.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _buildSubtitle(checkIn!),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: (score!.clamp(0, 100)) / 100.0,
                          backgroundColor: Colors.white.withAlpha(38),
                          valueColor: AlwaysStoppedAnimation<Color>(scoreColor!),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _scoreColor(int score) {
    return ScoreColorScale.discrete(score);
  }

  String _scoreLabel(int score) {
    if (score >= 70) return 'Добре';
    if (score >= 40) return 'Ок';
    return 'Важко';
  }

  String _buildSubtitle(DailyCheckInResponseDto dto) {
    if (dto.emotions.isEmpty) return 'Загальний стан: ${dto.calmScore}/100';

    final sorted = [...dto.emotions]..sort((a, b) => b.intensity.compareTo(a.intensity));
    final top = sorted.first;
    return '${EmotionUi.title(top.emotion)} · ${top.intensity}/100  •  Загальний стан ${dto.calmScore}/100';
  }
}
