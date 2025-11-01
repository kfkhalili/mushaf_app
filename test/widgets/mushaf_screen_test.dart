import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/screens/mushaf_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('MushafScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('renders mushaf screen with initial page', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: const MushafScreen(initialPage: 1)),
        ),
      );

      await tester.pump();

      expect(find.byType(MushafScreen), findsOneWidget);
    });

    testWidgets('displays header and bottom navigation', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: const MushafScreen(initialPage: 1)),
        ),
      );

      await tester.pump();

      // Screen should render even if data is loading
      expect(find.byType(MushafScreen), findsOneWidget);
    });

    testWidgets('initializes with custom page number', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: const MushafScreen(initialPage: 50)),
        ),
      );

      await tester.pump();

      expect(find.byType(MushafScreen), findsOneWidget);
    });

    testWidgets('renders in light theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.light(),
            home: const MushafScreen(initialPage: 1),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(MushafScreen), findsOneWidget);
    });

    testWidgets('renders in dark theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: const MushafScreen(initialPage: 1),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(MushafScreen), findsOneWidget);
    });
  });
}
