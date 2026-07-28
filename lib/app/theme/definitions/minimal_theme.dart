import 'package:flutter/material.dart';
import '../theme_builder.dart';
import '../theme_definition.dart';
import '../theme_id.dart';
import '../theme_tokens.dart';

abstract final class MinimalThemeColors {
  static const Color primary = Color(0xFF2C2C2C);
  static const Color accent = Color(0xFF6B6B6B);
  static const Color surface = Color(0xFFFAFAFA);
  static const Color background = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFF5F5F5);
  static const Color scaffold = Color(0xFFFCFCFC);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color miniPlayer = Color(0xFFF7F7F7);
  static const Color error = Color(0xFFB00020);
  static const Color favorite = Color(0xFFB00020);
}

final ThemeDefinition minimalThemeDefinition = ThemeDefinition(
  id: ThemeId.minimal,
  displayName: ThemeId.minimal.displayName,
  icon: Icons.crop_square_rounded,
  tokens: MusixThemeTokens(
    id: ThemeId.minimal,
    displayName: ThemeId.minimal.displayName,
    radiusSm: 4,
    radiusMd: 8,
    radiusLg: 12,
    borderWidth: 0,
    miniPlayerBackground: MinimalThemeColors.miniPlayer,
    playerGradientStart: MinimalThemeColors.scaffold,
    playerGradientEnd: MinimalThemeColors.scaffold,
    playButtonRadius: BorderRadius.circular(28),
    artworkRadius: 6,
    previewColors: const [
      MinimalThemeColors.primary,
      MinimalThemeColors.scaffold,
      MinimalThemeColors.textSecondary,
    ],
    favoriteColor: MinimalThemeColors.favorite,
    fastAnim: const Duration(milliseconds: 200),
    mediumAnim: const Duration(milliseconds: 350),
  ),
  buildThemeData: () {
    final tokens = minimalThemeDefinition.tokens;
    final colorScheme = ColorScheme.light(
      primary: MinimalThemeColors.primary,
      secondary: MinimalThemeColors.accent,
      surface: MinimalThemeColors.surface,
      error: MinimalThemeColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: MinimalThemeColors.textPrimary,
      onError: Colors.white,
    );
    return ThemeBuilder.build(
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: MinimalThemeColors.scaffold,
      tokens: tokens,
      textPrimary: MinimalThemeColors.textPrimary,
      textSecondary: MinimalThemeColors.textSecondary,
      cardColor: MinimalThemeColors.card,
      navBackground: MinimalThemeColors.background,
      inputFill: MinimalThemeColors.card,
      dialogBackground: MinimalThemeColors.background,
      snackBarBackground: MinimalThemeColors.primary,
      snackBarForeground: Colors.white,
      cardElevation: 0,
    );
  },
);
