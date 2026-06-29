import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/widgets/page_list_view.dart';
import 'package:mushaf_app/providers.dart';

import '../support/harness.dart';

void main() {
  group('PageListView', () {
    testWidgets('renders page list view', (tester) async {
      await pumpScreen(tester, Scaffold(body: const PageListView()));

      await tester.pump();

      expect(find.byType(PageListView), findsOneWidget);
    });

    testWidgets('displays page previews when loaded', (tester) async {
      await pumpScreen(
        tester,
        Scaffold(body: const PageListView()),
        overrides: [
          totalPagesProvider.overrideWith((ref) => Future.value(604)),
          pagePreviewProvider.overrideWith(
            (ref, pageNumber) => Future.value('Preview $pageNumber'),
          ),
          pageFontFamilyProvider.overrideWith(
            (ref, pageNumber) => Future.value('Uthmani'),
          ),
        ],
      );

      await settle(tester);

      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
