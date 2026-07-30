import 'package:flutter/material.dart';
import '../../../visual/models/audio_features.dart';
import '../../../visual/models/visual_settings.dart';
import '../../../visual/models/visualizer_frame.dart';
import '../../../visual/models/visualizer_type.dart';
import '../../../visual/renderers/visualizer_registry.dart';
import 'animation_type.dart';

/// Legacy wrapper — prefer [PlayerVisualShell].
///
/// Kept for any residual call sites; delegates to [VisualizerRegistry].
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
    final effectiveType = reduceMotion ? VisualizerType.none : animationType;

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.biggest.shortestSide;
        final size = side.isFinite && side > 0 ? side : 280.0;
        final theme = Theme.of(context);

        final frame = VisualizerFrame(
          features: AudioFeatures(
            isPlaying: isPlaying,
            energy: isPlaying ? 0.35 : 0,
            intensity: 0.7,
          ),
          settings: VisualSettings(
            visualizerType: effectiveType,
            animationsEnabled: !reduceMotion,
          ),
          tokens: null,
          artwork: child,
          size: size,
          isPlaying: isPlaying,
          reduceMotion: reduceMotion,
          primaryColor: theme.colorScheme.primary,
        );

        return SizedBox(
          width: size,
          height: size,
          child: VisualizerRegistry.resolve(effectiveType).build(context, frame),
        );
      },
    );
  }
}
