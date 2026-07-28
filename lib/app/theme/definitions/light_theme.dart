import 'package:flutter/material.dart';
import '../theme_builder.dart';
import '../theme_definition.dart';
import '../theme_id.dart';
import '../theme_tokens.dart';

abstract final class LightThemeColors {
  static const Color primary = Color(0xFF5C6BC0);
  static const Color accent = Color(0xFFFF7043);
  static const Color surface = Color(0xFFF8F9FF);
  static const Color background = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFF0F1FA);
  static const Color scaffold = Color(0xFFF5F6FA);
  static const Color textPrimary = Color(0xFF1A1B4B);
  static const Color textSecondary = Color(0xFF6B6D7B);
  static const Color miniPlayer = Color(0xFFEEF0FF);
  static const Color error = Color(0xFFEF5350);
  static const Color favorite = Color(0xFFE53935);
}

final ThemeDefinition lightThemeDefinition = ThemeDefinition(
  id: ThemeId.light,
  displayName: ThemeId.light.displayName,
  icon: Icons.light_mode_rounded,
  tokens: MusixThemeTokens(
    id: ThemeId.light,
    displayName: ThemeId.light.displayName,
    radiusSm: 8,
    radiusMd: 16,
    radiusLg: 20,
    borderWidth: 0,
    miniPlayerBackground: LightThemeColors.miniPlayer,
    playerGradientStart: LightThemeColors.primary.withAlpha(40),
    playerGradientEnd: LightThemeColors.scaffold,
    playButtonRadius: BorderRadius.circular(32),
    artworkRadius: 12,
    previewColors: const [
      LightThemeColors.primary,
      LightThemeColors.scaffold,
      LightThemeColors.textPrimary,
    ],
    favoriteColor: LightThemeColors.favorite,
    cardShadows: [
      BoxShadow(
        color: Colors.black.withAlpha(12),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  buildThemeData: () {
    final tokens = lightThemeDefinition.tokens;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: LightThemeColors.primary,
      brightness: Brightness.light,
      primary: LightThemeColors.primary,
      secondary: LightThemeColors.accent,
      surface: LightThemeColors.surface,
      error: LightThemeColors.error,
    );
    return ThemeBuilder.build(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: LightThemeColors.scaffold,
      tokens: tokens,
      textPrimary: LightThemeColors.textPrimary,
      textSecondary: LightThemeColors.textSecondary,
      cardColor: LightThemeColors.card,
      navBackground: LightThemeColors.background,
      inputFill: LightThemeColors.card,
      dialogBackground: LightThemeColors.background,
      snackBarBackground: LightThemeColors.textPrimary,
      snackBarForeground: Colors.white,
    );
  },
);
