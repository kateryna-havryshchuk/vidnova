import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:twemoji/twemoji.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../checkins/presentation/widgets/daily_checkin_tile.dart' show EmotionUi;
import '../../bloc/journal_bloc.dart';
import '../../bloc/journal_event.dart';
import '../../bloc/journal_state.dart';

class WizardStep1Situation extends StatelessWidget {
  final TextEditingController situationController;

  const WizardStep1Situation({
    super.key,
    required this.situationController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalBloc, JournalState>(
      builder: (context, state) {
        final selected = state.draftEntry.emotions;
        final blocked = _blockedEmotions(selected);

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Яка ситуація?',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Опишіть подію або момент, який ви хочете зафіксувати (може бути як позитивний, так і складний).',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(20),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: situationController,
                          decoration: const InputDecoration(
                            hintText: 'Наприклад: "Я отримав гарні новини..." або "Мій колега не відповів..."',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                          keyboardType: TextInputType.multiline,
                          minLines: 6,
                          maxLines: 10,
                          style: const TextStyle(fontSize: 16),
                          onChanged: (text) {
                            context.read<JournalBloc>().add(UpdateSituationEvent(text));
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      const Text(
                        'Що ви відчули?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Натисніть, щоб вибрати. Несумісні емоції будуть заблоковані.',
                        style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        width: double.infinity,
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
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                for (final emotion in EmotionUi.all)
                                  _emotionCircle(
                                    context,
                                    emotion: emotion,
                                    isSelected: selected.contains(emotion),
                                    isBlocked: blocked.contains(emotion) && !selected.contains(emotion),
                                  ),
                              ],
                            ),
                            if (selected.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Divider(height: 1, color: AppColors.border),
                              const SizedBox(height: 16),
                              const Text(
                                'Інтенсивність',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...selected.map((e) => _intensityRow(context, state, e)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.draftEntry.situation.trim().isNotEmpty && state.draftEntry.emotions.isNotEmpty
                      ? () => context.read<JournalBloc>().add(NextStepEvent())
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Далі',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Set<String> _blockedEmotions(List<String> selected) {
    final blocked = <String>{};
    for (final e in selected) {
      final conflicts = EmotionUi.incompatible[e];
      if (conflicts != null) blocked.addAll(conflicts);
    }
    return blocked;
  }

  Widget _emotionCircle(
    BuildContext context, {
    required String emotion,
    required bool isSelected,
    required bool isBlocked,
  }) {
    final emoji = EmotionUi.emoji[emotion] ?? '🙂';

    final Color bg;
    final Color border;

    if (isBlocked) {
      bg = AppColors.gridLines;
      border = AppColors.border;
    } else if (isSelected) {
      bg = AppColors.primary;
      border = AppColors.primaryBorder;
    } else {
      bg = AppColors.surface;
      border = AppColors.border;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: bg,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: isBlocked ? null : () => context.read<JournalBloc>().add(ToggleEmotionEvent(emotion)),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: border),
              ),
              alignment: Alignment.center,
              child: isBlocked
                  ? Opacity(
                      opacity: 0.45,
                      child: ColorFiltered(
                        colorFilter: const ColorFilter.matrix(_greyscaleMatrix),
                        child: Twemoji(
                          emoji: emoji,
                          height: 28,
                          width: 28,
                          twemojiFormat: TwemojiFormat.png,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  : Twemoji(
                      emoji: emoji,
                      height: 28,
                      width: 28,
                      twemojiFormat: TwemojiFormat.png,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 70,
          child: Text(
            EmotionUi.title(emotion),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: isBlocked ? AppColors.inactive : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _intensityRow(BuildContext context, JournalState state, String emotion) {
    final value = (state.draftEntry.initialIntensityByEmotion[emotion] ?? 0).clamp(0, 100);
    final emoji = EmotionUi.emoji[emotion] ?? '🙂';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Center(
              child: Twemoji(
                emoji: emoji,
                height: 20,
                width: 20,
                twemojiFormat: TwemojiFormat.png,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      EmotionUi.title(emotion),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '$value/100',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: value.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.gridLines,
                  onChanged: (v) => context.read<JournalBloc>().add(
                        UpdateEmotionIntensityEvent(
                          emotion: emotion,
                          intensity: v.round(),
                        ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Same greyscale matrix as in DailyCheckIn.
const List<double> _greyscaleMatrix = <double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0,      0,      0,      1, 0,
];