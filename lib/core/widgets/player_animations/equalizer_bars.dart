import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Equalizer bars rendered below the artwork (always visible).
class EqualizerBars extends StatefulWidget {
  const EqualizerBars({
    super.key,
    required this.isPlaying,
    required this.size,
    required this.child,
  });

  final bool isPlaying;
  final double size;
  final Widget child;

  @override
  State<EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<EqualizerBars>
    with SingleTickerProviderStateMixin {
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
    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(EqualizerBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isPlaying && _controller.isAnimating) {
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
    final primary = Theme.of(context).colorScheme.primary;
    final artFraction = 0.78;
    final artSize = widget.size * artFraction;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Artwork upper-centered
        Align(
          alignment: const Alignment(0, -0.35),
          child: SizedBox(
            width: artSize,
            height: artSize,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(artSize * 0.08),
              child: widget.child,
            ),
          ),
        ),
        // Bars at bottom
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(bottom: widget.size * 0.04),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  size: Size(widget.size * 0.7, widget.size * 0.18),
                  painter: _EqPainter(
                    color: primary,
                    progress: _controller.value,
                    isPlaying: widget.isPlaying,
                    phases: _phases,
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
  });

  final Color color;
  final double progress;
  final bool isPlaying;
  final List<double> phases;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final n = phases.length;
    final gap = size.width * 0.06;
    final barW = (size.width - gap * (n - 1)) / n;
    final maxH = size.height;

    for (var i = 0; i < n; i++) {
      final wave = isPlaying
          ? (0.35 +
              0.65 *
                  (0.5 +
                      0.5 *
                          math.sin(
                            (progress + phases[i]) * 2 * math.pi,
                          )))
          : 0.22;
      final h = maxH * wave;
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
      color != oldDelegate.color;
}
