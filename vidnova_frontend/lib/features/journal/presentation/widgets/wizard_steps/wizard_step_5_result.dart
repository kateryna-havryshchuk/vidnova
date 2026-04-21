import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/score_color_scale.dart';
import '../../bloc/journal_bloc.dart';
import '../../bloc/journal_event.dart';
import '../../bloc/journal_state.dart';
import '../emotion_slider.dart';

class WizardStep5Result extends StatelessWidget {
  final TextEditingController situationController;
  final TextEditingController thoughtController;
  final TextEditingController alternativeController;

  const WizardStep5Result({
    super.key,
    required this.situationController,
    required this.thoughtController,
    required this.alternativeController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalBloc, JournalState>(
      builder: (context, state) {
        final isPositiveFlow = state.draftEntry.emotions.isNotEmpty &&
            state.draftEntry.emotions.every((e) => e == 'Calm' || e == 'Joy');

        final before = _initialCalm(state).round().clamp(0, 100);
        final after = state.draftEntry.finalEmotionIntensity.clamp(0, 100);
        final beforeColor = ScoreColorScale.discrete(before);
        final afterColor = ScoreColorScale.smooth(after);

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPositiveFlow ? 'Результат' : 'Після переосмислення',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isPositiveFlow
                    ? 'Порівняймо ваш стан: на початку та зараз.'
                    : 'Порівняймо, як змінився ваш стан: на початку та зараз.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 32),
              
              Container(
                padding: const EdgeInsets.all(20),
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'На початку:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: beforeColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$before%',
                            style: TextStyle(fontWeight: FontWeight.bold, color: beforeColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Зараз:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: afterColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$after%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: afterColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              EmotionSlider(
                value: after.toDouble(),
                label: 'Оцініть ваш стан зараз',
                onChanged: (value) {
                  context.read<JournalBloc>().add(UpdateFinalIntensityEvent(value.round()));
                },
                color: afterColor,
              ),
              
              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.isSaving ||
                          state.draftEntry.situation.trim().isEmpty ||
                          state.draftEntry.emotions.isEmpty
                      ? null
                      : () {
                          context.read<JournalBloc>().add(UpdateSituationEvent(situationController.text));
                          context.read<JournalBloc>().add(UpdateAutomaticThoughtEvent(thoughtController.text));
                          context.read<JournalBloc>().add(UpdateAlternativeThoughtEvent(alternativeController.text));
                          context.read<JournalBloc>().add(SaveAbcEntryEvent());
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: state.isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Зберегти запис',
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

  double _initialCalm(JournalState state) {
    final emotions = state.draftEntry.emotions;
    if (emotions.isEmpty) return 0;

    final vals = emotions.map((e) => state.draftEntry.initialIntensityByEmotion[e] ?? 0).toList();
    final sum = vals.fold<int>(0, (a, b) => a + b);
    final avgIntensity = sum / vals.length;

    final isPositiveFlow = emotions.every((e) => e == 'Calm' || e == 'Joy');
    if (isPositiveFlow) {
      // Для позитивних емоцій інтенсивність = "стан" (не інвертуємо).
      return avgIntensity;
    }

    // Для негативних емоцій інтенсивність = "негативність", тому інвертуємо у "стан".
    return 100 - avgIntensity;
  }
}