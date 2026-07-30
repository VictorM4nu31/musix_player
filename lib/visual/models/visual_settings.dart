import 'package:flutter/foundation.dart';
import 'animation_preset.dart';
import 'visual_quality.dart';
import 'visualizer_type.dart';

@immutable
class VisualSettings {
  const VisualSettings({
    this.visualizerType = VisualizerType.vinyl,
    this.preset = AnimationPreset.vinyl,
    this.quality = VisualQuality.medium,
    this.intensity = 0.7,
    this.audioReactive = true,
    this.animationsEnabled = true,
  });

  final VisualizerType visualizerType;
  final AnimationPreset preset;
  final VisualQuality quality;
  final double intensity;
  final bool audioReactive;
  final bool animationsEnabled;

  /// Effective type after accessibility / kill-switch.
  VisualizerType get effectiveType {
    if (!animationsEnabled) return VisualizerType.none;
    return visualizerType;
  }

  double get clampedIntensity => intensity.clamp(0.0, 1.0);

  VisualSettings copyWith({
    VisualizerType? visualizerType,
    AnimationPreset? preset,
    VisualQuality? quality,
    double? intensity,
    bool? audioReactive,
    bool? animationsEnabled,
  }) {
    return VisualSettings(
      visualizerType: visualizerType ?? this.visualizerType,
      preset: preset ?? this.preset,
      quality: quality ?? this.quality,
      intensity: intensity ?? this.intensity,
      audioReactive: audioReactive ?? this.audioReactive,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VisualSettings &&
        other.visualizerType == visualizerType &&
        other.preset == preset &&
        other.quality == quality &&
        other.intensity == intensity &&
        other.audioReactive == audioReactive &&
        other.animationsEnabled == animationsEnabled;
  }

  @override
  int get hashCode => Object.hash(
        visualizerType,
        preset,
        quality,
        intensity,
        audioReactive,
        animationsEnabled,
      );
}
