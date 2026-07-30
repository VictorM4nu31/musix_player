import 'dart:ui' show Color;

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  double life;
  double maxLife;
  double alpha;
  Color color;
  double wobblePhase;
  double wobbleAmp;
  bool radial;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    this.life = 0,
    this.maxLife = 1,
    required this.alpha,
    required this.color,
    this.wobblePhase = 0,
    this.wobbleAmp = 0,
    this.radial = false,
  });

  double get normalizedLife => (life / maxLife).clamp(0.0, 1.0);
  bool get isDead => life >= maxLife;
}
