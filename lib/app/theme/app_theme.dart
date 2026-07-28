import 'package:flutter/material.dart';
import 'theme_catalog.dart';
import 'theme_id.dart';

/// Legacy facade — prefer [ThemeCatalog].
abstract final class AppTheme {
  static ThemeData get light => ThemeCatalog.buildThemeData(ThemeId.light);
  static ThemeData get dark => ThemeCatalog.buildThemeData(ThemeId.dark);
}
