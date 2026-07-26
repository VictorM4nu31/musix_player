import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/theme/pixel_art_theme.dart';

class PixelBorder extends StatelessWidget {
  const PixelBorder({
    super.key,
    required this.child,
    this.color,
    this.width = 1.5,
    this.padding = const EdgeInsets.all(2),
    this.borderRadius = 4,
  });

  final Widget child;
  final Color? color;
  final double width;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPixelArt = theme.brightness == Brightness.dark &&
        theme.scaffoldBackgroundColor == PixelArtColors.background;
    final borderColor = color ?? (isPixelArt ? PixelArtColors.border : theme.colorScheme.primary);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor, width: width),
      ),
      child: child,
    );
  }
}

class PixelDecoration extends Decoration {
  const PixelDecoration({
    this.color,
    this.borderColor,
    this.borderWidth = 1.5,
    this.cornerSize = 4,
  });

  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final double cornerSize;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _PixelDecorationPainter(
      color: color,
      borderColor: borderColor,
      borderWidth: borderWidth,
      cornerSize: cornerSize,
    );
  }
}

class _PixelDecorationPainter extends BoxPainter {
  _PixelDecorationPainter({
    this.color,
    this.borderColor,
    required this.borderWidth,
    required this.cornerSize,
  });

  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final double cornerSize;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final rect = offset & cfg.size!;
    final paint = Paint()
      ..color = color ?? Colors.transparent
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect.deflate(borderWidth / 2), paint);

    if (borderColor != null) {
      final borderPaint = Paint()
        ..color = borderColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawRect(rect.deflate(borderWidth / 2), borderPaint);

      _drawCornerPixels(canvas, rect, borderPaint);
    }
  }

  void _drawCornerPixels(Canvas canvas, Rect rect, Paint paint) {
    final s = cornerSize;
    final halfW = borderWidth / 2;

    final corners = [
      Offset(rect.left + halfW, rect.top + halfW),
      Offset(rect.right - halfW, rect.top + halfW),
      Offset(rect.left + halfW, rect.bottom - halfW),
      Offset(rect.right - halfW, rect.bottom - halfW),
    ];

    for (final corner in corners) {
      for (final dx in [-s, 0, s]) {
        for (final dy in [-s, 0, s]) {
          final dist = math.sqrt(dx * dx + dy * dy);
          if (dist <= s) {
            canvas.drawCircle(
              corner + Offset(dx.toDouble(), dy.toDouble()),
              borderWidth / 2,
              paint,
            );
          }
        }
      }
    }
  }
}
