import 'package:flutter/material.dart';
import 'theme_id.dart';
import 'theme_tokens.dart';

/// Describes one complete visual theme: Material [ThemeData] + [MusixThemeTokens].
class ThemeDefinition {
  const ThemeDefinition({
    required this.id,
    required this.displayName,
    required this.tokens,
    required this.buildThemeData,
    this.icon = Icons.palette_rounded,
  });

  final ThemeId id;
  final String displayName;
  final MusixThemeTokens tokens;
  final ThemeData Function() buildThemeData;
  final IconData icon;

  List<Color> get previewColors => tokens.previewColors;

  ThemeData build() {
    final data = buildThemeData();
    // Ensure tokens are always present (definitions may already attach them).
    if (data.extension<MusixThemeTokens>() != null) return data;
    return data.copyWith(extensions: [tokens]);
  }
}

/// Result used to configure [MaterialApp].
class MaterialThemeConfig {
  const MaterialThemeConfig({
    required this.theme,
    required this.darkTheme,
    required this.themeMode,
  });

  final ThemeData theme;
  final ThemeData darkTheme;
  final ThemeMode themeMode;
}
