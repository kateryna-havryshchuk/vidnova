import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../bloc/journal_bloc.dart';
import '../../bloc/journal_event.dart';
import '../../bloc/journal_state.dart';
import '../emotion_slider.dart';

class WizardStep4Reframing extends StatelessWidget {
  final TextEditingController alternativeController;

  const WizardStep4Reframing({
    super.key,
    required this.alternativeController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JournalBloc, JournalState>(
      builder: (context, state) {
        final isPositiveFlow = state.draftEntry.emotions.isNotEmpty &&
            state.draftEntry.emotions.every((e) => e == 'Calm' || e == 'Joy');

        final bottomInset = MediaQuery.of(context).viewInsets.bottom;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPositiveFlow ? 'Позитивний досвід' : 'Новий погляд',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isPositiveFlow
                    ? 'Зафіксуйте, що саме допомогло вам це відчути (дії, думки, люди, контекст).'
                    : 'Базуючись на доказах "проти", сформулюйте більш збалансовану думку',
                style: const TextStyle(
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
                  controller: alternativeController,
                  decoration: InputDecoration(
                    hintText: isPositiveFlow
                        ? 'Що допомогло мені відчути спокій/радість...'
                        : 'Після проведеного аналізу зараз я думаю...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 4,
                  onChanged: (text) {
                    context.read<JournalBloc>().add(UpdateAlternativeThoughtEvent(text));
                  },
                ),
              ),

              if (!isPositiveFlow) ...[
                const SizedBox(height: 24),
                EmotionSlider(
                  value: state.draftEntry.alternativeThoughtBelief.toDouble(),
                  label: 'Наскільки ви вірите у цю нову думку?',
                  onChanged: (value) {
                    context.read<JournalBloc>().add(UpdateAlternativeBeliefEvent(value.round()));
                  },
                  color: AppColors.emotionPositive,
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.draftEntry.alternativeThought.trim().isNotEmpty
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