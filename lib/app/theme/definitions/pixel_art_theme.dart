import 'package:flutter/material.dart';
import '../fonts.dart';
import '../theme_builder.dart';
import '../theme_definition.dart';
import '../theme_id.dart';
import '../theme_tokens.dart';

/// Legacy color accessors kept for gradual migration of pixel widgets.
abstract final class PixelArtColors {
  static const Color background = Color(0xFF0A0E14);
  static const Color surface = Color(0xFF12181F);
  static const Color card = Color(0xFF1A2332);
  static const Color primary = Color(0xFF39FF14);
  static const Color secondary = Color(0xFFFF2A6D);
  static const Color accent = Color(0xFF05D9E8);
  static const Color warning = Color(0xFFFFD700);
  static const Color error = Color(0xFFFF4444);
  static const Color textPrimary = Color(0xFFE6F1FF);
  static const Color textSecondary = Color(0xFF8B9BB4);
  static const Color divider = Color(0xFF2A3544);
  static const Color border = Color(0xFF39FF14);
  static const Color glow = Color(0xFF39FF14);
}

final ThemeDefinition pixelArtThemeDefinition = ThemeDefinition(
  id: ThemeId.pixelArt,
  displayName: ThemeId.pixelArt.displayName,
  icon: Icons.videogame_asset_rounded,
  tokens: MusixThemeTokens(
    id: ThemeId.pixelArt,
    displayName: ThemeId.pixelArt.displayName,
    radiusSm: 0,
    radiusMd: 2,
    radiusLg: 4,
    borderWidth: 2,
    borderColor: PixelArtColors.border,
    miniPlayerBackground: PixelArtColors.surface,
    playerGradientStart: PixelArtColors.primary.withAlpha(28),
    playerGradientEnd: PixelArtColors.background,
    enableScanlines: true,
    scanlineOpacity: 0.04,
    glowColor: PixelArtColors.glow,
    sliderThumbStyle: SliderThumbStyle.square,
    playButtonSize: 68,
    playButtonRadius: BorderRadius.circular(4),
    artworkRadius: 2,
    displayFontFamily: AppFonts.pressStart2p,
    bodyFontFamily: AppFonts.shareTechMono,
    preferFrameSteppedMotion: true,
    fastAnim: const Duration(milliseconds: 80),
    mediumAnim: const Duration(milliseconds: 160),
    defaultCurve: Curves.linear,
    previewColors: const [
      PixelArtColors.primary,
      PixelArtColors.background,
      PixelArtColors.textPrimary,
    ],
    favoriteColor: PixelArtColors.secondary,
    controlShadows: [
      BoxShadow(
        color: PixelArtColors.glow.withAlpha(80),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ],
  ),
  buildThemeData: () {
    final tokens = pixelArtThemeDefinition.tokens;
    final colorScheme = ColorScheme.dark(
      primary: PixelArtColors.primary,
      secondary: PixelArtColors.secondary,
      tertiary: PixelArtColors.accent,
      surface: PixelArtColors.surface,
      error: PixelArtColors.error,
      onPrimary: PixelArtColors.background,
      onSecondary: PixelArtColors.background,
      onSurface: PixelArtColors.textPrimary,
      onError: Colors.white,
      outline: PixelArtColors.divider,
    );

    return ThemeBuilder.build(
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: PixelArtColors.background,
      tokens: tokens,
      textPrimary: PixelArtColors.textPrimary,
      textSecondary: PixelArtColors.textSecondary,
      fontFamily: AppFonts.shareTechMono,
      appBarBackground: PixelArtColors.surface,
      cardColor: PixelArtColors.card,
      navBackground: PixelArtColors.surface,
      inputFill: PixelArtColors.card,
      dialogBackground: PixelArtColors.surface,
      snackBarBackground: PixelArtColors.card,
      snackBarForeground: PixelArtColors.primary,
      cardOutlined: true,
      cardElevation: 0,
      textThemeOverride: TextTheme(
        headlineLarge: const TextStyle(
          color: PixelArtColors.primary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: AppFonts.pressStart2p,
          height: 1.5,
          letterSpacing: 0.5,
        ),
        headlineMedium: const TextStyle(
          color: PixelArtColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          fontFamily: AppFonts.pressStart2p,
          height: 1.5,
        ),
        titleLarge: const TextStyle(
          color: PixelArtColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          fontFamily: AppFonts.pressStart2p,
          height: 1.45,
        ),
        titleMedium: const TextStyle(
          color: PixelArtColors.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w400,
          fontFamily: AppFonts.pressStart2p,
          height: 1.4,
        ),
        bodyLarge: const TextStyle(
          color: PixelArtColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          fontFamily: AppFonts.shareTechMono,
          height: 1.35,
        ),
        bodyMedium: const TextStyle(
          color: PixelArtColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontFamily: AppFonts.shareTechMono,
          height: 1.35,
        ),
        bodySmall: const TextStyle(
          color: PixelArtColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          fontFamily: AppFonts.shareTechMono,
          height: 1.3,
        ),
        labelLarge: const TextStyle(
          color: PixelArtColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          fontFamily: AppFonts.shareTechMono,
        ),
      ),
      appBarThemeOverride: const AppBarTheme(
        backgroundColor: PixelArtColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: PixelArtColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          fontFamily: AppFonts.pressStart2p,
        ),
        iconTheme: IconThemeData(color: PixelArtColors.primary),
      ),
      navThemeOverride: const BottomNavigationBarThemeData(
        backgroundColor: PixelArtColors.surface,
        selectedItemColor: PixelArtColors.primary,
        unselectedItemColor: PixelArtColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          fontFamily: AppFonts.shareTechMono,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          fontFamily: AppFonts.shareTechMono,
        ),
      ),
    );
  },
);
