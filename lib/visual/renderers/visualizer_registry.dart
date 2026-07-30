import '../models/visualizer_type.dart';
import 'equalizer_renderer.dart';
import 'minimal_renderer.dart';
import 'none_renderer.dart';
import 'pulse_renderer.dart';
import 'vinyl_renderer.dart';
import 'visualizer_renderer.dart';
import 'waves_renderer.dart';

class VisualizerRegistry {
  VisualizerRegistry._();

  static final Map<VisualizerType, VisualizerRenderer> _renderers = {
    VisualizerType.none: const NoneRenderer(),
    VisualizerType.minimal: const MinimalRenderer(),
    VisualizerType.pulse: const PulseRenderer(),
    VisualizerType.vinyl: const VinylRenderer(),
    VisualizerType.waves: const WavesRenderer(),
    VisualizerType.equalizer: const EqualizerRenderer(),
  };

  static VisualizerRenderer resolve(VisualizerType type) {
    return _renderers[type] ?? const NoneRenderer();
  }

  static List<VisualizerType> get availableTypes =>
      List.unmodifiable(VisualizerType.values);
}
