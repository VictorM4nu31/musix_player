import 'package:flutter/material.dart';
import 'particle.dart';

class ParticlePainter extends CustomPainter {
  ParticlePainter({
    required this.particles,
    required this.color,
    required this.intensity,
    required this.isPlaying,
  });

  final List<Particle> particles;
  final Color color;
  final double intensity;
  final bool isPlaying;

  @override
  void paint(Canvas canvas, Size size) {
    final showParticles = isPlaying || particles.isNotEmpty;
    if (!showParticles) return;

    for (final p in particles) {
      if (p.alpha <= 0.01) continue;

      final cx = p.x * size.width;
      final cy = p.y * size.height;
      final baseRadius = p.size * size.width / 500;
      final radius = baseRadius * (0.5 + intensity * 0.5);

      if (radius < 0.3) continue;

      final alpha =
          (p.alpha * (isPlaying ? 220 : 60)).round().clamp(0, 255);
      final c = p.color.withAlpha(alpha);

      // Glow
      final glow = Paint()
        ..color = c.withAlpha((alpha * 0.18).round().clamp(0, 255))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(cx, cy), radius * 2.5, glow);

      // Core
      final core = Paint()..color = c;
      canvas.drawCircle(Offset(cx, cy), radius, core);

      // Bright center for sparkles (short-lived radial particles)
      if (p.radial && p.alpha > 0.5) {
        final bright = Paint()
          ..color = Colors.white.withAlpha((alpha * 0.5).round().clamp(0, 255));
        canvas.drawCircle(Offset(cx, cy), radius * 0.35, bright);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}
