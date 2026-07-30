import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/audio_features.dart';
import '../models/visual_quality.dart';
import 'particle.dart';

class ParticleSystem {
  ParticleSystem({required VisualQuality quality}) {
    _updateLimits(quality);
  }

  VisualQuality _quality = VisualQuality.medium;
  int _maxParticles = 35;
  double _emissionRate = 8;
  final List<Particle> _particles = [];
  final _random = math.Random();
  double _time = 0;
  double _spawnAcc = 0;
  double _lastBeat = 0;

  List<Particle> get particles => _particles;

  void updateQuality(VisualQuality quality) {
    if (quality == _quality) return;
    _updateLimits(quality);
    while (_particles.length > _maxParticles) {
      _particles.removeAt(0);
    }
  }

  void _updateLimits(VisualQuality q) {
    _quality = q;
    switch (q) {
      case VisualQuality.low:
        _maxParticles = 12;
        _emissionRate = 3;
      case VisualQuality.medium:
        _maxParticles = 35;
        _emissionRate = 8;
      case VisualQuality.high:
        _maxParticles = 70;
        _emissionRate = 18;
      case VisualQuality.ultra:
        _maxParticles = 120;
        _emissionRate = 30;
    }
  }

  void update(double dt, AudioFeatures features) {
    if (_maxParticles <= 0) {
      if (_particles.isNotEmpty) _particles.clear();
      return;
    }

    dt = dt.clamp(0.001, 0.05);
    _time += dt;

    final isPlaying = features.isPlaying;
    final speed = isPlaying ? 1.0 : 0.15;
    final energy = features.energy;
    final bass = features.bass;
    final beat = features.beatPulse;

    // Beat burst
    if (isPlaying && beat > 0.3 && _lastBeat <= 0.3) {
      final burstCount = (8 + (beat * 15) * (_quality == VisualQuality.ultra ? 1.5 : 1.0))
          .round()
          .clamp(4, 30);
      for (var i = 0; i < burstCount && _particles.length < _maxParticles; i++) {
        _particles.add(_createSparkle(energy));
      }
    }
    _lastBeat = beat;

    // Continuous emission
    _spawnAcc += _emissionRate * dt * speed;
    while (_spawnAcc >= 1.0 && _particles.length < _maxParticles) {
      _spawnAcc -= 1.0;
      _particles.add(_createFirefly(energy));
      if (_quality.index >= VisualQuality.high.index && _random.nextDouble() < 0.3) {
        _particles.add(_createBubble(bass));
      }
    }

    for (var i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.life += dt * (isPlaying ? (0.3 + energy * 0.5) : 0.1);

      if (p.isDead) {
        _particles.removeAt(i);
        continue;
      }

      final n = p.normalizedLife;
      final wobble = math.sin(_time * 2.5 + p.wobblePhase) * p.wobbleAmp * speed;
      final bassBoost = isPlaying ? bass * 0.25 : 0.0;

      p.x += (p.vx + wobble) * dt * speed;
      p.y += (p.vy - bassBoost * 0.15) * dt * speed;

      final fadeIn = (n * 3).clamp(0.0, 1.0);
      final fadeOut = ((1.0 - n) * 1.5).clamp(0.0, 1.0);
      p.alpha = (fadeIn * fadeOut).clamp(0.0, 1.0);
    }
  }

  Particle _createFirefly(double energy) {
    final angle = _random.nextDouble() * 2 * math.pi;
    final dist = _random.nextDouble() * 0.08;
    final hue = 30 + _random.nextDouble() * 30;
    final sat = 0.5 + _random.nextDouble() * 0.4;
    final light = 0.5 + _random.nextDouble() * 0.4;

    return Particle(
      x: 0.5 + math.cos(angle) * dist,
      y: 0.5 + math.sin(angle) * dist,
      vx: (_random.nextDouble() - 0.5) * 0.06,
      vy: -(0.03 + _random.nextDouble() * 0.08),
      size: 1.5 + _random.nextDouble() * 2.5,
      alpha: 0.7 + _random.nextDouble() * 0.3,
      color: HSLColor.fromAHSL(1, hue, sat, light).toColor(),
      maxLife: 2 + _random.nextDouble() * 3,
      wobblePhase: _random.nextDouble() * 2 * math.pi,
      wobbleAmp: 0.01 + _random.nextDouble() * 0.03,
      radial: false,
    );
  }

  Particle _createSparkle(double energy) {
    final angle = _random.nextDouble() * 2 * math.pi;
    final hue = 40 + _random.nextDouble() * 30;
    final speed = 0.12 + energy * 0.15 + _random.nextDouble() * 0.08;

    return Particle(
      x: 0.5,
      y: 0.5,
      vx: math.cos(angle) * speed,
      vy: math.sin(angle) * speed,
      size: 0.8 + _random.nextDouble() * 1.5,
      alpha: 1.0,
      color: HSLColor.fromAHSL(1, hue, 1.0, 0.65 + _random.nextDouble() * 0.2)
          .toColor(),
      maxLife: 0.3 + _random.nextDouble() * 0.5,
      radial: true,
    );
  }

  Particle _createBubble(double bass) {
    return Particle(
      x: 0.1 + _random.nextDouble() * 0.8,
      y: 1.0 + 0.02,
      vx: (_random.nextDouble() - 0.5) * 0.015,
      vy: -(0.04 + _random.nextDouble() * 0.06 + bass * 0.04),
      size: 3 + _random.nextDouble() * 5,
      alpha: 0.2 + _random.nextDouble() * 0.3,
      color: HSLColor.fromAHSL(1, 195, 0.5, 0.5).toColor(),
      maxLife: 4 + _random.nextDouble() * 4,
      wobblePhase: _random.nextDouble() * 2 * math.pi,
      wobbleAmp: 0.008 + _random.nextDouble() * 0.015,
      radial: false,
    );
  }

  void reset() {
    _particles.clear();
    _spawnAcc = 0;
    _time = 0;
    _lastBeat = 0;
  }
}
