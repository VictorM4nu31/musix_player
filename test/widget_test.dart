import 'package:flutter_test/flutter_test.dart';
import 'package:musix_player/app/app.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const MusixPlayerApp());
    expect(find.text('Biblioteca'), findsOneWidget);
  });
}
