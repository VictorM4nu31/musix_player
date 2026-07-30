import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/visualizer_frame.dart';
import '../models/visualizer_type.dart';
import 'visualizer_renderer.dart';

class MinimalRenderer extends VisualizerRenderer {
  const MinimalRenderer();

  @override
  VisualizerType get type => VisualizerType.minimal;

  @override
  Widget build(BuildContext context, VisualizerFrame frame) {
    return _MinimalView(frame: frame);
  }
}

class _MinimalView extends StatefulWidget {
  const _MinimalView({required this.frame});

  final VisualizerFrame frame;

  @override
  State<_MinimalView> createState() => _MinimalViewState();
}

class _MinimalViewState extends State<_MinimalView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _sync(widget.frame);
  }

  @override
  void didUpdateWidget(covariant _MinimalView oldWidget) {
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
    final radius = frame.tokens?.artworkRadius ?? frame.size * 0.08;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final base = frame.isPlaying
            ? math.sin(_controller.value * 2 * math.pi) * 0.025
            : 0.0;
        final reactive = frame.reactive * 0.04;
        final scale = 1.0 + base + reactive;
        final glowAlpha =
            ((frame.isPlaying ? 40 : 16) + frame.reactive * 50).round().clamp(0, 90);

        return Transform.scale(
          scale: scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: primary.withAlpha(glowAlpha),
                  blurRadius: 16 + frame.reactive * 16,
                  spreadRadius: frame.reactive * 3,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: child,
            ),
          ),
        );
      },
      child: frame.artwork,
    );
  }
}
