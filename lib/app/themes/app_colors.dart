import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color primaryLight = Color(0xFF6366F1); // Indigo
  static const Color secondaryLight = Color(0xFF8B5CF6); // Purple
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Colors.white;
  static const Color errorLight = Color(0xFFEF4444);

  // Dark Theme Colors
  static const Color primaryDark = Color(0xFF818CF8);
  static const Color secondaryDark = Color(0xFFA78BFA);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color errorDark = Color(0xFFFCA5A5);

  // Common Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Transaction Colors
  static const Color income = Color(0xFF10B981);
  static const Color expense = Color(0xFFEF4444);

  // Category Colors
  static const List<Color> categoryColors = [
    Color(0xFFEF4444), // Red
    Color(0xFFF59E0B), // Orange
    Color(0xFF10B981), // Green
    Color(0xFF3B82F6), // Blue
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF14B8A6), // Teal
    Color(0xFFF97316), // Deep Orange
  ];
}
