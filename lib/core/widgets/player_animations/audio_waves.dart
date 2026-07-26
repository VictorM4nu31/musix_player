import 'dart:math';
import 'package:flutter/material.dart';

class AudioWaves extends StatefulWidget {
  const AudioWaves({super.key, required this.isPlaying, required this.size});

  final bool isPlaying;
  final double size;

  @override
  State<AudioWaves> createState() => _AudioWavesState();
}

class _AudioWavesState extends State<AudioWaves>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
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
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _WavePainter(
            color: primaryColor,
            progress: _controller.value,
            isPlaying: widget.isPlaying,
            random: _random,
          ),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter({
    required this.color,
    required this.progress,
    required this.isPlaying,
    required this.random,
  });

  final Color color;
  final double progress;
  final bool isPlaying;
  final Random random;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int ring = 1; ring <= 4; ring++) {
      final ringRadius = radius * (0.55 + ring * 0.1);
      final opacity = (1.0 - ring * 0.2).clamp(0.0, 1.0);
      paint.color = color.withAlpha((opacity * 100).toInt());

      final path = Path();
      for (int i = 0; i <= 360; i += 3) {
        final angle = i * pi / 180;
        final amp = isPlaying ? 0.3 + random.nextDouble() * 0.7 : 0.15;
        final wave = sin(angle * 3 + progress * 2 * pi) * amp * 8;
        final r = ringRadius + wave;
        final x = center.dx + cos(angle) * r;
        final y = center.dy + sin(angle) * r;
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
  bool shouldRepaint(_WavePainter oldDelegate) =>
      progress != oldDelegate.progress || isPlaying != oldDelegate.isPlaying;
}
