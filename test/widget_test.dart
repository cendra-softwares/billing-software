// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:seo_biling/main.dart';
import 'package:seo_biling/providers/theme_provider.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Theme toggle button exists and works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that theme toggle button exists
    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);

    // Tap the theme toggle button
    await tester.tap(find.byIcon(Icons.dark_mode_outlined));
    await tester.pumpAndSettle();

    // Verify that the icon changed to light mode
    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
  });

  testWidgets('Theme toggle switch exists and works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that theme toggle switch exists
    expect(find.byType(Switch), findsOneWidget);

    // Get initial switch state (should be false for light mode)
    Switch switchWidget = tester.widget(find.byType(Switch));
    expect(switchWidget.value, false);

    // Tap the switch
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    // Verify that the switch state changed
    switchWidget = tester.widget(find.byType(Switch));
    expect(switchWidget.value, true);
  });
}
