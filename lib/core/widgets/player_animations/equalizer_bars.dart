import 'dart:math';
import 'package:flutter/material.dart';

class EqualizerBars extends StatefulWidget {
  const EqualizerBars({super.key, required this.isPlaying, required this.size});

  final bool isPlaying;
  final double size;

  @override
  State<EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<EqualizerBars>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final int _barCount = 7;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _barCount,
      (i) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400 + _random.nextInt(300)),
      ),
    );

    _animations = List.generate(_barCount, (i) {
      final start = 0.2 + _random.nextDouble() * 0.2;
      final end = 0.6 + _random.nextDouble() * 0.4;
      return Tween<double>(begin: start, end: end).animate(
        CurvedAnimation(parent: _controllers[i], curve: Curves.easeInOut),
      );
    });

    if (widget.isPlaying) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    for (int i = 0; i < _barCount; i++) {
      Future.delayed(Duration(milliseconds: i * 80), () {
        if (mounted && widget.isPlaying) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  void _stopAnimations() {
    for (final c in _controllers) {
      c.stop();
    }
  }

  @override
  void didUpdateWidget(EqualizerBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controllers.first.isAnimating) {
      _startAnimations();
    } else if (!widget.isPlaying && _controllers.first.isAnimating) {
      _stopAnimations();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final barWidth = widget.size * 0.08;
    final totalWidth = _barCount * barWidth + (_barCount - 1) * (barWidth * 0.6);
    final startX = (widget.size - totalWidth) / 2;

    return AnimatedBuilder(
      animation: Listenable.merge(_controllers),
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _EqualizerPainter(
            bars: List.generate(_barCount, (i) {
              return _BarData(
                x: startX + i * (barWidth + barWidth * 0.6),
                height: _animations[i].value * widget.size * 0.5,
                width: barWidth,
              );
            }),
            color: primaryColor,
            maxHeight: widget.size * 0.5,
          ),
        );
      },
    );
  }
}

class _BarData {
  final double x;
  final double height;
  final double width;

  _BarData({required this.x, required this.height, required this.width});
}

class _EqualizerPainter extends CustomPainter {
  _EqualizerPainter({
    required this.bars,
    required this.color,
    required this.maxHeight,
  });

  final List<_BarData> bars;
  final Color color;
  final double maxHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final centerY = size.height / 2;

    for (final bar in bars) {
      final topY = centerY - bar.height / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(bar.x, topY, bar.width, bar.height),
        const Radius.circular(4),
      );
      paint.color = color.withAlpha(180);
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_EqualizerPainter oldDelegate) => true;
}
