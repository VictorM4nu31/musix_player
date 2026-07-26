import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Rotates the artwork itself while playing (visible vinyl effect).
class VinylDisc extends StatefulWidget {
  const VinylDisc({
    super.key,
    required this.isPlaying,
    required this.size,
    required this.child,
  });

  final bool isPlaying;
  final double size;
  final Widget child;

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
      duration: const Duration(seconds: 24),
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
    final primary = theme.colorScheme.primary;
    final discInset = widget.size * 0.06;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer ring groove (visible around circular art)
        CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _OuterGroovePainter(color: primary),
        ),
        Padding(
          padding: EdgeInsets.all(discInset),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: child,
              );
            },
            child: ClipOval(child: widget.child),
          ),
        ),
        // Center spindle
        IgnorePointer(
          child: Container(
            width: widget.size * 0.12,
            height: widget.size * 0.12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.scaffoldBackgroundColor.withAlpha(200),
              border: Border.all(color: primary.withAlpha(120), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OuterGroovePainter extends CustomPainter {
  _OuterGroovePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (var i = 0; i < 5; i++) {
      paint.color = color.withAlpha(18 + i * 8);
      canvas.drawCircle(center, radius * (0.92 + i * 0.015), paint);
    }

    paint
      ..style = PaintingStyle.fill
      ..color = color.withAlpha(20);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _OuterGroovePainter oldDelegate) =>
      color != oldDelegate.color;
}
