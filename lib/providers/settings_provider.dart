import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/theme/theme_catalog.dart';
import '../app/theme/theme_definition.dart';
import '../core/service_locator.dart';
import '../core/utils/seeded_stream.dart';
import '../services/settings/settings_service.dart';
import '../visual/models/visualizer_type.dart';
import '../visual/providers/visual_providers.dart';

export '../visual/providers/visual_providers.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return settingsService;
});

final themeModeStreamProvider = StreamProvider<ThemeMode>((ref) {
  final service = ref.watch(settingsServiceProvider);
  return seededStream(service.themeMode, service.themeModeStream);
});

final currentThemeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeModeStreamProvider).valueOrNull ??
      settingsService.themeMode;
});

final themePreferenceProvider = StreamProvider<ThemeId>((ref) {
  final service = ref.watch(settingsServiceProvider);
  return seededStream(service.themePreference, service.themeStream);
});

final themeIdProvider = themePreferenceProvider;

final materialThemeConfigProvider = Provider<MaterialThemeConfig>((ref) {
  final id = ref.watch(themePreferenceProvider).valueOrNull ??
      settingsService.themePreference;
  return ThemeCatalog.materialConfig(id);
});

final sortPreferenceProvider = StreamProvider<SortPreference>((ref) {
  final service = ref.watch(settingsServiceProvider);
  return seededStream(service.sortPreference, service.sortStream);
});

/// Legacy name — same stream as [visualizerTypeProvider].
final playerAnimationProvider = visualizerTypeProvider;

/// Legacy typedef.
typedef PlayerAnimationType = VisualizerType;
