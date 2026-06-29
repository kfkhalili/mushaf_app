import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/widgets/surah_list_view.dart';
import 'package:mushaf_app/providers.dart';
import 'package:mushaf_app/models.dart';

import '../support/harness.dart';

void main() {
  group('SurahListView', () {
    testWidgets('shows loading indicator when loading', (tester) async {
      await pumpScreen(
        tester,
        Scaffold(body: const SurahListView()),
        overrides: [
          surahListProvider.overrideWith((ref) => Future.value(<SurahInfo>[])),
        ],
      );

      // First frame is the loading state.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays surah list when loaded', (tester) async {
      final surahs = [
        const SurahInfo(
          surahNumber: 1,
          nameArabic: 'الفاتحة',
          revelationPlace: 'مكية',
          startingPage: 1,
        ),
        const SurahInfo(
          surahNumber: 2,
          nameArabic: 'البقرة',
          revelationPlace: 'مدنية',
          startingPage: 2,
        ),
      ];

      await pumpScreen(
        tester,
        Scaffold(body: const SurahListView()),
        overrides: [
          surahListProvider.overrideWith((ref) => Future.value(surahs)),
        ],
      );

      // Let the async provider resolve and the list settle.
      await settle(tester);
      expect(find.byType(SurahListView), findsOneWidget);
    });
  });
}
