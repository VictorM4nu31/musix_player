import 'package:flutter/material.dart';
import '../../core/widgets/themed_slider_thumb.dart';
import 'theme_tokens.dart';

/// Shared helpers to build consistent [ThemeData] from a [ColorScheme] + tokens.
abstract final class ThemeBuilder {
  static ThemeData build({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required Color scaffoldBackgroundColor,
    required MusixThemeTokens tokens,
    required Color textPrimary,
    required Color textSecondary,
    String? fontFamily,
    Color? appBarBackground,
    Color? cardColor,
    Color? navBackground,
    Color? inputFill,
    Color? dialogBackground,
    Color? snackBarBackground,
    Color? snackBarForeground,
    double? cardElevation,
    bool cardOutlined = false,
    TextTheme? textThemeOverride,
    AppBarTheme? appBarThemeOverride,
    BottomNavigationBarThemeData? navThemeOverride,
    SliderThemeData? sliderThemeOverride,
  }) {
    final radiusMd = tokens.radiusMd;
    final radiusLg = tokens.radiusLg;
    final borderSide = tokens.borderColor != null && tokens.borderWidth > 0
        ? BorderSide(color: tokens.borderColor!, width: tokens.borderWidth)
        : BorderSide.none;

    final baseTextTheme = textThemeOverride ??
        _defaultTextTheme(
          textPrimary: textPrimary,
          textSecondary: textSecondary,
          fontFamily: fontFamily ?? tokens.bodyFontFamily,
          displayFontFamily: tokens.displayFontFamily,
        );

    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
      side: cardOutlined ? borderSide : BorderSide.none,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      fontFamily: fontFamily ?? tokens.bodyFontFamily,
      extensions: [tokens],
      appBarTheme: appBarThemeOverride ??
          AppBarTheme(
            backgroundColor: appBarBackground ?? Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              color: textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              fontFamily: tokens.displayFontFamily ?? fontFamily,
            ),
            iconTheme: IconThemeData(color: textPrimary),
          ),
      cardTheme: CardThemeData(
        color: cardColor ?? colorScheme.surface,
        elevation: cardElevation ?? 0,
        shape: cardShape,
      ),
      bottomNavigationBarTheme: navThemeOverride ??
          BottomNavigationBarThemeData(
            backgroundColor: navBackground ?? scaffoldBackgroundColor,
            selectedItemColor: colorScheme.primary,
            unselectedItemColor: textSecondary,
            type: BottomNavigationBarType.fixed,
            elevation: tokens.cardShadows.isEmpty ? 0 : 8,
            selectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: fontFamily ?? tokens.bodyFontFamily,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: fontFamily ?? tokens.bodyFontFamily,
            ),
          ),
      iconTheme: IconThemeData(color: textPrimary, size: 24),
      textTheme: baseTextTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill ?? cardColor ?? colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd > 4 ? 12 : radiusMd),
          borderSide: borderSide == BorderSide.none
              ? BorderSide.none
              : borderSide,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd > 4 ? 12 : radiusMd),
          borderSide: borderSide == BorderSide.none
              ? BorderSide.none
              : borderSide,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd > 4 ? 12 : radiusMd),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(
          color: textSecondary,
          fontFamily: fontFamily ?? tokens.bodyFontFamily,
        ),
        hintStyle: TextStyle(
          color: textSecondary,
          fontFamily: fontFamily ?? tokens.bodyFontFamily,
        ),
      ),
      sliderTheme: sliderThemeOverride ??
          SliderThemeData(
            activeTrackColor: colorScheme.primary,
            inactiveTrackColor: colorScheme.primary.withAlpha(60),
            thumbColor: colorScheme.primary,
            overlayColor: colorScheme.primary.withAlpha(30),
            trackHeight:
                tokens.sliderThumbStyle == SliderThumbStyle.square ? 6 : 4,
            thumbShape: thumbShapeFor(tokens.sliderThumbStyle),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
      dialogTheme: DialogThemeData(
        backgroundColor: dialogBackground ?? scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: borderSide,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: snackBarBackground ?? textPrimary,
        contentTextStyle: TextStyle(
          color: snackBarForeground ?? colorScheme.surface,
          fontFamily: fontFamily ?? tokens.bodyFontFamily,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: borderSide == BorderSide.none
              ? BorderSide.none
              : BorderSide(
                  color: tokens.borderColor ?? colorScheme.primary,
                  width: 1,
                ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerColor: colorScheme.outline.withAlpha(80),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withAlpha(80),
        thickness: 1,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: dialogBackground ?? colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: borderSide,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: dialogBackground ?? colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
          side: borderSide,
        ),
      ),
    );
  }

  static TextTheme _defaultTextTheme({
    required Color textPrimary,
    required Color textSecondary,
    String? fontFamily,
    String? displayFontFamily,
  }) {
    final display = displayFontFamily ?? fontFamily;
    return TextTheme(
      headlineLarge: TextStyle(
        color: textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        fontFamily: display,
      ),
      headlineMedium: TextStyle(
        color: textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        fontFamily: display,
      ),
      titleLarge: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: display,
      ),
      titleMedium: TextStyle(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        fontFamily: display,
      ),
      bodyLarge: TextStyle(
        color: textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        fontFamily: fontFamily,
      ),
      bodyMedium: TextStyle(
        color: textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: fontFamily,
      ),
      bodySmall: TextStyle(
        color: textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontFamily: fontFamily,
      ),
    );
  }
}
