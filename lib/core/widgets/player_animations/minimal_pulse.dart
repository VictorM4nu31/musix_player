import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Subtle scale pulse of the artwork while playing.
class MinimalPulse extends StatefulWidget {
  const MinimalPulse({
    super.key,
    required this.isPlaying,
    required this.size,
    required this.child,
  });

  final bool isPlaying;
  final double size;
  final Widget child;

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
      duration: const Duration(milliseconds: 2200),
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
    final primary = Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale = widget.isPlaying
            ? 1.0 + math.sin(_controller.value * 2 * math.pi) * 0.03
            : 1.0;
        return Transform.scale(
          scale: scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.size * 0.08),
              boxShadow: [
                BoxShadow(
                  color: primary.withAlpha(widget.isPlaying ? 50 : 20),
                  blurRadius: widget.isPlaying ? 24 : 12,
                  spreadRadius: widget.isPlaying ? 2 : 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.size * 0.08),
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}
