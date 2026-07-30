import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/service_locator.dart';
import '../../core/utils/seeded_stream.dart';
import '../../services/settings/settings_service.dart';
import '../models/animation_preset.dart';
import '../models/visual_quality.dart';
import '../models/visual_settings.dart';
import '../models/visualizer_type.dart';

final visualSettingsServiceProvider = Provider<SettingsService>((ref) {
  return settingsService;
});

final visualizerTypeProvider = StreamProvider<VisualizerType>((ref) {
  final service = ref.watch(visualSettingsServiceProvider);
  return seededStream(service.visualizerType, service.visualizerTypeStream);
});

final animationPresetProvider = StreamProvider<AnimationPreset>((ref) {
  final service = ref.watch(visualSettingsServiceProvider);
  return seededStream(service.animationPreset, service.animationPresetStream);
});

final visualQualityProvider = StreamProvider<VisualQuality>((ref) {
  final service = ref.watch(visualSettingsServiceProvider);
  return seededStream(service.visualQuality, service.visualQualityStream);
});

final visualIntensityProvider = StreamProvider<double>((ref) {
  final service = ref.watch(visualSettingsServiceProvider);
  return seededStream(service.visualIntensity, service.visualIntensityStream);
});

final audioReactiveProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(visualSettingsServiceProvider);
  return seededStream(service.audioReactive, service.audioReactiveStream);
});

final animationsEnabledProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(visualSettingsServiceProvider);
  return seededStream(
    service.animationsEnabled,
    service.animationsEnabledStream,
  );
});

/// Aggregated snapshot for renderers (rebuilds when any visual setting changes).
final visualSettingsProvider = Provider<VisualSettings>((ref) {
  final type = ref.watch(visualizerTypeProvider).valueOrNull;
  final preset = ref.watch(animationPresetProvider).valueOrNull;
  final quality = ref.watch(visualQualityProvider).valueOrNull;
  final intensity = ref.watch(visualIntensityProvider).valueOrNull;
  final reactive = ref.watch(audioReactiveProvider).valueOrNull;
  final enabled = ref.watch(animationsEnabledProvider).valueOrNull;
  final service = ref.watch(visualSettingsServiceProvider);

  return VisualSettings(
    visualizerType: type ?? service.visualizerType,
    preset: preset ?? service.animationPreset,
    quality: quality ?? service.visualQuality,
    intensity: intensity ?? service.visualIntensity,
    audioReactive: reactive ?? service.audioReactive,
    animationsEnabled: enabled ?? service.animationsEnabled,
  );
});
