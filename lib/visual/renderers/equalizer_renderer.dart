import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/audio_features.dart';
import '../models/visualizer_frame.dart';
import '../models/visualizer_type.dart';
import 'visualizer_renderer.dart';

class EqualizerRenderer extends VisualizerRenderer {
  const EqualizerRenderer();

  @override
  VisualizerType get type => VisualizerType.equalizer;

  @override
  Widget build(BuildContext context, VisualizerFrame frame) {
    return _EqView(frame: frame);
  }
}

class _EqView extends StatefulWidget {
  const _EqView({required this.frame});

  final VisualizerFrame frame;

  @override
  State<_EqView> createState() => _EqViewState();
}

class _EqViewState extends State<_EqView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const _barCount = 5;
  late final List<double> _phases;

  @override
  void initState() {
    super.initState();
    _phases = List.generate(_barCount, (i) => i * 0.35);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _sync(widget.frame);
  }

  @override
  void didUpdateWidget(covariant _EqView oldWidget) {
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
    final artFraction = 0.78;
    final artSize = frame.size * artFraction;
    final radius = frame.tokens?.artworkRadius ?? artSize * 0.08;

    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: const Alignment(0, -0.35),
          child: SizedBox(
            width: artSize,
            height: artSize,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: frame.artwork,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: frame.size * 0.04),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  size: Size(frame.size * 0.7, frame.size * 0.18),
                  painter: _EqPainter(
                    color: primary,
                    progress: _controller.value,
                    isPlaying: frame.isPlaying,
                    phases: _phases,
                    features: frame.features,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _EqPainter extends CustomPainter {
  _EqPainter({
    required this.color,
    required this.progress,
    required this.isPlaying,
    required this.phases,
    required this.features,
  });

  final Color color;
  final double progress;
  final bool isPlaying;
  final List<double> phases;
  final AudioFeatures features;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final n = phases.length;
    final gap = size.width * 0.06;
    final barW = (size.width - gap * (n - 1)) / n;
    final maxH = size.height;

    final bands = [
      features.bass,
      (features.bass + features.mid) * 0.5,
      features.mid,
      (features.mid + features.treble) * 0.5,
      features.treble,
    ];

    for (var i = 0; i < n; i++) {
      final wave = isPlaying
          ? (0.28 +
              0.45 *
                  (0.5 +
                      0.5 *
                          math.sin(
                            (progress + phases[i]) * 2 * math.pi,
                          )) +
              0.35 * bands[i.clamp(0, bands.length - 1)])
          : 0.22;
      final h = maxH * wave.clamp(0.12, 1.0);
      final x = i * (barW + gap);
      final y = maxH - h;
      paint.color = color.withAlpha(isPlaying ? 200 : 90);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barW, h),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _EqPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      isPlaying != oldDelegate.isPlaying ||
      features != oldDelegate.features ||
      color != oldDelegate.color;
}
