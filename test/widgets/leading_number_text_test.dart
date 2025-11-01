import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/widgets/shared/leading_number_text.dart';

void main() {
  group('LeadingNumberText', () {
    testWidgets('renders number correctly with eastern numerals', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: LeadingNumberText(number: 1))),
      );

      expect(find.text('١'), findsOneWidget);
    });

    testWidgets('renders with different numbers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: LeadingNumberText(number: 114))),
      );

      expect(find.text('١١٤'), findsOneWidget);
    });

    testWidgets('renders zero correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: LeadingNumberText(number: 0))),
      );

      expect(find.text('٠'), findsOneWidget);
    });
  });
}
