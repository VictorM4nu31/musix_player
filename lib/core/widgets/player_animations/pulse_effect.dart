import 'package:flutter/material.dart';

/// Expanding rings outside the artwork bounds.
class PulseEffect extends StatefulWidget {
  const PulseEffect({
    super.key,
    required this.isPlaying,
    required this.size,
    required this.child,
  });

  final bool isPlaying;
  final double size;
  final Widget child;

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
      duration: const Duration(milliseconds: 1800),
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
    final primary = Theme.of(context).colorScheme.primary;
    // Artwork sits inset so rings are visible around it.
    final artPad = widget.size * 0.10;

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _PulsePainter(
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
    final maxR = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    for (var i = 0; i < 3; i++) {
      final phase = (progress + i * 0.33) % 1.0;
      // Start near artwork edge (~0.78) and expand outward.
      final radius = maxR * (0.78 + phase * 0.22);
      final opacity = isPlaying
          ? ((1.0 - phase) * 110).toInt().clamp(0, 110)
          : 24;
      paint.color = color.withAlpha(opacity);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PulsePainter oldDelegate) =>
      progress != oldDelegate.progress ||
      isPlaying != oldDelegate.isPlaying ||
      color != oldDelegate.color;
}
