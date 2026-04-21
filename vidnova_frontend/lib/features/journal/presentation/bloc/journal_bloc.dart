import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../checkins/presentation/widgets/daily_checkin_tile.dart' show EmotionUi;
import '../../data/journal_api.dart';
import '../../data/models/journal_models.dart';
import '../journal_changes.dart';
import 'journal_event.dart';
import 'journal_state.dart';
import '../models/abc_entry_draft.dart';

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  final JournalApi _api;
  final String? _entryId;

  static const Set<String> _positiveEmotions = {'Calm', 'Joy'};

  JournalBloc({required JournalApi api, String? entryId})
      : _api = api,
        _entryId = entryId,
        super(JournalState(draftEntry: AbcEntryDraft.empty())) {
    on<NextStepEvent>((event, emit) {
      final isPositiveFlow = _isPositiveFlow(state.draftEntry);

      if (!isPositiveFlow) {
        if (state.currentStep < 4) {
          // На кроці 5 дефолт: "після" = "на початку" + 1.
          // Ставимо лише якщо користувач ще не рухав повзунок, і це новий запис.
          if (state.currentStep == 3 && state.draftEntry.id == null && !state.finalIntensityTouched) {
            final before = _initialStatePercent(state.draftEntry);
            final seeded = (before + 1).clamp(0, 100);
            emit(state.copyWith(
              currentStep: state.currentStep + 1,
              draftEntry: state.draftEntry.copyWith(finalEmotionIntensity: seeded),
            ));
          } else {
            emit(state.copyWith(currentStep: state.currentStep + 1));
          }
        }
        return;
      }

      // Позитивний флоу: 1 -> 4 -> 5 (пропускаємо 2 і 3).
      final step = state.currentStep;
      if (step == 0) {
        emit(state.copyWith(currentStep: 3));
        return;
      }

      if (step == 1 || step == 2) {
        emit(state.copyWith(currentStep: 3));
        return;
      }

      if (step == 3) {
        var nextDraft = state.draftEntry;

        // На кроці 5 дефолт: "після" = "на початку" + 1.
        // Ставимо лише якщо користувач ще не рухав повзунок, і це новий запис.
        if (nextDraft.id == null && !state.finalIntensityTouched) {
          final before = _initialStatePercent(nextDraft);
          nextDraft = nextDraft.copyWith(finalEmotionIntensity: (before + 1).clamp(0, 100));
        }

        emit(state.copyWith(currentStep: 4, draftEntry: nextDraft));
      }
    });

    on<PrevStepEvent>((event, emit) {
      final isPositiveFlow = _isPositiveFlow(state.draftEntry);

      if (!isPositiveFlow) {
        if (state.currentStep > 0) {
          emit(state.copyWith(currentStep: state.currentStep - 1));
        }
        return;
      }

      // Позитивний флоу: 5 -> 4 -> 1
      final step = state.currentStep;
      if (step == 4) {
        emit(state.copyWith(currentStep: 3));
        return;
      }
      if (step == 3 || step == 2 || step == 1) {
        emit(state.copyWith(currentStep: 0));
      }
    });

    on<LoadAbcEntryEvent>((event, emit) async {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      try {
        final dto = await _api.getAbcById(event.id);

        final evidenceFor = dto.evidenceFor.map((e) => e.text).where((t) => t.trim().isNotEmpty).toList();
        final evidenceAgainst = dto.evidenceAgainst.map((e) => e.text).where((t) => t.trim().isNotEmpty).toList();

        emit(state.copyWith(
          isLoading: false,
          draftEntry: _mapFromResponse(dto),
          evidencePool: const [],
          evidenceFor: evidenceFor,
          evidenceAgainst: evidenceAgainst,
          finalIntensityTouched: true,
        ));
      } catch (_) {
        emit(state.copyWith(isLoading: false, errorMessage: 'Не вдалося завантажити запис'));
      }
    });

    on<UpdateSituationEvent>((event, emit) {
      emit(state.copyWith(draftEntry: state.draftEntry.copyWith(situation: event.text)));
    });

    on<ToggleEmotionEvent>((event, emit) {
      final emotion = event.emotion;
      final current = List<String>.from(state.draftEntry.emotions);
      final intensities = Map<String, int>.from(state.draftEntry.initialIntensityByEmotion);

      if (current.contains(emotion)) {
        current.remove(emotion);
        intensities.remove(emotion);
        emit(state.copyWith(
          draftEntry: state.draftEntry.copyWith(
            emotions: current,
            initialIntensityByEmotion: intensities,
          ),
        ));
        return;
      }

      final incompatible = EmotionUi.incompatible[emotion] ?? const <String>{};
      final hasConflict = current.any((e) {
        final set = EmotionUi.incompatible[e] ?? const <String>{};
        return incompatible.contains(e) || set.contains(emotion);
      });
      if (hasConflict) return;

      current.add(emotion);
      intensities.putIfAbsent(emotion, () => 50);
      emit(state.copyWith(
        draftEntry: state.draftEntry.copyWith(
          emotions: current,
          initialIntensityByEmotion: intensities,
        ),
      ));
    });

    on<UpdateEmotionIntensityEvent>((event, emit) {
      final intensities = Map<String, int>.from(state.draftEntry.initialIntensityByEmotion);
      intensities[event.emotion] = event.intensity.clamp(0, 100);
      emit(state.copyWith(draftEntry: state.draftEntry.copyWith(initialIntensityByEmotion: intensities)));
    });

    on<UpdateAutomaticThoughtEvent>((event, emit) {
      emit(state.copyWith(draftEntry: state.draftEntry.copyWith(automaticThought: event.text)));
    });

    on<UpdateThoughtBeliefEvent>((event, emit) {
      emit(state.copyWith(draftEntry: state.draftEntry.copyWith(thoughtBelief: event.belief.clamp(0, 100))));
    });

    on<AddEvidenceToPoolEvent>((event, emit) {
      final text = event.text.trim();
      if (text.isEmpty) return;

      final pool = List<String>.from(state.evidencePool);
      final forList = List<String>.from(state.evidenceFor);
      final againstList = List<String>.from(state.evidenceAgainst);

      final alreadyExists = pool.contains(text) || forList.contains(text) || againstList.contains(text);
      if (alreadyExists) return;

      pool.insert(0, text);
      emit(state.copyWith(evidencePool: pool));
    });

    on<RemoveEvidenceFromPoolEvent>((event, emit) {
      final pool = List<String>.from(state.evidencePool);
      pool.remove(event.text);
      emit(state.copyWith(evidencePool: pool));
    });

    on<MoveEvidenceToForEvent>((event, emit) {
      final text = event.text.trim();
      if (text.isEmpty) return;

      final pool = List<String>.from(state.evidencePool);
      final forList = List<String>.from(state.evidenceFor);
      final againstList = List<String>.from(state.evidenceAgainst);

      pool.remove(text);
      againstList.remove(text);
      if (!forList.contains(text)) {
        forList.add(text);
      }

      emit(state.copyWith(evidencePool: pool, evidenceFor: forList, evidenceAgainst: againstList));
    });

    on<MoveEvidenceToAgainstEvent>((event, emit) {
      final text = event.text.trim();
      if (text.isEmpty) return;

      final pool = List<String>.from(state.evidencePool);
      final forList = List<String>.from(state.evidenceFor);
      final againstList = List<String>.from(state.evidenceAgainst);

      pool.remove(text);
      forList.remove(text);
      if (!againstList.contains(text)) {
        againstList.add(text);
      }

      emit(state.copyWith(evidencePool: pool, evidenceFor: forList, evidenceAgainst: againstList));
    });

    on<RemoveEvidenceFromForEvent>((event, emit) {
      final text = event.text.trim();
      if (text.isEmpty) return;

      final pool = List<String>.from(state.evidencePool);
      final forList = List<String>.from(state.evidenceFor);
      forList.remove(text);
      if (!pool.contains(text)) {
        pool.insert(0, text);
      }
      emit(state.copyWith(evidencePool: pool, evidenceFor: forList));
    });

    on<RemoveEvidenceFromAgainstEvent>((event, emit) {
      final text = event.text.trim();
      if (text.isEmpty) return;

      final pool = List<String>.from(state.evidencePool);
      final againstList = List<String>.from(state.evidenceAgainst);
      againstList.remove(text);
      if (!pool.contains(text)) {
        pool.insert(0, text);
      }
      emit(state.copyWith(evidencePool: pool, evidenceAgainst: againstList));
    });

    on<UpdateAlternativeThoughtEvent>((event, emit) {
      emit(state.copyWith(draftEntry: state.draftEntry.copyWith(alternativeThought: event.text)));
    });

    on<UpdateAlternativeBeliefEvent>((event, emit) {
      emit(state.copyWith(
        draftEntry: state.draftEntry.copyWith(alternativeThoughtBelief: event.belief.clamp(0, 100)),
      ));
    });

    on<UpdateFinalIntensityEvent>((event, emit) {
      emit(state.copyWith(
        draftEntry: state.draftEntry.copyWith(finalEmotionIntensity: event.intensity.clamp(0, 100)),
        finalIntensityTouched: true,
      ));
    });

    on<SaveAbcEntryEvent>((event, emit) async {
      emit(state.copyWith(isSaving: true, saveSucceeded: false, errorMessage: null));
      try {
        final req = _buildSaveRequest(
          state.draftEntry,
          evidenceFor: state.evidenceFor,
          evidenceAgainst: state.evidenceAgainst,
        );
        final entryId = _entryId;
        if (entryId == null) {
          await _api.createAbc(req);
        } else {
          await _api.updateAbc(entryId, req);
        }
        JournalChanges.bump();
        emit(state.copyWith(isSaving: false, saveSucceeded: true));
      } catch (_) {
        emit(state.copyWith(isSaving: false, errorMessage: 'Не вдалося зберегти запис'));
      }
    });

    final entryId = _entryId;
    if (entryId != null) {
      add(LoadAbcEntryEvent(entryId));
    }
  }

  bool _isPositiveFlow(AbcEntryDraft draft) {
    if (draft.emotions.isEmpty) return false;
    return draft.emotions.every(_positiveEmotions.contains);
  }

  int _avgInitialIntensity(AbcEntryDraft draft) {
    final emotions = draft.emotions;
    if (emotions.isEmpty) return 0;

    var sum = 0;
    for (final e in emotions) {
      sum += (draft.initialIntensityByEmotion[e] ?? 0).clamp(0, 100);
    }

    return (sum / emotions.length).round().clamp(0, 100);
  }

  int _initialStatePercent(AbcEntryDraft draft) {
    final avg = _avgInitialIntensity(draft);
    if (_isPositiveFlow(draft)) {
      // Для позитивних емоцій інтенсивність = "стан" (не інвертуємо).
      return avg;
    }
    // Для негативного флоу інтенсивність = "негативність", тому інвертуємо у "стан".
    return (100 - avg).clamp(0, 100);
  }

  AbcEntryDraft _mapFromResponse(AbcEntryResponseDto dto) {
    final intensities = <String, int>{
      for (final e in dto.emotions) e.emotion: e.initialIntensity,
    };
    return AbcEntryDraft(
      id: dto.id,
      createdDate: dto.createdDate,
      situation: dto.situation,
      emotions: dto.emotions.map((e) => e.emotion).toList(),
      initialIntensityByEmotion: intensities,
      automaticThought: dto.automaticThought,
      thoughtBelief: dto.thoughtBelief,
      alternativeThought: dto.alternativeThought,
      alternativeThoughtBelief: dto.alternativeThoughtBelief,
      finalEmotionIntensity: dto.finalEmotionIntensity,
    );
  }

  SaveAbcEntryRequestDto _buildSaveRequest(
    AbcEntryDraft draft, {
    required List<String> evidenceFor,
    required List<String> evidenceAgainst,
  }) {
    final emotions = draft.emotions
        .map((e) => AbcEntryEmotionDto(
              emotion: e,
              initialIntensity: (draft.initialIntensityByEmotion[e] ?? 0).clamp(0, 100),
            ))
        .toList();

    final normalizedFor = evidenceFor.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final normalizedAgainst = evidenceAgainst.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    return SaveAbcEntryRequestDto(
      situation: draft.situation.trim(),
      automaticThought: draft.automaticThought.trim(),
      thoughtBelief: draft.thoughtBelief.clamp(0, 100),
      evidenceFor: normalizedFor,
      evidenceAgainst: normalizedAgainst,
      alternativeThought: draft.alternativeThought.trim(),
      alternativeThoughtBelief: draft.alternativeThoughtBelief.clamp(0, 100),
      finalEmotionIntensity: draft.finalEmotionIntensity.clamp(0, 100),
      emotions: emotions,
    );
  }
}