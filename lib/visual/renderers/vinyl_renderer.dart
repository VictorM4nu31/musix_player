import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/visualizer_frame.dart';
import '../models/visualizer_type.dart';
import 'visualizer_renderer.dart';

class VinylRenderer extends VisualizerRenderer {
  const VinylRenderer();

  @override
  VisualizerType get type => VisualizerType.vinyl;

  @override
  Widget build(BuildContext context, VisualizerFrame frame) {
    return _VinylView(frame: frame);
  }
}

class _VinylView extends StatefulWidget {
  const _VinylView({required this.frame});

  final VisualizerFrame frame;

  @override
  State<_VinylView> createState() => _VinylViewState();
}

class _VinylViewState extends State<_VinylView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Base 24s/rev; reactive shortens slightly when energy high.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    );
    _sync(widget.frame);
  }

  @override
  void didUpdateWidget(covariant _VinylView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final energy = widget.frame.features.energy;
    final seconds = (24.0 - energy * 6.0 * widget.frame.intensity)
        .clamp(16.0, 24.0);
    final next = Duration(milliseconds: (seconds * 1000).round());
    if (_controller.duration != next) {
      final value = _controller.value;
      _controller.duration = next;
      _controller.value = value;
    }
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
    final theme = Theme.of(context);
    final primary =
        frame.primaryColor ?? theme.colorScheme.primary;
    final discInset = frame.size * 0.06;

    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size(frame.size, frame.size),
          painter: _OuterGroovePainter(
            color: primary,
            reactive: frame.reactive,
          ),
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
            child: ClipOval(child: frame.artwork),
          ),
        ),
        IgnorePointer(
          child: Container(
            width: frame.size * 0.12,
            height: frame.size * 0.12,
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
  _OuterGroovePainter({required this.color, required this.reactive});

  final Color color;
  final double reactive;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (var i = 0; i < 5; i++) {
      paint.color = color.withAlpha((18 + i * 8 + reactive * 20).round().clamp(0, 80));
      canvas.drawCircle(center, radius * (0.92 + i * 0.015), paint);
    }

    paint
      ..style = PaintingStyle.fill
      ..color = color.withAlpha((20 + reactive * 25).round().clamp(0, 55));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _OuterGroovePainter oldDelegate) =>
      color != oldDelegate.color || reactive != oldDelegate.reactive;
}
