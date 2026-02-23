abstract class JournalEvent {}

class NextStepEvent extends JournalEvent {}
class PrevStepEvent extends JournalEvent {}

class UpdateEmotionEvent extends JournalEvent {
  final String emotion;
  UpdateEmotionEvent(this.emotion);
}

class UpdateIntensityEvent extends JournalEvent {
  final double intensity;
  UpdateIntensityEvent(this.intensity);
}

class UpdateThoughtBeliefEvent extends JournalEvent {
  final double belief;
  UpdateThoughtBeliefEvent(this.belief);
}

class UpdateAlternativeBeliefEvent extends JournalEvent {
  final double belief;
  UpdateAlternativeBeliefEvent(this.belief);
}

class UpdateFinalIntensityEvent extends JournalEvent {
  final double intensity;
  UpdateFinalIntensityEvent(this.intensity);
}

class AddTempEvidenceEvent extends JournalEvent {
  final String evidence;
  AddTempEvidenceEvent(this.evidence);
}

class RemoveTempEvidenceEvent extends JournalEvent {
  final String evidence;
  RemoveTempEvidenceEvent(this.evidence);
}

class AddEvidenceForEvent extends JournalEvent {
  final String evidence;
  AddEvidenceForEvent(this.evidence);
}

class AddEvidenceAgainstEvent extends JournalEvent {
  final String evidence;
  AddEvidenceAgainstEvent(this.evidence);
}

class RemoveEvidenceEvent extends JournalEvent {
  final String evidenceId;
  RemoveEvidenceEvent(this.evidenceId);
}

class AnalyzeThoughtEvent extends JournalEvent {
  final String thought;
  AnalyzeThoughtEvent(this.thought);
}

class DismissAiSuggestionEvent extends JournalEvent {}

class SaveEntryEvent extends JournalEvent {
  final String situation;
  final String thought;
  final String alternativeThought;
  
  SaveEntryEvent({
    required this.situation,
    required this.thought,
    required this.alternativeThought,
  });
}