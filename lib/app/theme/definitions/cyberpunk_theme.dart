import 'package:flutter/material.dart';
import '../fonts.dart';
import '../theme_builder.dart';
import '../theme_definition.dart';
import '../theme_id.dart';
import '../theme_tokens.dart';

abstract final class CyberpunkThemeColors {
  static const Color primary = Color(0xFFFF2A6D);
  static const Color accent = Color(0xFF05D9E8);
  static const Color secondary = Color(0xFFD1F7FF);
  static const Color surface = Color(0xFF1A0A2E);
  static const Color background = Color(0xFF0D0221);
  static const Color card = Color(0xFF251238);
  static const Color scaffold = Color(0xFF12001F);
  static const Color textPrimary = Color(0xFFD1F7FF);
  static const Color textSecondary = Color(0xFF9B7EBD);
  static const Color miniPlayer = Color(0xFF1A0A2E);
  static const Color error = Color(0xFFFF6B6B);
  static const Color favorite = Color(0xFFFF2A6D);
  static const Color border = Color(0xFFFF2A6D);
  static const Color glow = Color(0xFF05D9E8);
}

final ThemeDefinition cyberpunkThemeDefinition = ThemeDefinition(
  id: ThemeId.cyberpunk,
  displayName: ThemeId.cyberpunk.displayName,
  icon: Icons.bolt_rounded,
  tokens: MusixThemeTokens(
    id: ThemeId.cyberpunk,
    displayName: ThemeId.cyberpunk.displayName,
    radiusSm: 4,
    radiusMd: 8,
    radiusLg: 12,
    borderWidth: 1.5,
    borderColor: CyberpunkThemeColors.border.withAlpha(180),
    miniPlayerBackground: CyberpunkThemeColors.miniPlayer,
    playerGradientStart: CyberpunkThemeColors.primary.withAlpha(50),
    playerGradientEnd: CyberpunkThemeColors.scaffold,
    glowColor: CyberpunkThemeColors.glow,
    playButtonRadius: BorderRadius.circular(8),
    artworkRadius: 8,
    bodyFontFamily: AppFonts.shareTechMono,
    displayFontFamily: AppFonts.orbitron,
    previewColors: const [
      CyberpunkThemeColors.primary,
      CyberpunkThemeColors.scaffold,
      CyberpunkThemeColors.accent,
    ],
    favoriteColor: CyberpunkThemeColors.favorite,
    controlShadows: [
      BoxShadow(
        color: CyberpunkThemeColors.glow.withAlpha(90),
        blurRadius: 12,
        spreadRadius: 1,
      ),
    ],
    cardShadows: [
      BoxShadow(
        color: CyberpunkThemeColors.primary.withAlpha(40),
        blurRadius: 10,
        offset: const Offset(0, 0),
      ),
    ],
  ),
  buildThemeData: () {
    final tokens = cyberpunkThemeDefinition.tokens;
    final colorScheme = ColorScheme.dark(
      primary: CyberpunkThemeColors.primary,
      secondary: CyberpunkThemeColors.accent,
      tertiary: CyberpunkThemeColors.secondary,
      surface: CyberpunkThemeColors.surface,
      error: CyberpunkThemeColors.error,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: CyberpunkThemeColors.textPrimary,
      onError: Colors.black,
      outline: CyberpunkThemeColors.border,
    );
    return ThemeBuilder.build(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: CyberpunkThemeColors.scaffold,
      tokens: tokens,
      textPrimary: CyberpunkThemeColors.textPrimary,
      textSecondary: CyberpunkThemeColors.textSecondary,
      fontFamily: AppFonts.shareTechMono,
      appBarBackground: CyberpunkThemeColors.surface,
      cardColor: CyberpunkThemeColors.card,
      navBackground: CyberpunkThemeColors.surface,
      inputFill: CyberpunkThemeColors.card,
      dialogBackground: CyberpunkThemeColors.surface,
      snackBarBackground: CyberpunkThemeColors.card,
      snackBarForeground: CyberpunkThemeColors.accent,
      cardOutlined: true,
      appBarThemeOverride: const AppBarTheme(
        backgroundColor: CyberpunkThemeColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: CyberpunkThemeColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: AppFonts.orbitron,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: CyberpunkThemeColors.accent),
      ),
      textThemeOverride: const TextTheme(
        headlineLarge: TextStyle(
          color: CyberpunkThemeColors.primary,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          fontFamily: AppFonts.orbitron,
          letterSpacing: 1.0,
        ),
        headlineMedium: TextStyle(
          color: CyberpunkThemeColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          fontFamily: AppFonts.orbitron,
        ),
        titleLarge: TextStyle(
          color: CyberpunkThemeColors.primary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: AppFonts.orbitron,
          letterSpacing: 0.8,
        ),
        titleMedium: TextStyle(
          color: CyberpunkThemeColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontFamily: AppFonts.orbitron,
        ),
        bodyLarge: TextStyle(
          color: CyberpunkThemeColors.textPrimary,
          fontSize: 16,
          fontFamily: AppFonts.shareTechMono,
        ),
        bodyMedium: TextStyle(
          color: CyberpunkThemeColors.textSecondary,
          fontSize: 14,
          fontFamily: AppFonts.shareTechMono,
        ),
        bodySmall: TextStyle(
          color: CyberpunkThemeColors.textSecondary,
          fontSize: 12,
          fontFamily: AppFonts.shareTechMono,
        ),
      ),
    );
  },
);
