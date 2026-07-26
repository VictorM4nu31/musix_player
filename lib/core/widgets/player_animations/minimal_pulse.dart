import 'dart:math';
import 'package:flutter/material.dart';

class MinimalPulse extends StatefulWidget {
  const MinimalPulse({super.key, required this.isPlaying, required this.size});

  final bool isPlaying;
  final double size;

  @override
  State<MinimalPulse> createState() => _MinimalPulseState();
}

class _MinimalPulseState extends State<MinimalPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(MinimalPulse oldWidget) {
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
          painter: _MinimalPainter(
            color: primaryColor,
            progress: _controller.value,
            isPlaying: widget.isPlaying,
          ),
        );
      },
    );
  }
}

class _MinimalPainter extends CustomPainter {
  _MinimalPainter({
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
    final radius = size.width / 2;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5;

    final scale = isPlaying ? 1.0 + sin(progress * 2 * 3.14159) * 0.02 : 1.0;
    final scaledRadius = radius * 0.52 * scale;

    paint.color = color.withAlpha(60);
    canvas.drawCircle(center, scaledRadius, paint);
  }

  @override
  bool shouldRepaint(_MinimalPainter oldDelegate) =>
      progress != oldDelegate.progress || isPlaying != oldDelegate.isPlaying;
}
