class CheckInEmotionDto {
  final String emotion; 
  final int intensity;

  CheckInEmotionDto({
    required this.emotion,
    required this.intensity,
  });

  factory CheckInEmotionDto.fromJson(Map<String, dynamic> json) {
    return CheckInEmotionDto(
      emotion: json['emotion'] as String,
      intensity: (json['intensity'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'emotion': emotion,
        'intensity': intensity,
      };
}

class DailyCheckInResponseDto {
  final String id;
  final String date; 
  final String description;
  final int calmScore;
  final List<CheckInEmotionDto> emotions;

  DailyCheckInResponseDto({
    required this.id,
    required this.date,
    required this.description,
    required this.calmScore,
    required this.emotions,
  });

  factory DailyCheckInResponseDto.fromJson(Map<String, dynamic> json) {
    final emotionsJson = (json['emotions'] as List? ?? const []);
    return DailyCheckInResponseDto(
      id: json['id'] as String,
      date: json['date'] as String,
      description: (json['description'] as String?) ?? '',
      calmScore: (json['calmScore'] as num).toInt(),
      emotions: emotionsJson
          .whereType<Map>()
          .map((e) => CheckInEmotionDto.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class DailyCheckInAiInsightResponseDto {
  final String id;
  final String date;
  final String model;
  final String sourceUpdatedAtUtc;
  final String promptText;
  final String responseText;

  DailyCheckInAiInsightResponseDto({
    required this.id,
    required this.date,
    required this.model,
    required this.sourceUpdatedAtUtc,
    required this.promptText,
    required this.responseText,
  });

  factory DailyCheckInAiInsightResponseDto.fromJson(Map<String, dynamic> json) {
    return DailyCheckInAiInsightResponseDto(
      id: json['id'] as String,
      date: json['date'] as String,
      model: (json['model'] as String?) ?? '',
      sourceUpdatedAtUtc: (json['sourceUpdatedAtUtc'] as String?) ?? '',
      promptText: (json['promptText'] as String?) ?? '',
      responseText: (json['responseText'] as String?) ?? '',
    );
  }
}

class SaveDailyCheckInRequestDto {
  final String? description;
  final int calmScore;
  final List<CheckInEmotionDto> emotions;

  SaveDailyCheckInRequestDto({
    required this.description,
    required this.calmScore,
    required this.emotions,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'calmScore': calmScore,
        'emotions': emotions.map((e) => e.toJson()).toList(),
      };
}