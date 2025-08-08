import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);

  static const Color ledNormal = Color(0xFF48BB78);
  static const Color ledWarning = Color(0xFFED8936);
  static const Color ledCritical = Color(0xFFF56565);

  static const MaterialColor primaryMaterial =
      MaterialColor(0xFF6C63FF, <int, Color>{
        50: Color(0xFFE8E7FF),
        100: Color(0xFFC5C3FF),
        200: Color(0xFFA29FFF),
        300: Color(0xFF7F7BFF),
        400: Color(0xFF6C63FF),
        500: Color(0xFF5A4BFF),
        600: Color(0xFF4839FF),
        700: Color(0xFF3627FF),
        800: Color(0xFF2415FF),
        900: Color(0xFF1203FF),
      });
}
