import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/widgets/countdown_circle.dart';

void main() {
  group('CountdownCircle', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: CountdownCircle())),
      );

      expect(find.byType(CountdownCircle), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountdownCircle(
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.pump();
      // Tap on the GestureDetector widget (CountdownCircle uses GestureDetector internally)
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 100),
      ); // Wait for animation
      expect(tapped, isTrue);
    });

    testWidgets('displays centerLabel when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: CountdownCircle(centerLabel: '5')),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify the widget renders correctly with centerLabel
      expect(find.byType(CountdownCircle), findsOneWidget);
      // The RichText widget should be present when centerLabel is provided
      expect(find.byType(RichText), findsOneWidget);
    });

    testWidgets(
      'hides content when showNumber is false and centerLabel is null',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CountdownCircle(showNumber: false, centerLabel: null),
            ),
          ),
        );

        expect(find.byType(CountdownCircle), findsOneWidget);
        // Content should be hidden when both showNumber is false and centerLabel is null
        expect(find.byType(SizedBox), findsWidgets);
      },
    );
  });
}
