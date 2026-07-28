import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musix_player/app/theme/theme_catalog.dart';
import 'package:musix_player/app/theme/theme_id.dart';
import 'package:musix_player/app/theme/theme_tokens.dart';

void main() {
  test('every non-system theme builds ThemeData with MusixThemeTokens', () {
    for (final id in ThemeId.values) {
      if (id == ThemeId.system) continue;
      final theme = ThemeCatalog.buildThemeData(id);
      final tokens = theme.extension<MusixThemeTokens>();
      expect(tokens, isNotNull, reason: 'missing tokens for $id');
      expect(tokens!.id, id);
      expect(theme.colorScheme.primary, isNot(equals(Colors.transparent)));
    }
  });

  test('system material config uses light + dark + ThemeMode.system', () {
    final config = ThemeCatalog.materialConfig(ThemeId.system);
    expect(config.themeMode, ThemeMode.system);
    expect(
      config.theme.extension<MusixThemeTokens>()!.id,
      ThemeId.light,
    );
    expect(
      config.darkTheme.extension<MusixThemeTokens>()!.id,
      ThemeId.dark,
    );
  });

  test('custom themes force single ThemeData with ThemeMode.light', () {
    for (final id in [
      ThemeId.pixelArt,
      ThemeId.amoled,
      ThemeId.cyberpunk,
      ThemeId.minimal,
    ]) {
      final config = ThemeCatalog.materialConfig(id);
      expect(config.themeMode, ThemeMode.light);
      expect(config.theme.extension<MusixThemeTokens>()!.id, id);
      expect(config.darkTheme.extension<MusixThemeTokens>()!.id, id);
    }
  });

  test('pixel art enables scanlines and square slider style', () {
    final tokens =
        ThemeCatalog.buildThemeData(ThemeId.pixelArt).extension<MusixThemeTokens>()!;
    expect(tokens.enableScanlines, isTrue);
    expect(tokens.sliderThumbStyle, SliderThumbStyle.square);
    expect(tokens.isPixelArt, isTrue);
  });

  test('pixel and cyberpunk use bundled local font families', () {
    final pixel = ThemeCatalog.buildThemeData(ThemeId.pixelArt);
    final cyber = ThemeCatalog.buildThemeData(ThemeId.cyberpunk);
    final pixelTokens = pixel.extension<MusixThemeTokens>()!;
    final cyberTokens = cyber.extension<MusixThemeTokens>()!;

    expect(pixelTokens.displayFontFamily, 'PressStart2P');
    expect(pixelTokens.bodyFontFamily, 'ShareTechMono');
    expect(pixel.textTheme.titleLarge?.fontFamily, 'PressStart2P');
    expect(pixel.textTheme.bodyLarge?.fontFamily, 'ShareTechMono');

    expect(cyberTokens.displayFontFamily, 'Orbitron');
    expect(cyberTokens.bodyFontFamily, 'ShareTechMono');
    expect(cyber.textTheme.titleLarge?.fontFamily, 'Orbitron');
    expect(cyber.textTheme.bodyLarge?.fontFamily, 'ShareTechMono');
  });

  test('slider theme uses square thumb for pixel art', () {
    final theme = ThemeCatalog.buildThemeData(ThemeId.pixelArt);
    expect(theme.sliderTheme.thumbShape.runtimeType.toString(),
        contains('SquareSliderThumbShape'));
  });

  test('selectable ids include all catalog themes plus system', () {
    expect(ThemeCatalog.selectableIds, contains(ThemeId.system));
    expect(ThemeCatalog.selectableIds, contains(ThemeId.pixelArt));
    expect(ThemeCatalog.selectableIds, contains(ThemeId.cyberpunk));
    expect(ThemeCatalog.selectableIds.length, ThemeId.values.length);
  });

  test('ThemeId storage round-trip', () {
    for (final id in ThemeId.values) {
      expect(ThemeId.tryParse(id.storageId), id);
    }
    expect(ThemeId.fromLegacyIndex(0), ThemeId.system);
    expect(ThemeId.fromLegacyIndex(3), ThemeId.pixelArt);
  });

  test('notification accent is opaque primary for each theme', () {
    for (final id in ThemeId.values) {
      final color = ThemeCatalog.notificationAccent(id);
      expect(color.a, greaterThan(0.99));
    }
  });
}
