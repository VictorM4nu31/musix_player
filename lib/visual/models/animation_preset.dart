import 'visual_quality.dart';
import 'visualizer_type.dart';

enum AnimationPreset {
  performance,
  minimal,
  dynamic,
  vinyl,
  retro,
  cyber;

  String get storageId => name;

  String get displayName => switch (this) {
        AnimationPreset.performance => 'Rendimiento',
        AnimationPreset.minimal => 'Minimal',
        AnimationPreset.dynamic => 'Dinámico',
        AnimationPreset.vinyl => 'Vinilo',
        AnimationPreset.retro => 'Retro',
        AnimationPreset.cyber => 'Cyber',
      };

  static AnimationPreset? tryParse(String? value) {
    if (value == null || value.isEmpty) return null;
    for (final p in AnimationPreset.values) {
      if (p.storageId == value || p.name == value) return p;
    }
    return null;
  }

  VisualizerType get defaultVisualizer => switch (this) {
        AnimationPreset.performance => VisualizerType.none,
        AnimationPreset.minimal => VisualizerType.minimal,
        AnimationPreset.dynamic => VisualizerType.pulse,
        AnimationPreset.vinyl => VisualizerType.vinyl,
        AnimationPreset.retro => VisualizerType.equalizer,
        AnimationPreset.cyber => VisualizerType.waves,
      };

  VisualQuality get defaultQuality => switch (this) {
        AnimationPreset.performance => VisualQuality.low,
        AnimationPreset.minimal => VisualQuality.low,
        AnimationPreset.dynamic => VisualQuality.medium,
        AnimationPreset.vinyl => VisualQuality.low,
        AnimationPreset.retro => VisualQuality.medium,
        AnimationPreset.cyber => VisualQuality.high,
      };

  double get defaultIntensity => switch (this) {
        AnimationPreset.performance => 0.3,
        AnimationPreset.minimal => 0.45,
        AnimationPreset.dynamic => 0.7,
        AnimationPreset.vinyl => 0.55,
        AnimationPreset.retro => 0.65,
        AnimationPreset.cyber => 0.85,
      };
}
