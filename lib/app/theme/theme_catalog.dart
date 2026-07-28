import 'package:flutter/material.dart';
import 'definitions/amoled_theme.dart';
import 'definitions/cyberpunk_theme.dart';
import 'definitions/dark_theme.dart';
import 'definitions/light_theme.dart';
import 'definitions/minimal_theme.dart';
import 'definitions/pixel_art_theme.dart';
import 'theme_definition.dart';
import 'theme_id.dart';

/// Central registry of all app themes.
abstract final class ThemeCatalog {
  static final Map<ThemeId, ThemeDefinition> _byId = {
    ThemeId.light: lightThemeDefinition,
    ThemeId.dark: darkThemeDefinition,
    ThemeId.pixelArt: pixelArtThemeDefinition,
    ThemeId.amoled: amoledThemeDefinition,
    ThemeId.cyberpunk: cyberpunkThemeDefinition,
    ThemeId.minimal: minimalThemeDefinition,
  };

  /// Themes shown in the selector (includes [ThemeId.system]).
  static List<ThemeId> get selectableIds => const [
        ThemeId.system,
        ThemeId.light,
        ThemeId.dark,
        ThemeId.pixelArt,
        ThemeId.amoled,
        ThemeId.cyberpunk,
        ThemeId.minimal,
      ];

  static ThemeDefinition? definitionOf(ThemeId id) {
    if (id == ThemeId.system) return null;
    return _byId[id];
  }

  static ThemeDefinition requireDefinition(ThemeId id) {
    final def = definitionOf(id);
    if (def == null) {
      throw ArgumentError('No ThemeDefinition for $id');
    }
    return def;
  }

  /// Preview swatches for selector cards (system uses light+dark blend).
  static List<Color> previewColors(ThemeId id) {
    if (id == ThemeId.system) {
      return const [
        Color(0xFF5C6BC0),
        Color(0xFFFFFFFF),
        Color(0xFF161726),
      ];
    }
    return requireDefinition(id).previewColors;
  }

  static IconData iconOf(ThemeId id) {
    return switch (id) {
      ThemeId.system => Icons.brightness_auto_rounded,
      ThemeId.light => Icons.light_mode_rounded,
      ThemeId.dark => Icons.dark_mode_rounded,
      ThemeId.pixelArt => Icons.videogame_asset_rounded,
      ThemeId.amoled => Icons.contrast_rounded,
      ThemeId.cyberpunk => Icons.bolt_rounded,
      ThemeId.minimal => Icons.crop_square_rounded,
    };
  }

  static ThemeData buildThemeData(ThemeId id) {
    return requireDefinition(id).build();
  }

  /// Primary accent for OS surfaces (notifications). System uses light primary.
  static Color notificationAccent(ThemeId id) {
    final resolved = id == ThemeId.system ? ThemeId.light : id;
    return buildThemeData(resolved).colorScheme.primary;
  }

  /// Resolves [MaterialApp] theme / darkTheme / themeMode for [id].
  ///
  /// Custom styles (pixel, amoled, …) force a single [ThemeData] on both
  /// slots with [ThemeMode.light] so Flutter does not fall back to light/dark.
  static MaterialThemeConfig materialConfig(ThemeId id) {
    switch (id) {
      case ThemeId.system:
        return MaterialThemeConfig(
          theme: buildThemeData(ThemeId.light),
          darkTheme: buildThemeData(ThemeId.dark),
          themeMode: ThemeMode.system,
        );
      case ThemeId.light:
        final light = buildThemeData(ThemeId.light);
        return MaterialThemeConfig(
          theme: light,
          darkTheme: light,
          themeMode: ThemeMode.light,
        );
      case ThemeId.dark:
        final dark = buildThemeData(ThemeId.dark);
        return MaterialThemeConfig(
          theme: dark,
          darkTheme: dark,
          themeMode: ThemeMode.dark,
        );
      case ThemeId.pixelArt:
      case ThemeId.amoled:
      case ThemeId.cyberpunk:
      case ThemeId.minimal:
        final custom = buildThemeData(id);
        return MaterialThemeConfig(
          theme: custom,
          darkTheme: custom,
          themeMode: ThemeMode.light,
        );
    }
  }

  /// Effective definition for the currently applied brightness (for system).
  static ThemeDefinition effectiveDefinition(
    ThemeId id,
    Brightness platformBrightness,
  ) {
    if (id == ThemeId.system) {
      return platformBrightness == Brightness.dark
          ? darkThemeDefinition
          : lightThemeDefinition;
    }
    return requireDefinition(id);
  }
}
