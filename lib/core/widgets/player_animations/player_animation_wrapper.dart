import 'package:flutter/material.dart';
import 'audio_waves.dart';
import 'equalizer_bars.dart';
import 'pulse_effect.dart';
import 'vinyl_disc.dart';
import 'minimal_pulse.dart';
import 'animation_type.dart';

class PlayerAnimationWrapper extends StatelessWidget {
  const PlayerAnimationWrapper({
    super.key,
    required this.child,
    required this.animationType,
    required this.isPlaying,
  });

  final Widget child;
  final PlayerAnimationType animationType;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 280.0;

        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildAnimation(size),
              child,
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimation(double size) {
    switch (animationType) {
      case PlayerAnimationType.waves:
        return AudioWaves(isPlaying: isPlaying, size: size);
      case PlayerAnimationType.equalizer:
        return EqualizerBars(isPlaying: isPlaying, size: size);
      case PlayerAnimationType.pulse:
        return PulseEffect(isPlaying: isPlaying, size: size);
      case PlayerAnimationType.vinyl:
        return VinylDisc(isPlaying: isPlaying, size: size);
      case PlayerAnimationType.minimal:
        return MinimalPulse(isPlaying: isPlaying, size: size);
      case PlayerAnimationType.none:
        return const SizedBox.shrink();
    }
  }
}
