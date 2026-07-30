import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/audio_features.dart';
import 'shader_type.dart';

class ShaderPainter extends CustomPainter {
  ShaderPainter({
    required this.effectType,
    required this.features,
    required this.time,
    required this.intensity,
    required this.isPlaying,
    required this.primaryColor,
  });

  final ShaderEffectType effectType;
  final AudioFeatures features;
  final double time;
  final double intensity;
  final bool isPlaying;
  final Color primaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    _paintEffect(canvas, size);
  }

  void _paintEffect(Canvas canvas, Size size) {
    switch (effectType) {
      case ShaderEffectType.aurora:
        _paintAurora(canvas, size);
      case ShaderEffectType.ripple:
        _paintRipple(canvas, size);
      case ShaderEffectType.neon:
        _paintNeon(canvas, size);
    }
  }

  void _paintAurora(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final t = time * 0.25;
    final energy = features.energy;
    final bass = features.bass;

    for (var band = 0; band < 3; band++) {
      final path = Path();
      final double bandOffset;
      final List<Color> colors;
      switch (band) {
        case 0:
          bandOffset = 0;
          colors = [
            Color.lerp(
              HSLColor.fromAHSL(1, 165, 0.8, 0.35).toColor(),
              HSLColor.fromAHSL(1, 145, 0.9, 0.55).toColor(),
              energy,
            )!,
            Colors.transparent,
          ];
        case 1:
          bandOffset = 2.1;
          colors = [
            Color.lerp(
              HSLColor.fromAHSL(1, 265, 0.7, 0.4).toColor(),
              HSLColor.fromAHSL(1, 285, 0.8, 0.55).toColor(),
              energy,
            )!,
            Colors.transparent,
          ];
        default:
          bandOffset = 4.3;
          colors = [
            Color.lerp(
              HSLColor.fromAHSL(1, 140, 0.9, 0.3).toColor(),
              HSLColor.fromAHSL(1, 160, 1.0, 0.5).toColor(),
              energy,
            )!,
            Colors.transparent,
          ];
      }

      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ).createShader(Offset.zero & size)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

      final waveFreq = 3.0 + band * 1.5;
      final waveAmp = 0.08 + band * 0.04 + bass * 0.04;

      path.moveTo(0, h);
      for (var x = 0.0; x <= w; x += 2) {
        final nx = x / w;
        final y = h * (0.3 + band * 0.15) +
            math.sin(nx * waveFreq * math.pi + t + bandOffset) * h * waveAmp +
            math.sin(nx * (waveFreq + 1.5) * math.pi - t * 0.6 + bandOffset) *
                h *
                waveAmp *
                0.5;
        path.lineTo(x, y);
      }
      path.lineTo(w, h);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  void _paintRipple(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width * 0.45;
    final t = time * 0.6;
    final energy = features.energy;
    final bass = features.bass;
    final beat = features.beatPulse;

    final rippleCount = 3 + (energy * 2).round();
    for (var i = 0; i < rippleCount; i++) {
      final phase = (t * 1.5 + i * 0.33 + beat * 0.5) % 1.0;
      final radius = maxR * (0.1 + phase * 0.9);
      final alpha = ((1.0 - phase) * 120 + energy * 60 + beat * 80)
          .round()
          .clamp(20, 200);
      final width = (1.5 + energy * 2.5 + bass * 2.0).clamp(1.0, 6.0);

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          width * 1.5,
        );

      final hue = (i * 40 + t * 30) % 360;
      paint.color = HSLColor.fromAHSL(
        1,
        hue,
        0.7,
        0.5 + energy * 0.2,
      ).toColor().withAlpha(alpha);

      canvas.drawCircle(center, radius, paint);
    }
  }

  void _paintNeon(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseR = size.width * 0.32;
    final t = time;
    final energy = features.energy;
    final bass = features.bass;
    final beat = features.beatPulse;

    final pulse = (math.sin(t * 1.5 + bass * 3.0) * 0.5 + 0.5);
    final beatFlash = beat > 0.3 ? beat : 0.0;

    for (var ring = 0; ring < 3; ring++) {
      final radius = baseR + ring * (14 + bass * 8);
      final baseAlpha = (40 + pulse * 60 + beatFlash * 100)
          .round()
          .clamp(20, 200);
      final width = (2.0 + pulse * 2.0 + energy * 1.5).clamp(1.5, 6.0);

      final hue = (ring * 120 + t * 20) % 360;
      final color = HSLColor.fromAHSL(1, hue, 0.9, 0.5 + pulse * 0.2).toColor();

      // Glow
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width * 2.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12)
        ..color = color.withAlpha((baseAlpha * 0.3).round());
      canvas.drawCircle(center, radius, glow);

      // Core line
      final line = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..color = color.withAlpha(baseAlpha);
      canvas.drawCircle(center, radius, line);
    }

    // Center flash on beat
    if (beat > 0.1) {
      final flash = Paint()
        ..color = Colors.white.withAlpha((beat * 150).round().clamp(0, 180))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawCircle(center, baseR * 0.3, flash);
    }
  }

  @override
  bool shouldRepaint(covariant ShaderPainter oldDelegate) => true;
}
