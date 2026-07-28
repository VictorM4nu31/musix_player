import 'package:flutter/material.dart';
import '../theme_builder.dart';
import '../theme_definition.dart';
import '../theme_id.dart';
import '../theme_tokens.dart';

abstract final class DarkThemeColors {
  static const Color primary = Color(0xFF9FA8DA);
  static const Color accent = Color(0xFFFF8A65);
  static const Color surface = Color(0xFF1A1B2E);
  static const Color background = Color(0xFF12131E);
  static const Color card = Color(0xFF222338);
  static const Color scaffold = Color(0xFF161726);
  static const Color textPrimary = Color(0xFFE8E9F3);
  static const Color textSecondary = Color(0xFF9496AB);
  static const Color miniPlayer = Color(0xFF1E1F34);
  static const Color error = Color(0xFFEF5350);
  static const Color favorite = Color(0xFFE53935);
}

final ThemeDefinition darkThemeDefinition = ThemeDefinition(
  id: ThemeId.dark,
  displayName: ThemeId.dark.displayName,
  icon: Icons.dark_mode_rounded,
  tokens: MusixThemeTokens(
    id: ThemeId.dark,
    displayName: ThemeId.dark.displayName,
    radiusSm: 8,
    radiusMd: 16,
    radiusLg: 20,
    borderWidth: 0,
    miniPlayerBackground: DarkThemeColors.miniPlayer,
    playerGradientStart: DarkThemeColors.primary.withAlpha(40),
    playerGradientEnd: DarkThemeColors.scaffold,
    playButtonRadius: BorderRadius.circular(32),
    artworkRadius: 12,
    previewColors: const [
      DarkThemeColors.primary,
      DarkThemeColors.scaffold,
      DarkThemeColors.textPrimary,
    ],
    favoriteColor: DarkThemeColors.favorite,
    cardShadows: [
      BoxShadow(
        color: Colors.black.withAlpha(40),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  buildThemeData: () {
    final tokens = darkThemeDefinition.tokens;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: DarkThemeColors.primary,
      brightness: Brightness.dark,
      primary: DarkThemeColors.primary,
      secondary: DarkThemeColors.accent,
      surface: DarkThemeColors.surface,
      error: DarkThemeColors.error,
    );
    return ThemeBuilder.build(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: DarkThemeColors.scaffold,
      tokens: tokens,
      textPrimary: DarkThemeColors.textPrimary,
      textSecondary: DarkThemeColors.textSecondary,
      cardColor: DarkThemeColors.card,
      navBackground: DarkThemeColors.background,
      inputFill: DarkThemeColors.card,
      dialogBackground: DarkThemeColors.background,
      snackBarBackground: DarkThemeColors.textPrimary,
      snackBarForeground: DarkThemeColors.background,
    );
  },
);
