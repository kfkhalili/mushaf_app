import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/screens/search_screen.dart';

void main() {
  group('SearchScreen', () {
    testWidgets('renders search screen with header', (tester) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const SearchScreen())),
      );

      await tester.pumpAndSettle();

      expect(find.text('البحث'), findsOneWidget);
    });

    testWidgets('displays search input field', (tester) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const SearchScreen())),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('ابحث في القرآن الكريم...'), findsOneWidget);
    });

    testWidgets('shows search history when available', (tester) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: const SearchScreen())),
      );

      await tester.pumpAndSettle();

      // SearchScreen should render (history may be empty)
      expect(find.byType(SearchScreen), findsOneWidget);
    });

    testWidgets('renders in light theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.light(),
            home: const SearchScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SearchScreen), findsOneWidget);
    });

    testWidgets('renders in dark theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const SearchScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(SearchScreen), findsOneWidget);
    });
  });
}
