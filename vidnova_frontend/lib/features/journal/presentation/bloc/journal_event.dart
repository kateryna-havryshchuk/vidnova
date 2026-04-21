abstract class JournalEvent {}

class NextStepEvent extends JournalEvent {}
class PrevStepEvent extends JournalEvent {}

class LoadAbcEntryEvent extends JournalEvent {
  final String id;
  LoadAbcEntryEvent(this.id);
}

class UpdateSituationEvent extends JournalEvent {
  final String text;
  UpdateSituationEvent(this.text);
}

class ToggleEmotionEvent extends JournalEvent {
  final String emotion;
  ToggleEmotionEvent(this.emotion);
}

class UpdateEmotionIntensityEvent extends JournalEvent {
  final String emotion;
  final int intensity;
  UpdateEmotionIntensityEvent({required this.emotion, required this.intensity});
}

class UpdateAutomaticThoughtEvent extends JournalEvent {
  final String text;
  UpdateAutomaticThoughtEvent(this.text);
}

class UpdateThoughtBeliefEvent extends JournalEvent {
  final int belief;
  UpdateThoughtBeliefEvent(this.belief);
}

class AddEvidenceToPoolEvent extends JournalEvent {
  final String text;
  AddEvidenceToPoolEvent(this.text);
}

class RemoveEvidenceFromPoolEvent extends JournalEvent {
  final String text;
  RemoveEvidenceFromPoolEvent(this.text);
}

class MoveEvidenceToForEvent extends JournalEvent {
  final String text;
  MoveEvidenceToForEvent(this.text);
}

class MoveEvidenceToAgainstEvent extends JournalEvent {
  final String text;
  MoveEvidenceToAgainstEvent(this.text);
}

class RemoveEvidenceFromForEvent extends JournalEvent {
  final String text;
  RemoveEvidenceFromForEvent(this.text);
}

class RemoveEvidenceFromAgainstEvent extends JournalEvent {
  final String text;
  RemoveEvidenceFromAgainstEvent(this.text);
}

class UpdateAlternativeThoughtEvent extends JournalEvent {
  final String text;
  UpdateAlternativeThoughtEvent(this.text);
}

class UpdateAlternativeBeliefEvent extends JournalEvent {
  final int belief;
  UpdateAlternativeBeliefEvent(this.belief);
}

class UpdateFinalIntensityEvent extends JournalEvent {
  final int intensity;
  UpdateFinalIntensityEvent(this.intensity);
}

class SaveAbcEntryEvent extends JournalEvent {}