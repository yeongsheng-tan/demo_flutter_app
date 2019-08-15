// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:demo_flutter_app/main.dart';

void main() {
  testWidgets('Search countries in continent smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('Flutter GraphQL Client'), findsOneWidget);
    expect(find.text('Countries of ??'), findsOneWidget);
    expect(find.text('Antartica'), findsNothing);

    // Tap the 'Search' icon and search for countries in AN.
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    expect(find.text('Search continents: AF, EU, OC ...'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'an');
    await tester.pumpAndSettle();
    expect(find.text('an'), findsOneWidget);
    expect(find.text('Countries of AN'), findsOneWidget);
  });
}
