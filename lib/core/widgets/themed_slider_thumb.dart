import 'package:flutter/material.dart';
import '../../app/theme/theme_tokens.dart';

/// Square thumb used by pixel / hard-edged themes.
class SquareSliderThumbShape extends SliderComponentShape {
  const SquareSliderThumbShape({
    this.enabledThumbSize = 14,
    this.disabledThumbSize = 12,
    this.elevation = 1,
    this.pressedElevation = 2,
  });

  final double enabledThumbSize;
  final double disabledThumbSize;
  final double elevation;
  final double pressedElevation;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    final s = isEnabled ? enabledThumbSize : disabledThumbSize;
    return Size(s, s);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final sizeTween = Tween<double>(
      begin: disabledThumbSize,
      end: enabledThumbSize,
    );
    final size = sizeTween.evaluate(enableAnimation);
    final color = ColorTween(
      begin: sliderTheme.disabledThumbColor,
      end: sliderTheme.thumbColor,
    ).evaluate(enableAnimation)!;

    final elev = Tween<double>(
      begin: elevation,
      end: pressedElevation,
    ).evaluate(activationAnimation);

    final rect = Rect.fromCenter(center: center, width: size, height: size);
    final path = Path()..addRect(rect);

    canvas.drawShadow(path, Colors.black, elev, true);
    canvas.drawRect(rect, Paint()..color = color);
  }
}

SliderComponentShape thumbShapeFor(SliderThumbStyle style) {
  return switch (style) {
    SliderThumbStyle.square => const SquareSliderThumbShape(),
    SliderThumbStyle.pill => const RoundSliderThumbShape(
        enabledThumbRadius: 8,
        disabledThumbRadius: 6,
      ),
    SliderThumbStyle.round => const RoundSliderThumbShape(
        enabledThumbRadius: 6,
        disabledThumbRadius: 4,
      ),
  };
}

SliderThemeData sliderThemeFromTokens(
  ThemeData theme,
  MusixThemeTokens tokens,
) {
  final base = theme.sliderTheme;
  return base.copyWith(
    trackHeight: tokens.sliderThumbStyle == SliderThumbStyle.square ? 6 : 4,
    thumbShape: thumbShapeFor(tokens.sliderThumbStyle),
    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
    activeTrackColor: theme.colorScheme.primary,
    inactiveTrackColor: theme.colorScheme.primary.withAlpha(40),
    thumbColor: theme.colorScheme.primary,
    overlayColor: theme.colorScheme.primary.withAlpha(30),
  );
}
