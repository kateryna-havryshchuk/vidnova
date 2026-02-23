import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../bloc/journal_bloc.dart';
import '../../bloc/journal_event.dart';
import '../../bloc/journal_state.dart';
import '../emotion_slider.dart';
import '../ai_components/ai_thinking_indicator.dart';
import '../ai_components/ai_suggestion_card.dart';

class WizardStep2Thoughts extends StatelessWidget {
  final TextEditingController thoughtController;

  const WizardStep2Thoughts({
    super.key,
    required this.thoughtController,
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
                'Ловець думок',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Що промайнуло у вас в голові безпосередньо перед цими почуттями?',
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
                  controller: thoughtController,
                  decoration: const InputDecoration(
                    hintText: 'Наприклад: "Я завжди все псую" або "Ніхто мене не поважає"',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  maxLines: 3,
                  onChanged: (text) {
                    if (text.trim().split(' ').length > 3) {
                      context.read<JournalBloc>().add(AnalyzeThoughtEvent(text));
                    }
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              if (state.isAiAnalyzing)
                const AiThinkingIndicator(),
              
              if (state.aiSuggestion != null && !state.isAiAnalyzing)
                AiSuggestionCard(
                  suggestion: state.aiSuggestion!,
                  onDismiss: () {
                    context.read<JournalBloc>().add(DismissAiSuggestionEvent());
                  },
                ),
              
              const SizedBox(height: 24),
              
              EmotionSlider(
                value: state.draftEntry.thoughtBelief,
                label: 'Наскільки ви вірите цим думкам?',
                onChanged: (value) {
                  context.read<JournalBloc>().add(UpdateThoughtBeliefEvent(value));
                },
                color: AppColors.emotionNegative,
              ),
              
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: thoughtController.text.isNotEmpty
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