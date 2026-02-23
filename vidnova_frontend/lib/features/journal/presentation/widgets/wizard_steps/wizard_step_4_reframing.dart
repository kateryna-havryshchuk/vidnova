import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../bloc/journal_bloc.dart';
import '../../bloc/journal_event.dart';
import '../../bloc/journal_state.dart';
import '../emotion_slider.dart';
import '../evidence_card.dart';

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
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Новий погляд',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Базуючись на доказах "проти", сформулюйте більш збалансовану думку',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 24),
              
              if (state.draftEntry.evidenceAgainst.isNotEmpty) ...[
                const Text(
                  'Ваші докази проти:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.emotionPositive,
                  ),
                ),
                const SizedBox(height: 12),
                ...state.draftEntry.evidenceAgainst
                    .map((evidence) => EvidenceCard(
                          evidence: evidence,
                          onDelete: () {},
                        )),
                const SizedBox(height: 24),
              ],
              
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
                  decoration: const InputDecoration(
                    hintText: 'Після проведеного аналізу зараз я думаю...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  maxLines: 4,
                ),
              ),
              
              const SizedBox(height: 24),
              
              EmotionSlider(
                value: state.draftEntry.alternativeThoughtBelief,
                label: 'Наскільки ви вірите у цю нову думку?',
                onChanged: (value) {
                  context.read<JournalBloc>().add(UpdateAlternativeBeliefEvent(value));
                },
                color: AppColors.emotionPositive,
              ),
              
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: alternativeController.text.isNotEmpty
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