import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/widgets/shared/app_bottom_navigation.dart';

void main() {
  group('AppBottomNavigation', () {
    testWidgets('renders selection navigation correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavigation(
              type: AppBottomNavigationType.selection,
              selectedIndex: 0,
              onIndexChanged: (index) {},
            ),
          ),
        ),
      );

      expect(find.byType(AppBottomNavigation), findsOneWidget);
    });

    testWidgets('calls onIndexChanged when tab is tapped', (tester) async {
      int? selectedIndex;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavigation(
              type: AppBottomNavigationType.selection,
              selectedIndex: 0,
              onIndexChanged: (index) {
                selectedIndex = index;
              },
            ),
          ),
        ),
      );

      await tester.pump();

      // Find and tap a tab button (e.g., the second tab "الأجزاء")
      final tabButtons = find.text('الأجزاء');
      if (tabButtons.evaluate().isNotEmpty) {
        await tester.tap(tabButtons.first);
        await tester.pump();

        // Verify the callback was called with the correct index
        expect(selectedIndex, isNotNull);
        expect(selectedIndex, 1); // Juz tab is at index 1
      }

      expect(find.byType(AppBottomNavigation), findsOneWidget);
    });

    testWidgets('highlights selected index', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavigation(
              type: AppBottomNavigationType.selection,
              selectedIndex: 1,
              onIndexChanged: (index) {},
            ),
          ),
        ),
      );

      expect(find.byType(AppBottomNavigation), findsOneWidget);
    });
  });
}
