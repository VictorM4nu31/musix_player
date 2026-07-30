import 'package:flutter/material.dart';
import '../models/visualizer_frame.dart';
import '../models/visualizer_type.dart';
import 'visualizer_renderer.dart';

class PulseRenderer extends VisualizerRenderer {
  const PulseRenderer();

  @override
  VisualizerType get type => VisualizerType.pulse;

  @override
  Widget build(BuildContext context, VisualizerFrame frame) {
    return _PulseView(frame: frame);
  }
}

class _PulseView extends StatefulWidget {
  const _PulseView({required this.frame});

  final VisualizerFrame frame;

  @override
  State<_PulseView> createState() => _PulseViewState();
}

class _PulseViewState extends State<_PulseView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _sync(widget.frame);
  }

  @override
  void didUpdateWidget(covariant _PulseView oldWidget) {
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
    final artPad = frame.size * 0.10;
    final radius = frame.tokens?.artworkRadius ?? frame.size * 0.08;

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              size: Size(frame.size, frame.size),
              painter: _PulsePainter(
                color: primary,
                progress: _controller.value,
                isPlaying: frame.isPlaying,
                reactive: frame.reactive,
                intensity: frame.intensity,
              ),
            );
          },
        ),
        Padding(
          padding: EdgeInsets.all(artPad),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: frame.artwork,
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
    required this.reactive,
    required this.intensity,
  });

  final Color color;
  final double progress;
  final bool isPlaying;
  final double reactive;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2 + reactive * 1.5;

    final expand = 0.18 + reactive * 0.08;

    for (var i = 0; i < 3; i++) {
      final phase = (progress + i * 0.33) % 1.0;
      final radius = maxR * (0.78 + phase * expand);
      final opacity = isPlaying
          ? (((1.0 - phase) * (90 + intensity * 40) + reactive * 30)
                  .toInt())
              .clamp(0, 130)
          : 22;
      paint.color = color.withAlpha(opacity);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PulsePainter oldDelegate) =>
      progress != oldDelegate.progress ||
      isPlaying != oldDelegate.isPlaying ||
      reactive != oldDelegate.reactive ||
      intensity != oldDelegate.intensity ||
      color != oldDelegate.color;
}
