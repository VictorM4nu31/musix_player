import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/service_locator.dart';
import '../services/settings/settings_service.dart';

final settingsServiceProvider = Provider<SettingsService>((ref) {
  return settingsService;
});

final themeModeStreamProvider = StreamProvider<ThemeMode>((ref) {
  final service = ref.watch(settingsServiceProvider);
  return service.themeModeStream;
});

final currentThemeModeProvider = Provider<ThemeMode>((ref) {
  return settingsService.themeMode;
});

final themePreferenceProvider = Provider<ThemePreference>((ref) {
  return settingsService.themePreference;
});

final sortPreferenceProvider = Provider<SortPreference>((ref) {
  return settingsService.sortPreference;
});
