class AbcEntryDraft {
  final String? id;
  final DateTime? createdDate;

  final String situation;
  final List<String> emotions;
  final Map<String, int> initialIntensityByEmotion;

  final String automaticThought;
  final int thoughtBelief;

  final String alternativeThought;
  final int alternativeThoughtBelief;

  final int finalEmotionIntensity;

  const AbcEntryDraft({
    this.id,
    this.createdDate,
    required this.situation,
    required this.emotions,
    required this.initialIntensityByEmotion,
    required this.automaticThought,
    required this.thoughtBelief,
    required this.alternativeThought,
    required this.alternativeThoughtBelief,
    required this.finalEmotionIntensity,
  });

  factory AbcEntryDraft.empty() {
    return const AbcEntryDraft(
      situation: '',
      emotions: <String>[],
      initialIntensityByEmotion: <String, int>{},
      automaticThought: '',
      thoughtBelief: 0,
      alternativeThought: '',
      alternativeThoughtBelief: 0,
      finalEmotionIntensity: 0,
    );
  }

  AbcEntryDraft copyWith({
    String? id,
    DateTime? createdDate,
    String? situation,
    List<String>? emotions,
    Map<String, int>? initialIntensityByEmotion,
    String? automaticThought,
    int? thoughtBelief,
    String? alternativeThought,
    int? alternativeThoughtBelief,
    int? finalEmotionIntensity,
  }) {
    return AbcEntryDraft(
      id: id ?? this.id,
      createdDate: createdDate ?? this.createdDate,
      situation: situation ?? this.situation,
      emotions: emotions ?? this.emotions,
      initialIntensityByEmotion: initialIntensityByEmotion ?? this.initialIntensityByEmotion,
      automaticThought: automaticThought ?? this.automaticThought,
      thoughtBelief: thoughtBelief ?? this.thoughtBelief,
      alternativeThought: alternativeThought ?? this.alternativeThought,
      alternativeThoughtBelief: alternativeThoughtBelief ?? this.alternativeThoughtBelief,
      finalEmotionIntensity: finalEmotionIntensity ?? this.finalEmotionIntensity,
    );
  }
}
