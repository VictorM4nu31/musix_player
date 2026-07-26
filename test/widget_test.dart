import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:musix_player/core/widgets/empty_state.dart';
import 'package:musix_player/core/utils/formatters.dart';

void main() {
  testWidgets('EmptyState renders title and action', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.library_music_rounded,
            title: 'Sin canciones',
            subtitle: 'No hay música',
            actionLabel: 'Actualizar',
            onAction: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Sin canciones'), findsOneWidget);
    expect(find.text('No hay música'), findsOneWidget);
    await tester.tap(find.text('Actualizar'));
    expect(tapped, isTrue);
  });

  test('Formatters duration short', () {
    expect(
      Formatters.formatDurationShort(const Duration(minutes: 3, seconds: 5)),
      '3:05',
    );
  });
}
