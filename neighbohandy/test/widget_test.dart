// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:neighbohandy/main.dart';

void main() {
  testWidgets('NeighborHandy shows local providers', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const NeighborHandyApp());
    expect(find.text('Welcome back.'), findsOneWidget);
    expect(find.text('Client'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testWidgets('resident can change saved city', (WidgetTester tester) async {
    await tester.pumpWidget(const NeighborHandyApp());
    await tester.enterText(find.byType(TextField).first, 'client@example.com');
    await tester.enterText(find.byType(TextField).last, 'password');
    final signInButton = find.widgetWithText(FilledButton, 'Sign in');
    await tester.ensureVisible(signInButton);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quezon City · Project 4'));
    await tester.pumpAndSettle();
    expect(find.text('Choose your city'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'Manila');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Manila'));
    await tester.pumpAndSettle();
    expect(find.text('Manila · Project 4'), findsOneWidget);
  });
}
