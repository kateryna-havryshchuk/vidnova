import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/abc_entry_model.dart';
import 'journal_event.dart';
import 'journal_state.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  JournalBloc() : super(JournalState(draftEntry: AbcEntryModel())) {
    
    on<NextStepEvent>((event, emit) {
      if (state.currentStep < 4) {
        emit(state.copyWith(currentStep: state.currentStep + 1));
      }
    });

    on<PrevStepEvent>((event, emit) {
      if (state.currentStep > 0) {
        emit(state.copyWith(currentStep: state.currentStep - 1));
      }
    });

    on<UpdateEmotionEvent>((event, emit) {
      final updatedEntry = state.draftEntry.copyWith(emotion: event.emotion);
      emit(state.copyWith(draftEntry: updatedEntry));
    });

    on<UpdateIntensityEvent>((event, emit) {
      final updatedEntry = state.draftEntry.copyWith(
        initialEmotionIntensity: event.intensity,
      );
      emit(state.copyWith(draftEntry: updatedEntry));
    });

    on<UpdateThoughtBeliefEvent>((event, emit) {
      final updatedEntry = state.draftEntry.copyWith(thoughtBelief: event.belief);
      emit(state.copyWith(draftEntry: updatedEntry));
    });

    on<UpdateAlternativeBeliefEvent>((event, emit) {
      final updatedEntry = state.draftEntry.copyWith(
        alternativeThoughtBelief: event.belief,
      );
      emit(state.copyWith(draftEntry: updatedEntry));
    });

    on<UpdateFinalIntensityEvent>((event, emit) {
      final updatedEntry = state.draftEntry.copyWith(
        finalEmotionIntensity: event.intensity,
      );
      emit(state.copyWith(draftEntry: updatedEntry));
    });

    on<AddTempEvidenceEvent>((event, emit) {
      if (event.evidence.isNotEmpty) {
        final updatedList = List<String>.from(state.tempEvidenceList)
          ..add(event.evidence);
        emit(state.copyWith(tempEvidenceList: updatedList));
      }
    });

    on<RemoveTempEvidenceEvent>((event, emit) {
      final updatedList = state.tempEvidenceList
          .where((e) => e != event.evidence)
          .toList();
      emit(state.copyWith(tempEvidenceList: updatedList));
    });

    on<AddEvidenceForEvent>((event, emit) {
      final newEvidence = Evidence(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: event.evidence,
        isFor: true,
      );
      final updatedList = List<Evidence>.from(state.draftEntry.evidenceFor)
        ..add(newEvidence);
      final updatedEntry = state.draftEntry.copyWith(evidenceFor: updatedList);
      emit(state.copyWith(draftEntry: updatedEntry));
    });

    on<AddEvidenceAgainstEvent>((event, emit) {
      final newEvidence = Evidence(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: event.evidence,
        isFor: false,
      );
      final updatedList = List<Evidence>.from(state.draftEntry.evidenceAgainst)
        ..add(newEvidence);
      final updatedEntry = state.draftEntry.copyWith(evidenceAgainst: updatedList);
      emit(state.copyWith(draftEntry: updatedEntry));
    });

    on<RemoveEvidenceEvent>((event, emit) {
      final updatedFor = state.draftEntry.evidenceFor
          .where((e) => e.id != event.evidenceId)
          .toList();
      final updatedAgainst = state.draftEntry.evidenceAgainst
          .where((e) => e.id != event.evidenceId)
          .toList();
      
      final updatedEntry = state.draftEntry.copyWith(
        evidenceFor: updatedFor,
        evidenceAgainst: updatedAgainst,
      );
      emit(state.copyWith(draftEntry: updatedEntry));
    });

    on<AnalyzeThoughtEvent>((event, emit) async {
      emit(state.copyWith(isAiAnalyzing: true));
      
      await Future.delayed(const Duration(seconds: 2));
      
      String? suggestion;
      if (event.thought.toLowerCase().contains('завжди')) {
        suggestion = "Схоже на хибне узагальнення. Ви впевнені, що так відбувається завжди?";
      } else if (event.thought.toLowerCase().contains('ніколи')) {
        suggestion = "Це категоричне твердження. Чи дійсно такого ніколи не було?";
      } else if (event.thought.toLowerCase().contains('все псую')) {
        suggestion = "Це звучить як катастрофізація. Можливо, варто розглянути ситуацію менш критично?";
      }
      
      emit(state.copyWith(isAiAnalyzing: false, aiSuggestion: suggestion));
    });

    on<DismissAiSuggestionEvent>((event, emit) {
      emit(state.copyWith(aiSuggestion: null));
    });

    on<SaveEntryEvent>((event, emit) async {
      final updatedEntry = state.draftEntry.copyWith(
        situation: event.situation,
        automaticThought: event.thought,
        alternativeThought: event.alternativeThought,
      );
      
      // TODO: Save to repository/API
      
      emit(state.copyWith(draftEntry: updatedEntry));
    });
  }
}