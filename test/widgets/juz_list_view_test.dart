import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/widgets/juz_list_view.dart';
import 'package:mushaf_app/providers.dart';
import 'package:mushaf_app/models.dart';

void main() {
  group('JuzListView', () {
    testWidgets('shows loading indicator when loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          // ignore: argument_type_not_assignable
          overrides: [
            juzListProvider.overrideWith((ref) => Future.value(<JuzInfo>[])),
          ],
          child: MaterialApp(home: Scaffold(body: const JuzListView())),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays juz list when loaded', (tester) async {
      final juzs = [
        const JuzInfo(juzNumber: 1, startingPage: 1),
        const JuzInfo(juzNumber: 2, startingPage: 22),
      ];

      await tester.pumpWidget(
        ProviderScope(
          // ignore: argument_type_not_assignable
          overrides: [
            juzListProvider.overrideWith((ref) => Future.value(juzs)),
          ],
          child: MaterialApp(home: Scaffold(body: const JuzListView())),
        ),
      );

      await tester.pumpAndSettle();

      // JuzListView should display juz information
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
