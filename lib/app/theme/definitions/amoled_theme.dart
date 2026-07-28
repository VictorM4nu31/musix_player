import 'package:flutter/material.dart';
import '../theme_builder.dart';
import '../theme_definition.dart';
import '../theme_id.dart';
import '../theme_tokens.dart';

abstract final class AmoledThemeColors {
  static const Color primary = Color(0xFFBB86FC);
  static const Color accent = Color(0xFF03DAC6);
  static const Color surface = Color(0xFF000000);
  static const Color background = Color(0xFF000000);
  static const Color card = Color(0xFF0A0A0A);
  static const Color scaffold = Color(0xFF000000);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color miniPlayer = Color(0xFF000000);
  static const Color error = Color(0xFFCF6679);
  static const Color favorite = Color(0xFFFF5252);
}

final ThemeDefinition amoledThemeDefinition = ThemeDefinition(
  id: ThemeId.amoled,
  displayName: ThemeId.amoled.displayName,
  icon: Icons.contrast_rounded,
  tokens: MusixThemeTokens(
    id: ThemeId.amoled,
    displayName: ThemeId.amoled.displayName,
    radiusSm: 8,
    radiusMd: 12,
    radiusLg: 16,
    borderWidth: 0,
    miniPlayerBackground: AmoledThemeColors.miniPlayer,
    playerGradientStart: AmoledThemeColors.primary.withAlpha(30),
    playerGradientEnd: AmoledThemeColors.scaffold,
    playButtonRadius: BorderRadius.circular(32),
    artworkRadius: 10,
    previewColors: const [
      AmoledThemeColors.primary,
      AmoledThemeColors.scaffold,
      AmoledThemeColors.textPrimary,
    ],
    favoriteColor: AmoledThemeColors.favorite,
  ),
  buildThemeData: () {
    final tokens = amoledThemeDefinition.tokens;
    final colorScheme = ColorScheme.dark(
      primary: AmoledThemeColors.primary,
      secondary: AmoledThemeColors.accent,
      surface: AmoledThemeColors.surface,
      error: AmoledThemeColors.error,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: AmoledThemeColors.textPrimary,
      onError: Colors.black,
    );
    return ThemeBuilder.build(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AmoledThemeColors.scaffold,
      tokens: tokens,
      textPrimary: AmoledThemeColors.textPrimary,
      textSecondary: AmoledThemeColors.textSecondary,
      cardColor: AmoledThemeColors.card,
      navBackground: AmoledThemeColors.background,
      inputFill: AmoledThemeColors.card,
      dialogBackground: AmoledThemeColors.card,
      snackBarBackground: AmoledThemeColors.card,
      snackBarForeground: AmoledThemeColors.textPrimary,
      cardElevation: 0,
    );
  },
);
