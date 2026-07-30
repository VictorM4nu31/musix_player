import '../../app/theme/theme_id.dart';
import '../models/animation_preset.dart';
import '../models/visualizer_type.dart';

/// Suggested defaults when user has not overridden visualizer explicitly
/// after a theme change (optional helper for settings UX).
class ThemeVisualProfile {
  const ThemeVisualProfile({
    required this.suggestedPreset,
    required this.suggestedVisualizer,
  });

  final AnimationPreset suggestedPreset;
  final VisualizerType suggestedVisualizer;

  static ThemeVisualProfile forTheme(ThemeId id) {
    return switch (id) {
      ThemeId.minimal => const ThemeVisualProfile(
          suggestedPreset: AnimationPreset.minimal,
          suggestedVisualizer: VisualizerType.minimal,
        ),
      ThemeId.pixelArt => const ThemeVisualProfile(
          suggestedPreset: AnimationPreset.retro,
          suggestedVisualizer: VisualizerType.equalizer,
        ),
      ThemeId.cyberpunk => const ThemeVisualProfile(
          suggestedPreset: AnimationPreset.cyber,
          suggestedVisualizer: VisualizerType.waves,
        ),
      ThemeId.amoled => const ThemeVisualProfile(
          suggestedPreset: AnimationPreset.minimal,
          suggestedVisualizer: VisualizerType.pulse,
        ),
      ThemeId.light ||
      ThemeId.dark ||
      ThemeId.system =>
        const ThemeVisualProfile(
          suggestedPreset: AnimationPreset.dynamic,
          suggestedVisualizer: VisualizerType.pulse,
        ),
    };
  }
}
