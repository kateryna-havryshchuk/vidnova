import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../bloc/journal_bloc.dart';
import '../../bloc/journal_event.dart';
import '../../bloc/journal_state.dart';
import '../emotion_slider.dart';

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
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Що трапилося?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Опишіть подію або ситуацію, що вас засмутила',
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
                    hintText: 'Наприклад: "Мій колега не відповів на повідомлення..."',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  maxLines: 4,
                  style: const TextStyle(fontSize: 16),
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
              const SizedBox(height: 16),
              Wrap(
                spacing: 12.0,
                runSpacing: 8.0,
                children: ['Сум', 'Тривога', 'Злість', 'Розчарування', 'Страх', 'Сором']
                    .map((emotion) => FilterChip(
                          label: Text(emotion),
                          selected: state.draftEntry.emotion == emotion,
                          onSelected: (selected) {
                            if (selected) {
                              context.read<JournalBloc>().add(UpdateEmotionEvent(emotion));
                            }
                          },
                          selectedColor: AppColors.primary.withAlpha(51),
                          checkmarkColor: AppColors.primary,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              
              if (state.draftEntry.emotion.isNotEmpty)
                EmotionSlider(
                  value: state.draftEntry.initialEmotionIntensity,
                  label: 'Наскільки сильно ви це відчуваєте?',
                  onChanged: (value) {
                    context.read<JournalBloc>().add(UpdateIntensityEvent(value));
                  },
                ),
              
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: situationController.text.isNotEmpty && state.draftEntry.emotion.isNotEmpty
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
}