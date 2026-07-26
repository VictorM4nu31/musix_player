import 'package:flutter/material.dart';

class PulseEffect extends StatefulWidget {
  const PulseEffect({super.key, required this.isPlaying, required this.size});

  final bool isPlaying;
  final double size;

  @override
  State<PulseEffect> createState() => _PulseEffectState();
}

class _PulseEffectState extends State<PulseEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(PulseEffect oldWidget) {
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
          painter: _PulsePainter(
            color: primaryColor,
            progress: _controller.value,
            isPlaying: widget.isPlaying,
          ),
        );
      },
    );
  }
}

class _PulsePainter extends CustomPainter {
  _PulsePainter({
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
    final maxRadius = size.width / 2;
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.0;

    for (int i = 0; i < 3; i++) {
      final phase = (progress + i * 0.33) % 1.0;
      final radius = maxRadius * (0.45 + phase * 0.55);
      final opacity = ((1.0 - phase) * 80).toInt().clamp(0, 80);
      paint.color = color.withAlpha(isPlaying ? opacity : 20);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_PulsePainter oldDelegate) =>
      progress != oldDelegate.progress || isPlaying != oldDelegate.isPlaying;
}
