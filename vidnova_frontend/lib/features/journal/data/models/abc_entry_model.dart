class AbcEntryModel {
  final String situation;
  final String emotion;
  final double initialEmotionIntensity;
  final String automaticThought;
  final double thoughtBelief;
  final List<Evidence> evidenceFor;
  final List<Evidence> evidenceAgainst;
  final String alternativeThought;
  final double alternativeThoughtBelief;
  final double finalEmotionIntensity;
  final DateTime createdAt;

  AbcEntryModel({
    this.situation = '',
    this.emotion = '',
    this.initialEmotionIntensity = 0.0,
    this.automaticThought = '',
    this.thoughtBelief = 0.0,
    this.evidenceFor = const [],
    this.evidenceAgainst = const [],
    this.alternativeThought = '',
    this.alternativeThoughtBelief = 0.0,
    this.finalEmotionIntensity = 0.0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  AbcEntryModel copyWith({
    String? situation,
    String? emotion,
    double? initialEmotionIntensity,
    String? automaticThought,
    double? thoughtBelief,
    List<Evidence>? evidenceFor,
    List<Evidence>? evidenceAgainst,
    String? alternativeThought,
    double? alternativeThoughtBelief,
    double? finalEmotionIntensity,
    DateTime? createdAt,
  }) {
    return AbcEntryModel(
      situation: situation ?? this.situation,
      emotion: emotion ?? this.emotion,
      initialEmotionIntensity: initialEmotionIntensity ?? this.initialEmotionIntensity,
      automaticThought: automaticThought ?? this.automaticThought,
      thoughtBelief: thoughtBelief ?? this.thoughtBelief,
      evidenceFor: evidenceFor ?? this.evidenceFor,
      evidenceAgainst: evidenceAgainst ?? this.evidenceAgainst,
      alternativeThought: alternativeThought ?? this.alternativeThought,
      alternativeThoughtBelief: alternativeThoughtBelief ?? this.alternativeThoughtBelief,
      finalEmotionIntensity: finalEmotionIntensity ?? this.finalEmotionIntensity,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Evidence {
  final String id;
  final String text;
  final bool isFor;

  Evidence({
    required this.id,
    required this.text,
    required this.isFor,
  });
}