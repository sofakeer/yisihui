// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:yisihui/app/app.dart';

void main() {
  testWidgets('App initializes and shows splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: YisihuiApp(),
      ),
    );

    // Verify that splash screen elements are present
    expect(find.text('易思汇'), findsOneWidget);
    expect(find.text('留学缴费 · 安全便捷'), findsOneWidget);
  });
}
