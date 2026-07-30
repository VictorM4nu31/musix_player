import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/audio_features.dart';
import '../models/visualizer_frame.dart';
import '../models/visualizer_type.dart';
import 'visualizer_renderer.dart';

class WavesRenderer extends VisualizerRenderer {
  const WavesRenderer();

  @override
  VisualizerType get type => VisualizerType.waves;

  @override
  Widget build(BuildContext context, VisualizerFrame frame) {
    return _WavesView(frame: frame);
  }
}

class _WavesView extends StatefulWidget {
  const _WavesView({required this.frame});

  final VisualizerFrame frame;

  @override
  State<_WavesView> createState() => _WavesViewState();
}

class _WavesViewState extends State<_WavesView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _sync(widget.frame);
  }

  @override
  void didUpdateWidget(covariant _WavesView oldWidget) {
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
    final artPad = frame.size * 0.12;
    final radius = frame.tokens?.artworkRadius ?? frame.size * 0.08;

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              size: Size(frame.size, frame.size),
              painter: _WavePainter(
                color: primary,
                progress: _controller.value,
                isPlaying: frame.isPlaying,
                ampBoost: 0.035 + frame.reactive * 0.04,
                features: frame.features,
              ),
            );
          },
        ),
        Padding(
          padding: EdgeInsets.all(artPad),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: frame.artwork,
          ),
        ),
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.color,
    required this.progress,
    required this.isPlaying,
    required this.ampBoost,
    required this.features,
  });

  final Color color;
  final double progress;
  final bool isPlaying;
  final double ampBoost;
  final AudioFeatures features;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final base = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;

    final bass = features.bass;

    for (var ring = 0; ring < 3; ring++) {
      final ringBase = base * (0.78 + ring * 0.07 + bass * 0.02);
      final opacity = ((90 - ring * 22) + bass * 30).round().clamp(20, 120);
      paint.color = color.withAlpha(isPlaying ? opacity : 28);

      final path = Path();
      const steps = 72;
      for (var i = 0; i <= steps; i++) {
        final t = i / steps;
        final angle = t * 2 * math.pi;
        final amp = isPlaying ? 1.0 : 0.15;
        final wave = math.sin(angle * 4 + progress * 2 * math.pi + ring) *
            amp *
            (base * ampBoost);
        final r = ringBase + wave;
        final x = center.dx + math.cos(angle) * r;
        final y = center.dy + math.sin(angle) * r;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      progress != oldDelegate.progress ||
      isPlaying != oldDelegate.isPlaying ||
      ampBoost != oldDelegate.ampBoost ||
      color != oldDelegate.color;
}
