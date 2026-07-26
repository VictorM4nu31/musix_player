import 'package:flutter/material.dart';
import 'audio_waves.dart';
import 'equalizer_bars.dart';
import 'pulse_effect.dart';
import 'vinyl_disc.dart';
import 'minimal_pulse.dart';
import 'animation_type.dart';

class PlayerAnimationWrapper extends StatefulWidget {
  const PlayerAnimationWrapper({
    super.key,
    required this.child,
    required this.animationType,
    required this.isPlaying,
    this.size = 280,
  });

  final Widget child;
  final PlayerAnimationType animationType;
  final bool isPlaying;
  final double size;

  @override
  State<PlayerAnimationWrapper> createState() => _PlayerAnimationWrapperState();
}

class _PlayerAnimationWrapperState extends State<PlayerAnimationWrapper> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildAnimation(),
          widget.child,
        ],
      ),
    );
  }

  Widget _buildAnimation() {
    switch (widget.animationType) {
      case PlayerAnimationType.waves:
        return AudioWaves(isPlaying: widget.isPlaying, size: widget.size);
      case PlayerAnimationType.equalizer:
        return EqualizerBars(isPlaying: widget.isPlaying, size: widget.size);
      case PlayerAnimationType.pulse:
        return PulseEffect(isPlaying: widget.isPlaying, size: widget.size);
      case PlayerAnimationType.vinyl:
        return VinylDisc(isPlaying: widget.isPlaying, size: widget.size);
      case PlayerAnimationType.minimal:
        return MinimalPulse(isPlaying: widget.isPlaying, size: widget.size);
      case PlayerAnimationType.none:
        return const SizedBox.shrink();
    }
  }
}
