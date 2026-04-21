import 'package:flutter/material.dart';

class AppColors {
  // Основні кольори
  static const Color primary = Color(0xFF4A55A2);
  static const Color secondary = Color(0xFF7B68EE);
  
  // Фонові кольори
  static const Color background = Color(0xFFF8F9FF);
  static const Color surface = Colors.white;
  
  // Текстові кольори
  static const Color textPrimary = Color(0xFF2E337A);
  // Slightly darker secondary/hint text for better readability.
  static const Color textSecondary = Color(0xFF6F7693);
  static const Color textTertiary = Color(0xFF8B92B2);
  static const Color textHint = Color(0xFF949AB2);
  
  // Емоційні кольори
  static const Color emotionPositive = Color(0xFF81C784);
  static const Color emotionNegative = Color(0xFFE57373);
  static const Color emotionChart = Color(0xFFD97D54);
  
  // Додаткові кольори
  static const Color border = Color(0xFFE1E5F0);
  static const Color gridLines = Color(0xFFF0F2F8);
  static const Color inactive = Color(0xFF949AB2);
  
  // Кольори з прозорістю
  static Color primaryLight = primary.withAlpha(26);
  static Color primaryBorder = primary.withAlpha(77);
  static Color positiveLight = emotionPositive.withAlpha(26);
  static Color positiveBorder = emotionPositive.withAlpha(77);
  static Color negativeLight = emotionNegative.withAlpha(26);
  static Color negativeBorder = emotionNegative.withAlpha(77);
  static Color shadow = Colors.black.withAlpha(20);
  static Color shadowDark = Colors.black.withAlpha(51);
}