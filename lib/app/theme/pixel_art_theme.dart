import 'package:flutter/material.dart';
import 'theme_catalog.dart';
import 'theme_id.dart';

export 'definitions/pixel_art_theme.dart' show PixelArtColors;

/// Legacy facade — prefer [ThemeCatalog] / [MusixThemeTokens].
abstract final class AppThemePixelArt {
  static ThemeData get theme => ThemeCatalog.buildThemeData(ThemeId.pixelArt);
}
