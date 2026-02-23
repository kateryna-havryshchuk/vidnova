import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../bloc/journal_bloc.dart';
import '../../bloc/journal_event.dart';
import '../../bloc/journal_state.dart';
import '../evidence_card.dart';

class WizardStep3Evidence extends StatelessWidget {
  final TextEditingController evidenceController;

  const WizardStep3Evidence({
    super.key,
    required this.evidenceController,
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
                'Докази',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Давайте розглянемо факти "за" і "проти" вашої думки',
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
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: evidenceController,
                        decoration: const InputDecoration(
                          hintText: 'Додайте доказ...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: AppColors.primary),
                      onPressed: () {
                        if (evidenceController.text.isNotEmpty) {
                          context.read<JournalBloc>().add(
                            AddTempEvidenceEvent(evidenceController.text),
                          );
                          evidenceController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Тимчасові докази для перетягування
              if (state.tempEvidenceList.isNotEmpty) ...[
                const Text(
                  'Перетягніть докази в відповідні категорії:',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ...state.tempEvidenceList.map(
                  (evidence) => DraggableEvidenceCard(
                    text: evidence,
                    onTap: () {
                      context.read<JournalBloc>().add(
                        RemoveTempEvidenceEvent(evidence),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              Expanded(
                child: Row(
                  children: [
                    // Зона "За"
                    Expanded(
                      child: _buildEvidenceZone(
                        context,
                        state,
                        title: 'ЗА думку',
                        color: AppColors.emotionNegative,
                        evidenceList: state.draftEntry.evidenceFor,
                        isForEvidence: true,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Зона "Проти"
                    Expanded(
                      child: _buildEvidenceZone(
                        context,
                        state,
                        title: 'ПРОТИ думку',
                        color: AppColors.emotionPositive,
                        evidenceList: state.draftEntry.evidenceAgainst,
                        isForEvidence: false,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.read<JournalBloc>().add(NextStepEvent()),
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

  Widget _buildEvidenceZone(
    BuildContext context,
    JournalState state, {
    required String title,
    required Color color,
    required List<dynamic> evidenceList,
    required bool isForEvidence,
  }) {
    return DragTarget<String>(
      onAcceptWithDetails: (details) {
        final evidence = details.data;
        context.read<JournalBloc>().add(
          RemoveTempEvidenceEvent(evidence),
        );
        
        if (isForEvidence) {
          context.read<JournalBloc>().add(AddEvidenceForEvent(evidence));
        } else {
          context.read<JournalBloc>().add(AddEvidenceAgainstEvent(evidence));
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        
        return Container(
          height: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isHighlighted 
              ? color.withAlpha(77) 
              : color.withAlpha(26),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color,
              width: isHighlighted ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: evidenceList.length,
                  itemBuilder: (context, index) {
                    final evidence = evidenceList[index];
                    return EvidenceCard(
                      evidence: evidence,
                      onDelete: () {
                        context.read<JournalBloc>().add(
                          RemoveEvidenceEvent(evidence.id),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}