import 'package:flutter/material.dart';
import 'theme_id.dart';

enum SliderThumbStyle { round, square, pill }

@immutable
class MusixThemeTokens extends ThemeExtension<MusixThemeTokens> {
  const MusixThemeTokens({
    required this.id,
    required this.displayName,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.borderWidth,
    this.borderColor,
    required this.miniPlayerBackground,
    required this.playerGradientStart,
    required this.playerGradientEnd,
    this.enableScanlines = false,
    this.scanlineOpacity = 0.0,
    this.glowColor,
    this.cardShadows = const [],
    this.controlShadows = const [],
    this.sliderThumbStyle = SliderThumbStyle.round,
    this.playButtonSize = 64,
    required this.playButtonRadius,
    required this.artworkRadius,
    this.displayFontFamily,
    this.bodyFontFamily,
    this.fastAnim = const Duration(milliseconds: 150),
    this.mediumAnim = const Duration(milliseconds: 300),
    this.defaultCurve = Curves.easeInOut,
    this.preferFrameSteppedMotion = false,
    required this.previewColors,
    this.favoriteColor = const Color(0xFFE53935),
  });

  final ThemeId id;
  final String displayName;

  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double borderWidth;
  final Color? borderColor;

  final Color miniPlayerBackground;
  final Color playerGradientStart;
  final Color playerGradientEnd;

  final bool enableScanlines;
  final double scanlineOpacity;
  final Color? glowColor;
  final List<BoxShadow> cardShadows;
  final List<BoxShadow> controlShadows;

  final SliderThumbStyle sliderThumbStyle;
  final double playButtonSize;
  final BorderRadius playButtonRadius;
  final double artworkRadius;

  final String? displayFontFamily;
  final String? bodyFontFamily;

  final Duration fastAnim;
  final Duration mediumAnim;
  final Curve defaultCurve;
  final bool preferFrameSteppedMotion;

  /// Primary, background, onBackground — used by theme selector previews.
  final List<Color> previewColors;
  final Color favoriteColor;

  bool get isPixelArt => id == ThemeId.pixelArt;

  BorderRadius get radiusSmAll => BorderRadius.circular(radiusSm);
  BorderRadius get radiusMdAll => BorderRadius.circular(radiusMd);
  BorderRadius get radiusLgAll => BorderRadius.circular(radiusLg);

  @override
  MusixThemeTokens copyWith({
    ThemeId? id,
    String? displayName,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? borderWidth,
    Color? borderColor,
    Color? miniPlayerBackground,
    Color? playerGradientStart,
    Color? playerGradientEnd,
    bool? enableScanlines,
    double? scanlineOpacity,
    Color? glowColor,
    List<BoxShadow>? cardShadows,
    List<BoxShadow>? controlShadows,
    SliderThumbStyle? sliderThumbStyle,
    double? playButtonSize,
    BorderRadius? playButtonRadius,
    double? artworkRadius,
    String? displayFontFamily,
    String? bodyFontFamily,
    Duration? fastAnim,
    Duration? mediumAnim,
    Curve? defaultCurve,
    bool? preferFrameSteppedMotion,
    List<Color>? previewColors,
    Color? favoriteColor,
  }) {
    return MusixThemeTokens(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColor: borderColor ?? this.borderColor,
      miniPlayerBackground: miniPlayerBackground ?? this.miniPlayerBackground,
      playerGradientStart: playerGradientStart ?? this.playerGradientStart,
      playerGradientEnd: playerGradientEnd ?? this.playerGradientEnd,
      enableScanlines: enableScanlines ?? this.enableScanlines,
      scanlineOpacity: scanlineOpacity ?? this.scanlineOpacity,
      glowColor: glowColor ?? this.glowColor,
      cardShadows: cardShadows ?? this.cardShadows,
      controlShadows: controlShadows ?? this.controlShadows,
      sliderThumbStyle: sliderThumbStyle ?? this.sliderThumbStyle,
      playButtonSize: playButtonSize ?? this.playButtonSize,
      playButtonRadius: playButtonRadius ?? this.playButtonRadius,
      artworkRadius: artworkRadius ?? this.artworkRadius,
      displayFontFamily: displayFontFamily ?? this.displayFontFamily,
      bodyFontFamily: bodyFontFamily ?? this.bodyFontFamily,
      fastAnim: fastAnim ?? this.fastAnim,
      mediumAnim: mediumAnim ?? this.mediumAnim,
      defaultCurve: defaultCurve ?? this.defaultCurve,
      preferFrameSteppedMotion:
          preferFrameSteppedMotion ?? this.preferFrameSteppedMotion,
      previewColors: previewColors ?? this.previewColors,
      favoriteColor: favoriteColor ?? this.favoriteColor,
    );
  }

  @override
  MusixThemeTokens lerp(ThemeExtension<MusixThemeTokens>? other, double t) {
    if (other is! MusixThemeTokens) return this;
    if (t < 0.5) return this;
    return other;
  }
}

extension MusixThemeTokensX on BuildContext {
  MusixThemeTokens get musixTheme {
    final tokens = Theme.of(this).extension<MusixThemeTokens>();
    assert(tokens != null, 'MusixThemeTokens missing from ThemeData.extensions');
    return tokens!;
  }

  MusixThemeTokens? get musixThemeOrNull =>
      Theme.of(this).extension<MusixThemeTokens>();
}
