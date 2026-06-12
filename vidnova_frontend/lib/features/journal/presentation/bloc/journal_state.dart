import '../models/abc_entry_draft.dart';

class JournalState {
  final int currentStep;
  final AbcEntryDraft draftEntry;
  final List<String> evidencePool;
  final List<String> evidenceFor;
  final List<String> evidenceAgainst;
  final bool isLoading;
  final bool isSaving;
  final bool saveSucceeded;
  final String? errorMessage;

  // Потрібно, щоб на кроці 5 ставити дефолт "після" = "на початку" + 1,
  // але не перетирати значення, якщо користувач вже рухав повзунок.
  final bool finalIntensityTouched;

  JournalState({
    this.currentStep = 0,
    required this.draftEntry,
    this.evidencePool = const [],
    this.evidenceFor = const [],
    this.evidenceAgainst = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.saveSucceeded = false,
    this.errorMessage,
    this.finalIntensityTouched = false,
  });

  JournalState copyWith({
    int? currentStep,
    AbcEntryDraft? draftEntry,
    List<String>? evidencePool,
    List<String>? evidenceFor,
    List<String>? evidenceAgainst,
    bool? isLoading,
    bool? isSaving,
    bool? saveSucceeded,
    String? errorMessage,
    bool? finalIntensityTouched,
  }) {
    return JournalState(
      currentStep: currentStep ?? this.currentStep,
      draftEntry: draftEntry ?? this.draftEntry,
      evidencePool: evidencePool ?? this.evidencePool,
      evidenceFor: evidenceFor ?? this.evidenceFor,
      evidenceAgainst: evidenceAgainst ?? this.evidenceAgainst,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      saveSucceeded: saveSucceeded ?? this.saveSucceeded,
      errorMessage: errorMessage,
      finalIntensityTouched: finalIntensityTouched ?? this.finalIntensityTouched,
    );
  }
}