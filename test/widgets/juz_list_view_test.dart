import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/widgets/juz_list_view.dart';
import 'package:mushaf_app/providers.dart';
import 'package:mushaf_app/models.dart';

import '../support/harness.dart';

void main() {
  group('JuzListView', () {
    testWidgets('shows loading indicator when loading', (tester) async {
      await pumpScreen(
        tester,
        Scaffold(body: const JuzListView()),
        overrides: [
          juzListProvider.overrideWith((ref) => Future.value(<JuzInfo>[])),
        ],
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays juz list when loaded', (tester) async {
      final juzs = [
        const JuzInfo(juzNumber: 1, startingPage: 1),
        const JuzInfo(juzNumber: 2, startingPage: 22),
      ];

      await pumpScreen(
        tester,
        Scaffold(body: const JuzListView()),
        overrides: [juzListProvider.overrideWith((ref) => Future.value(juzs))],
      );

      await settle(tester);

      // JuzListView should display juz information
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
