import 'package:flutter/material.dart';
import 'definitions/dark_theme.dart';
import 'definitions/light_theme.dart';

/// Legacy color facade — prefer [MusixThemeTokens] / [ColorScheme].
abstract final class AppColors {
  static const Color primaryLight = LightThemeColors.primary;
  static const Color primaryDark = DarkThemeColors.primary;
  static const Color primary = LightThemeColors.primary;

  static const Color accentLight = LightThemeColors.accent;
  static const Color accentDark = DarkThemeColors.accent;
  static const Color accent = LightThemeColors.accent;

  static const Color surfaceLight = LightThemeColors.surface;
  static const Color backgroundLight = LightThemeColors.background;
  static const Color cardLight = LightThemeColors.card;
  static const Color scaffoldLight = LightThemeColors.scaffold;

  static const Color surfaceDark = DarkThemeColors.surface;
  static const Color backgroundDark = DarkThemeColors.background;
  static const Color cardDark = DarkThemeColors.card;
  static const Color scaffoldDark = DarkThemeColors.scaffold;

  static const Color textPrimaryLight = LightThemeColors.textPrimary;
  static const Color textSecondaryLight = LightThemeColors.textSecondary;
  static const Color textPrimaryDark = DarkThemeColors.textPrimary;
  static const Color textSecondaryDark = DarkThemeColors.textSecondary;

  static const Color dividerLight = Color(0xFFE0E1EB);
  static const Color dividerDark = Color(0xFF2D2E42);

  static const Color miniPlayerLight = LightThemeColors.miniPlayer;
  static const Color miniPlayerDark = DarkThemeColors.miniPlayer;

  static const Color error = LightThemeColors.error;
  static const Color favorite = LightThemeColors.favorite;
}
