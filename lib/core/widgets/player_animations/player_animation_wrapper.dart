import 'package:flutter/material.dart';
import 'animation_type.dart';
import 'audio_waves.dart';
import 'equalizer_bars.dart';
import 'minimal_pulse.dart';
import 'pulse_effect.dart';
import 'vinyl_disc.dart';

/// Composes artwork with a visible animation that reacts to [isPlaying].
///
/// Layout principle: decorative effects live *outside* or *on* the artwork
/// (never fully hidden behind an opaque cover of the same size).
class PlayerAnimationWrapper extends StatelessWidget {
  const PlayerAnimationWrapper({
    super.key,
    required this.child,
    required this.animationType,
    required this.isPlaying,
    this.reduceMotion = false,
  });

  final Widget child;
  final PlayerAnimationType animationType;
  final bool isPlaying;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final effectiveType =
        reduceMotion ? PlayerAnimationType.none : animationType;

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide;
        final size = side.isFinite && side > 0 ? side : 280.0;

        return SizedBox(
          width: size,
          height: size,
          child: _buildForType(effectiveType, size),
        );
      },
    );
  }

  Widget _buildForType(PlayerAnimationType type, double size) {
    switch (type) {
      case PlayerAnimationType.vinyl:
        return VinylDisc(
          isPlaying: isPlaying,
          size: size,
          child: child,
        );
      case PlayerAnimationType.pulse:
        return PulseEffect(
          isPlaying: isPlaying,
          size: size,
          child: child,
        );
      case PlayerAnimationType.waves:
        return AudioWaves(
          isPlaying: isPlaying,
          size: size,
          child: child,
        );
      case PlayerAnimationType.equalizer:
        return EqualizerBars(
          isPlaying: isPlaying,
          size: size,
          child: child,
        );
      case PlayerAnimationType.minimal:
        return MinimalPulse(
          isPlaying: isPlaying,
          size: size,
          child: child,
        );
      case PlayerAnimationType.none:
        return child;
    }
  }
}
