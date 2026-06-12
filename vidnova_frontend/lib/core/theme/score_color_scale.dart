import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Shared 5-color scale for "state" scores (0..100):
/// red -> orange -> blue -> purple -> green.
///
/// Use [discrete] when you want exactly 5 buckets.
/// Use [smooth] when you want continuous color changes (e.g. slider thumb/track).
class ScoreColorScale {
  static const List<int> _stops = <int>[0, 20, 40, 60, 80, 100];

  static const List<Color> _colors = <Color>[
    AppColors.emotionNegative, // 0
    AppColors.emotionChart, // 20
    AppColors.primary, // 40
    AppColors.secondary, // 60
    AppColors.emotionPositive, // 80
    AppColors.emotionPositive, // 100
  ];

  static Color discrete(int score) {
    final s = score.clamp(0, 100);
    if (s >= 80) return AppColors.emotionPositive;
    if (s >= 60) return AppColors.secondary;
    if (s >= 40) return AppColors.primary;
    if (s >= 20) return AppColors.emotionChart;
    return AppColors.emotionNegative;
  }

  static Color smooth(int score) {
    final s = score.clamp(0, 100);

    for (var i = 0; i < _stops.length - 1; i++) {
      final a = _stops[i];
      final b = _stops[i + 1];
      if (s >= a && s <= b) {
        final t = (b == a) ? 0.0 : (s - a) / (b - a);
        return Color.lerp(_colors[i], _colors[i + 1], t) ?? _colors[i + 1];
      }
    }

    return _colors.last;
  }
}
