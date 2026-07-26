import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/service_locator.dart';
import '../core/utils/seeded_stream.dart';
import '../core/widgets/player_animations/animation_type.dart';
import '../services/settings/settings_service.dart';

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

final themePreferenceProvider = StreamProvider<ThemePreference>((ref) {
  final service = ref.watch(settingsServiceProvider);
  return seededStream(service.themePreference, service.themeStream);
});

final sortPreferenceProvider = StreamProvider<SortPreference>((ref) {
  final service = ref.watch(settingsServiceProvider);
  return seededStream(service.sortPreference, service.sortStream);
});

final playerAnimationProvider = StreamProvider<PlayerAnimationType>((ref) {
  final service = ref.watch(settingsServiceProvider);
  return seededStream(service.playerAnimation, service.animationStream);
});
