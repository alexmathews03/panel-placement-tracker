import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drivedeck/main.dart';

void main() {
  testWidgets('DriveDeckApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DriveDeckApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
