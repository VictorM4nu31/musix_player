import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/theme/pixel_art_theme.dart';

class ScanlineOverlay extends StatelessWidget {
  const ScanlineOverlay({super.key, this.opacity = 0.03});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    final isPixelArt = Theme.of(context).brightness == Brightness.dark &&
        Theme.of(context).scaffoldBackgroundColor == PixelArtColors.background;
    if (!isPixelArt) return const SizedBox.shrink();

    return IgnorePointer(
      child: CustomPaint(
        painter: _ScanlinePainter(opacity: opacity),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  _ScanlinePainter({required this.opacity});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withAlpha((opacity * 255).round())
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_ScanlinePainter oldDelegate) =>
      opacity != oldDelegate.opacity;
}

class GlowEffect extends StatefulWidget {
  const GlowEffect({
    super.key,
    required this.child,
    this.color,
    this.radius = 8,
    this.enabled = true,
  });

  final Widget child;
  final Color? color;
  final double radius;
  final bool enabled;

  @override
  State<GlowEffect> createState() => _GlowEffectState();
}

class _GlowEffectState extends State<GlowEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: (widget.color ?? PixelArtColors.glow)
                    .withAlpha((_glowAnimation.value * 60).round()),
                blurRadius: widget.radius,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class PixelAppearTransition extends StatefulWidget {
  const PixelAppearTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;

  @override
  State<PixelAppearTransition> createState() => _PixelAppearTransitionState();
}

class _PixelAppearTransitionState extends State<PixelAppearTransition>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPixelArt = Theme.of(context).brightness == Brightness.dark &&
        Theme.of(context).scaffoldBackgroundColor == PixelArtColors.background;

    if (!isPixelArt) {
      return FadeTransition(
        opacity: _animation,
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ClipRect(
          child: CustomPaint(
            painter: _PixelAppearPainter(
              progress: _animation.value,
              gridSize: 8,
            ),
            child: Opacity(
              opacity: _animation.value,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _PixelAppearPainter extends CustomPainter {
  _PixelAppearPainter({required this.progress, required this.gridSize});

  final double progress;
  final int gridSize;

  @override
  void paint(Canvas canvas, Size size) {
    final pixelW = size.width / gridSize;
    final pixelH = size.height / gridSize;
    final totalPixels = gridSize * gridSize;
    final pixelsToShow = (totalPixels * progress).round();

    final random = math.Random(42);
    final indices = List.generate(totalPixels, (i) => i)..shuffle(random);

    final visible = indices.take(pixelsToShow).toSet();

    final paint = Paint()..color = Colors.black;

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        final idx = i * gridSize + j;
        if (!visible.contains(idx)) {
          canvas.drawRect(
            Rect.fromLTWH(i * pixelW, j * pixelH, pixelW, pixelH),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_PixelAppearPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
