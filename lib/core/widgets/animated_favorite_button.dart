import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/theme/theme_tokens.dart';

class AnimatedFavoriteButton extends StatefulWidget {
  const AnimatedFavoriteButton({
    super.key,
    required this.isFavorite,
    this.size = 28,
    this.onChanged,
  });

  final bool isFavorite;
  final double size;
  final ValueChanged<bool>? onChanged;

  @override
  State<AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<AnimatedFavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(AnimatedFavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _controller.forward(from: 0.0).then((_) {
        if (mounted) _controller.reverse();
      });
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
    final tokens = context.musixThemeOrNull;
    final iconColor = widget.isFavorite
        ? (tokens?.favoriteColor ?? theme.colorScheme.error)
        : theme.iconTheme.color ?? theme.colorScheme.onSurface.withAlpha(160);

    return GestureDetector(
      onTap: () => widget.onChanged?.call(!widget.isFavorite),
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              if (widget.isFavorite)
                _buildParticles(context, iconColor),
              Transform.scale(
                scale: _pulseAnim.value,
                child: Icon(
                  widget.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: iconColor,
                  size: widget.size,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildParticles(BuildContext context, Color color) {
    return CustomPaint(
      size: Size(widget.size + 20, widget.size + 20),
      painter: _ParticlePainter(
        progress: _pulseAnim.value,
        color: color,
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.9) return;

    final paint = Paint()
      ..color = color.withAlpha(
        ((1.0 - (progress - 0.9) / 0.3).clamp(0, 1) * 255).round(),
      )
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final numParticles = 6;

    for (int i = 0; i < numParticles; i++) {
      final angle = (math.pi * 2 * i / numParticles) + (progress * 0.5);
      final distance = ((progress - 0.9) / 0.1).clamp(0, 1) * 15;
      final px = center.dx + math.cos(angle) * distance;
      final py = center.dy + math.sin(angle) * distance;
      canvas.drawCircle(Offset(px, py), 2, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) =>
      progress != oldDelegate.progress;
}
