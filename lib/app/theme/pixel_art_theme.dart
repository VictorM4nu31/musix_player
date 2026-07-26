import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class PixelArtColors {
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color card = Color(0xFF1C2333);
  static const Color primary = Color(0xFF00FF41);
  static const Color secondary = Color(0xFFFF00FF);
  static const Color accent = Color(0xFF00D4FF);
  static const Color warning = Color(0xFFFFD700);
  static const Color error = Color(0xFFFF4444);
  static const Color textPrimary = Color(0xFFE6EDF3);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color divider = Color(0xFF30363D);
  static const Color border = Color(0xFF00FF41);
  static const Color glow = Color(0xFF00FF41);
}

abstract final class AppThemePixelArt {
  static ThemeData get theme {
    final colorScheme = ColorScheme.dark(
      primary: PixelArtColors.primary,
      secondary: PixelArtColors.secondary,
      surface: PixelArtColors.surface,
      error: PixelArtColors.error,
      onPrimary: PixelArtColors.background,
      onSecondary: PixelArtColors.background,
      onSurface: PixelArtColors.textPrimary,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: PixelArtColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: PixelArtColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: PixelArtColors.primary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
        ),
        iconTheme: IconThemeData(color: PixelArtColors.primary),
      ),
      cardTheme: CardThemeData(
        color: PixelArtColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: PixelArtColors.border, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: PixelArtColors.surface,
        selectedItemColor: PixelArtColors.primary,
        unselectedItemColor: PixelArtColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'monospace',
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: 'monospace',
        ),
      ),
      iconTheme: const IconThemeData(
        color: PixelArtColors.primary,
        size: 24,
      ),
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.pressStart2p(
          color: PixelArtColors.primary,
          fontSize: 24,
        ),
        headlineMedium: GoogleFonts.pressStart2p(
          color: PixelArtColors.textPrimary,
          fontSize: 18,
        ),
        titleLarge: GoogleFonts.pressStart2p(
          color: PixelArtColors.primary,
          fontSize: 16,
        ),
        titleMedium: GoogleFonts.pressStart2p(
          color: PixelArtColors.textPrimary,
          fontSize: 14,
        ),
        bodyLarge: GoogleFonts.shareTechMono(
          color: PixelArtColors.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.shareTechMono(
          color: PixelArtColors.textSecondary,
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.shareTechMono(
          color: PixelArtColors.textSecondary,
          fontSize: 12,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PixelArtColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: PixelArtColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: PixelArtColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: PixelArtColors.accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: const TextStyle(
          color: PixelArtColors.textSecondary,
          fontFamily: 'monospace',
        ),
        hintStyle: const TextStyle(
          color: PixelArtColors.textSecondary,
          fontFamily: 'monospace',
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: PixelArtColors.primary,
        inactiveTrackColor: PixelArtColors.primary.withAlpha(40),
        thumbColor: PixelArtColors.primary,
        overlayColor: PixelArtColors.primary.withAlpha(30),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: PixelArtColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: PixelArtColors.border, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: PixelArtColors.card,
        contentTextStyle: const TextStyle(
          color: PixelArtColors.primary,
          fontFamily: 'monospace',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: PixelArtColors.border, width: 1),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerColor: PixelArtColors.divider,
      dividerTheme: const DividerThemeData(
        color: PixelArtColors.divider,
        thickness: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: PixelArtColors.primary,
        foregroundColor: PixelArtColors.background,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: PixelArtColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: PixelArtColors.border, width: 1.5),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: PixelArtColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: PixelArtColors.border, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: PixelArtColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ),
    );
  }
}
