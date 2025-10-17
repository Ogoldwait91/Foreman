import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile/main.dart"; // path is apps/mobile/lib/main.dart, but test runner resolves by package name set in pubspec. If it fails, use relative import.

void main() {
  testWidgets("ForemanApp builds", (WidgetTester tester) async {
    await tester.pumpWidget(const ForemanApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
