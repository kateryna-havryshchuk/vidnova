import '../../data/models/abc_entry_model.dart';

class JournalState {
  final int currentStep;
  final AbcEntryModel draftEntry;
  final bool isAiAnalyzing;
  final String? aiSuggestion;
  final List<String> tempEvidenceList;

  JournalState({
    this.currentStep = 0,
    required this.draftEntry,
    this.isAiAnalyzing = false,
    this.aiSuggestion,
    this.tempEvidenceList = const [],
  });

  JournalState copyWith({
    int? currentStep,
    AbcEntryModel? draftEntry,
    bool? isAiAnalyzing,
    String? aiSuggestion,
    List<String>? tempEvidenceList,
  }) {
    return JournalState(
      currentStep: currentStep ?? this.currentStep,
      draftEntry: draftEntry ?? this.draftEntry,
      isAiAnalyzing: isAiAnalyzing ?? this.isAiAnalyzing,
      aiSuggestion: aiSuggestion,
      tempEvidenceList: tempEvidenceList ?? this.tempEvidenceList,
    );
  }
}