import 'package:flutter/material.dart';

class AppColors {
  // Primary Theme Colors (Rich Maroon & Terracotta)
  static const Color primary = Color(0xFF5D1204);
  static const Color primaryLight = Color(0xFFB58D3D);
  static const Color primaryDark = Color(0xFF3E0A02);
  
  // Golden Accent Colors
  static const Color accent = Color(0xFFFFD54F);     // Amber Yellow
  static const Color highlight = Color(0xFFFFB300);  // Gold Yellow
  
  // Functional Colors
  static const Color background = Color(0xFFFAF6EE); // Warm Cream Background
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD32F2F);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF5D1204);
  static const Color textSecondary = Color(0xFF795548);
  static const Color textHint = Color(0xFF9E9E9E);
  
  // Gradient for Dashboard / Buttons
  static const List<Color> primaryGradient = [
    Color(0xFFFFD54F),
    Color(0xFFFFB300),
  ];
}
