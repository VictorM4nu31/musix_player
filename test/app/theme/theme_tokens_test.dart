import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musix_player/app/theme/theme_catalog.dart';
import 'package:musix_player/app/theme/theme_id.dart';
import 'package:musix_player/app/theme/theme_tokens.dart';

void main() {
  test('MusixThemeTokens.lerp keeps endpoints', () {
    final a = ThemeCatalog.buildThemeData(ThemeId.light)
        .extension<MusixThemeTokens>()!;
    final b = ThemeCatalog.buildThemeData(ThemeId.pixelArt)
        .extension<MusixThemeTokens>()!;

    expect(a.lerp(b, 0.0).id, ThemeId.light);
    expect(a.lerp(b, 0.49).id, ThemeId.light);
    expect(a.lerp(b, 0.5).id, ThemeId.pixelArt);
    expect(a.lerp(b, 1.0).id, ThemeId.pixelArt);
  });

  test('copyWith updates selected fields', () {
    final base = ThemeCatalog.buildThemeData(ThemeId.dark)
        .extension<MusixThemeTokens>()!;
    final next = base.copyWith(
      enableScanlines: true,
      scanlineOpacity: 0.1,
      sliderThumbStyle: SliderThumbStyle.square,
    );
    expect(next.enableScanlines, isTrue);
    expect(next.scanlineOpacity, 0.1);
    expect(next.sliderThumbStyle, SliderThumbStyle.square);
    expect(next.id, ThemeId.dark);
    expect(next.radiusMd, base.radiusMd);
  });

  test('every theme has three preview colors', () {
    for (final id in ThemeCatalog.selectableIds) {
      final colors = ThemeCatalog.previewColors(id);
      expect(colors.length, greaterThanOrEqualTo(3), reason: id.name);
    }
  });

  test('theme identities match design goals', () {
    final pixel =
        ThemeCatalog.buildThemeData(ThemeId.pixelArt).extension<MusixThemeTokens>()!;
    expect(pixel.enableScanlines, isTrue);
    expect(pixel.sliderThumbStyle, SliderThumbStyle.square);
    expect(pixel.artworkRadius, 0);
    expect(pixel.displayFontFamily, 'PressStart2P');

    final amoled =
        ThemeCatalog.buildThemeData(ThemeId.amoled).extension<MusixThemeTokens>()!;
    expect(amoled.playerGradientEnd, const Color(0xFF000000));
    expect(amoled.cardShadows, isEmpty);

    final minimal =
        ThemeCatalog.buildThemeData(ThemeId.minimal).extension<MusixThemeTokens>()!;
    expect(minimal.radiusMd, 0);
    expect(minimal.artworkRadius, 0);
    expect(minimal.cardShadows, isEmpty);

    final cyber =
        ThemeCatalog.buildThemeData(ThemeId.cyberpunk).extension<MusixThemeTokens>()!;
    expect(cyber.glowColor, isNotNull);
    expect(cyber.borderWidth, greaterThan(0));
    expect(cyber.displayFontFamily, 'Orbitron');
  });

  testWidgets('context.musixTheme reads extension from Theme', (tester) async {
    final theme = ThemeCatalog.buildThemeData(ThemeId.cyberpunk);
    late MusixThemeTokens read;

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        home: Builder(
          builder: (context) {
            read = context.musixTheme;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(read.id, ThemeId.cyberpunk);
    expect(read.displayFontFamily, 'Orbitron');
  });
}
