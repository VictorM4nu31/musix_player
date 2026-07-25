import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/settings/settings_service.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  final service = SettingsService();
  service.init();
  ref.onDispose(() => service.dispose());
  return service;
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  final service = ref.watch(settingsServiceProvider);
  return service.themeMode;
});

final themePreferenceProvider = Provider<ThemePreference>((ref) {
  final service = ref.watch(settingsServiceProvider);
  return service.themePreference;
});

final sortPreferenceProvider = Provider<SortPreference>((ref) {
  final service = ref.watch(settingsServiceProvider);
  return service.sortPreference;
});
