import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/audio_features.dart';
import '../models/visual_quality.dart';
import '../models/visualizer_frame.dart';
import '../models/visualizer_type.dart';
import 'visualizer_renderer.dart';

/// Frequency-style spectrum around or below the artwork (pseudo bands).
class SpectrumRenderer extends VisualizerRenderer {
  const SpectrumRenderer();

  @override
  VisualizerType get type => VisualizerType.spectrum;

  @override
  Widget build(BuildContext context, VisualizerFrame frame) {
    return _SpectrumView(frame: frame);
  }
}

class _SpectrumView extends StatefulWidget {
  const _SpectrumView({required this.frame});

  final VisualizerFrame frame;

  @override
  State<_SpectrumView> createState() => _SpectrumViewState();
}

class _SpectrumViewState extends State<_SpectrumView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _sync(widget.frame);
  }

  @override
  void didUpdateWidget(covariant _SpectrumView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(widget.frame);
  }

  void _sync(VisualizerFrame frame) {
    final run = frame.isPlaying && !frame.reduceMotion;
    if (run && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!run && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frame = widget.frame;
    final primary =
        frame.primaryColor ?? Theme.of(context).colorScheme.primary;
    final quality = frame.settings.quality;
    final circular = quality != VisualQuality.low;
    final artPad = circular ? frame.size * 0.14 : frame.size * 0.08;
    final radius = frame.tokens?.artworkRadius ?? frame.size * 0.08;

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              size: Size(frame.size, frame.size),
              painter: circular
                  ? _CircularSpectrumPainter(
                      color: primary,
                      progress: _controller.value,
                      features: frame.features,
                      isPlaying: frame.isPlaying,
                      intensity: frame.intensity,
                      barCount: quality == VisualQuality.ultra
                          ? 48
                          : quality == VisualQuality.high
                              ? 36
                              : 28,
                    )
                  : _BarSpectrumPainter(
                      color: primary,
                      progress: _controller.value,
                      features: frame.features,
                      isPlaying: frame.isPlaying,
                      intensity: frame.intensity,
                      barCount: 20,
                    ),
            );
          },
        ),
        Padding(
          padding: EdgeInsets.all(artPad),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              circular ? 999 : radius,
            ),
            child: frame.artwork,
          ),
        ),
      ],
    );
  }
}

class _CircularSpectrumPainter extends CustomPainter {
  _CircularSpectrumPainter({
    required this.color,
    required this.progress,
    required this.features,
    required this.isPlaying,
    required this.intensity,
    required this.barCount,
  });

  final Color color;
  final double progress;
  final AudioFeatures features;
  final bool isPlaying;
  final double intensity;
  final int barCount;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseR = size.width * 0.36;
    final maxLen = size.width * 0.12;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = (size.width / barCount * 0.55).clamp(2.0, 5.0);

    for (var i = 0; i < barCount; i++) {
      final t = i / barCount;
      final angle = t * math.pi * 2 - math.pi / 2;
      final band = features.bands.isEmpty
          ? (isPlaying
              ? 0.3 +
                  0.4 *
                      (0.5 +
                          0.5 *
                              math.sin(
                                progress * math.pi * 2 + i * 0.4,
                              ))
              : 0.12)
          : features.bandAt(
              (i * features.bands.length / barCount).floor(),
            );

      final wobble = isPlaying
          ? 0.08 *
              math.sin(progress * math.pi * 2 * 2 + i * 0.55 + features.beatPulse)
          : 0.0;
      final level = (band + wobble).clamp(0.08, 1.0) * intensity.clamp(0.2, 1.0);
      final len = maxLen * (isPlaying ? level : 0.12);

      final x0 = center.dx + math.cos(angle) * baseR;
      final y0 = center.dy + math.sin(angle) * baseR;
      final x1 = center.dx + math.cos(angle) * (baseR + len);
      final y1 = center.dy + math.sin(angle) * (baseR + len);

      final alpha = isPlaying ? (90 + level * 140).round().clamp(40, 230) : 40;
      paint.color = color.withAlpha(alpha);
      canvas.drawLine(Offset(x0, y0), Offset(x1, y1), paint);
    }

    // Soft ring under bars
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color.withAlpha(isPlaying ? 50 : 24);
    canvas.drawCircle(center, baseR * 0.98, ring);
  }

  @override
  bool shouldRepaint(covariant _CircularSpectrumPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      features != oldDelegate.features ||
      isPlaying != oldDelegate.isPlaying ||
      intensity != oldDelegate.intensity ||
      color != oldDelegate.color ||
      barCount != oldDelegate.barCount;
}

class _BarSpectrumPainter extends CustomPainter {
  _BarSpectrumPainter({
    required this.color,
    required this.progress,
    required this.features,
    required this.isPlaying,
    required this.intensity,
    required this.barCount,
  });

  final Color color;
  final double progress;
  final AudioFeatures features;
  final bool isPlaying;
  final double intensity;
  final int barCount;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final gap = size.width * 0.012;
    final barW = (size.width - gap * (barCount - 1)) / barCount;
    final baseY = size.height * 0.92;
    final maxH = size.height * 0.28;

    for (var i = 0; i < barCount; i++) {
      final band = features.bands.isEmpty
          ? (isPlaying
              ? 0.35 +
                  0.45 *
                      (0.5 +
                          0.5 *
                              math.sin(progress * math.pi * 2 + i * 0.35))
              : 0.15)
          : features.bandAt(
              (i * math.max(features.bands.length, 1) / barCount).floor(),
            );
      final h = maxH *
          (isPlaying ? band.clamp(0.1, 1.0) : 0.12) *
          intensity.clamp(0.25, 1.0);
      final x = i * (barW + gap);
      paint.color = color.withAlpha(isPlaying ? 190 : 70);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, baseY - h, barW, h),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BarSpectrumPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      features != oldDelegate.features ||
      isPlaying != oldDelegate.isPlaying ||
      intensity != oldDelegate.intensity ||
      color != oldDelegate.color;
}
