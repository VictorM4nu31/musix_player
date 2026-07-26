import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Deterministic wave rings outside the artwork (no per-frame Random).
class AudioWaves extends StatefulWidget {
  const AudioWaves({
    super.key,
    required this.isPlaying,
    required this.size,
    required this.child,
  });

  final bool isPlaying;
  final double size;
  final Widget child;

  @override
  State<AudioWaves> createState() => _AudioWavesState();
}

class _AudioWavesState extends State<AudioWaves>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AudioWaves oldWidget) {
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
    final artPad = widget.size * 0.12;

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _WavePainter(
                color: primary,
                progress: _controller.value,
                isPlaying: widget.isPlaying,
              ),
            );
          },
        ),
        Padding(
          padding: EdgeInsets.all(artPad),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.size * 0.08),
            child: widget.child,
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
  });

  final Color color;
  final double progress;
  final bool isPlaying;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final base = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeJoin = StrokeJoin.round;

    for (var ring = 0; ring < 3; ring++) {
      final ringBase = base * (0.78 + ring * 0.07);
      final opacity = (90 - ring * 22).clamp(20, 90);
      paint.color = color.withAlpha(isPlaying ? opacity : 28);

      final path = Path();
      const steps = 72;
      for (var i = 0; i <= steps; i++) {
        final t = i / steps;
        final angle = t * 2 * math.pi;
        final amp = isPlaying ? 1.0 : 0.15;
        final wave = math.sin(angle * 4 + progress * 2 * math.pi + ring) *
            amp *
            (base * 0.035);
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
      color != oldDelegate.color;
}
