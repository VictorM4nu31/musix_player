import 'package:flutter/material.dart';
import '../../app/theme/theme_tokens.dart';
import 'audio_features.dart';
import 'visual_settings.dart';

/// Immutable snapshot passed to every [VisualizerRenderer].
@immutable
class VisualizerFrame {
  const VisualizerFrame({
    required this.features,
    required this.settings,
    required this.tokens,
    required this.artwork,
    required this.size,
    required this.isPlaying,
    required this.reduceMotion,
    this.primaryColor,
  });

  final AudioFeatures features;
  final VisualSettings settings;
  final MusixThemeTokens? tokens;
  final Widget artwork;
  final double size;
  final bool isPlaying;
  final bool reduceMotion;
  final Color? primaryColor;

  double get intensity => settings.clampedIntensity;

  /// Blended reactive scale 0–1 for light renderers.
  double get reactive => settings.audioReactive
      ? (features.energy * 0.55 + features.beatPulse * 0.45) * intensity
      : (isPlaying ? 0.35 * intensity : 0.0);
}
