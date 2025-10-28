// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:foodie/main.dart';

void main() {
  testWidgets('App shows splash title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FoddieApp());

    // The splash screen should show the app name 'Foddie'.
    expect(find.text('Foddie'), findsOneWidget);
    // Advance the timer used by the splash screen so there are no pending timers
    // when the test finishes.
    await tester.pump(const Duration(seconds: 3));
  });
}
