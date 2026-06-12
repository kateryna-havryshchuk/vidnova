class AbcEntryEmotionDto {
  final String emotion;
  final int initialIntensity;

  AbcEntryEmotionDto({
    required this.emotion,
    required this.initialIntensity,
  });

  factory AbcEntryEmotionDto.fromJson(Map<String, dynamic> json) {
    return AbcEntryEmotionDto(
      emotion: json['emotion'] as String,
      initialIntensity: (json['initialIntensity'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'emotion': emotion,
        'initialIntensity': initialIntensity,
      };
}

class AbcEvidenceDto {
  final String id;
  final String text;
  final bool isFor;

  AbcEvidenceDto({
    required this.id,
    required this.text,
    required this.isFor,
  });

  factory AbcEvidenceDto.fromJson(Map<String, dynamic> json) {
    return AbcEvidenceDto(
      id: json['id'] as String,
      text: json['text'] as String,
      isFor: json['isFor'] as bool,
    );
  }
}

class AbcEntryListItemDto {
  final String id;
  final DateTime createdDate;
  final String situation;
  final int finalEmotionIntensity;
  final List<AbcEntryEmotionDto> emotions;

  AbcEntryListItemDto({
    required this.id,
    required this.createdDate,
    required this.situation,
    required this.finalEmotionIntensity,
    required this.emotions,
  });

  factory AbcEntryListItemDto.fromJson(Map<String, dynamic> json) {
    final emotionsJson = (json['emotions'] as List? ?? const []);
    return AbcEntryListItemDto(
      id: json['id'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String),
      situation: (json['situation'] as String?) ?? '',
      finalEmotionIntensity: (json['finalEmotionIntensity'] as num).toInt(),
      emotions: emotionsJson
          .whereType<Map>()
          .map((e) => AbcEntryEmotionDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class AbcEntryResponseDto {
  final String id;
  final DateTime createdDate;
  final String situation;
  final String automaticThought;
  final int thoughtBelief;
  final List<AbcEvidenceDto> evidenceFor;
  final List<AbcEvidenceDto> evidenceAgainst;
  final String alternativeThought;
  final int alternativeThoughtBelief;
  final int finalEmotionIntensity;
  final List<AbcEntryEmotionDto> emotions;

  AbcEntryResponseDto({
    required this.id,
    required this.createdDate,
    required this.situation,
    required this.automaticThought,
    required this.thoughtBelief,
    required this.evidenceFor,
    required this.evidenceAgainst,
    required this.alternativeThought,
    required this.alternativeThoughtBelief,
    required this.finalEmotionIntensity,
    required this.emotions,
  });

  factory AbcEntryResponseDto.fromJson(Map<String, dynamic> json) {
    final evidenceForJson = (json['evidenceFor'] as List? ?? const []);
    final evidenceAgainstJson = (json['evidenceAgainst'] as List? ?? const []);
    final emotionsJson = (json['emotions'] as List? ?? const []);

    return AbcEntryResponseDto(
      id: json['id'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String),
      situation: (json['situation'] as String?) ?? '',
      automaticThought: (json['automaticThought'] as String?) ?? '',
      thoughtBelief: (json['thoughtBelief'] as num).toInt(),
      evidenceFor: evidenceForJson
          .whereType<Map>()
          .map((e) => AbcEvidenceDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      evidenceAgainst: evidenceAgainstJson
          .whereType<Map>()
          .map((e) => AbcEvidenceDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      alternativeThought: (json['alternativeThought'] as String?) ?? '',
      alternativeThoughtBelief: (json['alternativeThoughtBelief'] as num).toInt(),
      finalEmotionIntensity: (json['finalEmotionIntensity'] as num).toInt(),
      emotions: emotionsJson
          .whereType<Map>()
          .map((e) => AbcEntryEmotionDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class SaveAbcEntryRequestDto {
  final String situation;
  final String automaticThought;
  final int thoughtBelief;
  final List<String> evidenceFor;
  final List<String> evidenceAgainst;
  final String alternativeThought;
  final int alternativeThoughtBelief;
  final int finalEmotionIntensity;
  final List<AbcEntryEmotionDto> emotions;

  SaveAbcEntryRequestDto({
    required this.situation,
    required this.automaticThought,
    required this.thoughtBelief,
    required this.evidenceFor,
    required this.evidenceAgainst,
    required this.alternativeThought,
    required this.alternativeThoughtBelief,
    required this.finalEmotionIntensity,
    required this.emotions,
  });

  Map<String, dynamic> toJson() => {
        'situation': situation,
        'automaticThought': automaticThought,
        'thoughtBelief': thoughtBelief,
        'evidenceFor': evidenceFor,
        'evidenceAgainst': evidenceAgainst,
        'alternativeThought': alternativeThought,
        'alternativeThoughtBelief': alternativeThoughtBelief,
        'finalEmotionIntensity': finalEmotionIntensity,
        'emotions': emotions.map((e) => e.toJson()).toList(),
      };
}
