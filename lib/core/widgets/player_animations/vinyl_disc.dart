import 'dart:math';
import 'package:flutter/material.dart';

class VinylDisc extends StatefulWidget {
  const VinylDisc({super.key, required this.isPlaying, required this.size});

  final bool isPlaying;
  final double size;

  @override
  State<VinylDisc> createState() => _VinylDiscState();
}

class _VinylDiscState extends State<VinylDisc>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(VinylDisc oldWidget) {
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
        return Transform.rotate(
          angle: _controller.value * 2 * pi,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _VinylPainter(color: primaryColor),
          ),
        );
      },
    );
  }
}

class _VinylPainter extends CustomPainter {
  _VinylPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()..style = PaintingStyle.stroke;

    paint.color = color.withAlpha(25);
    paint.strokeWidth = 1.0;

    for (int i = 1; i <= 8; i++) {
      final r = radius * (0.3 + i * 0.08);
      canvas.drawCircle(center, r, paint);
    }

    paint
      ..style = PaintingStyle.fill
      ..color = color.withAlpha(15);
    canvas.drawCircle(center, radius * 0.95, paint);

    paint.color = color.withAlpha(40);
    canvas.drawCircle(center, radius * 0.35, paint);

    paint.color = color.withAlpha(80);
    canvas.drawCircle(center, radius * 0.08, paint);
  }

  @override
  bool shouldRepaint(_VinylPainter oldDelegate) => false;
}
