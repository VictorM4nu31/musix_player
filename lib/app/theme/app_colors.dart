import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary palette
  static const Color primaryLight = Color(0xFF5C6BC0);
  static const Color primaryDark = Color(0xFF9FA8DA);
  static const Color primary = Color(0xFF5C6BC0);

  // Secondary / Accent
  static const Color accentLight = Color(0xFFFF7043);
  static const Color accentDark = Color(0xFFFF8A65);
  static const Color accent = Color(0xFFFF7043);

  // Surface colors - Light
  static const Color surfaceLight = Color(0xFFF8F9FF);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFF0F1FA);
  static const Color scaffoldLight = Color(0xFFF5F6FA);

  // Surface colors - Dark
  static const Color surfaceDark = Color(0xFF1A1B2E);
  static const Color backgroundDark = Color(0xFF12131E);
  static const Color cardDark = Color(0xFF222338);
  static const Color scaffoldDark = Color(0xFF161726);

  // Text colors
  static const Color textPrimaryLight = Color(0xFF1A1B4B);
  static const Color textSecondaryLight = Color(0xFF6B6D7B);
  static const Color textPrimaryDark = Color(0xFFE8E9F3);
  static const Color textSecondaryDark = Color(0xFF9496AB);

  // Divider
  static const Color dividerLight = Color(0xFFE0E1EB);
  static const Color dividerDark = Color(0xFF2D2E42);

  // Mini player
  static const Color miniPlayerLight = Color(0xFFEEF0FF);
  static const Color miniPlayerDark = Color(0xFF1E1F34);

  // Error
  static const Color error = Color(0xFFEF5350);

  // Favorite
  static const Color favorite = Color(0xFFE53935);
}
