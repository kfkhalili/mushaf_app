import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/widgets/page_list_view.dart';
import 'package:mushaf_app/providers.dart';

void main() {
  group('PageListView', () {
    testWidgets('renders page list view', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: const PageListView())),
        ),
      );

      await tester.pump();

      expect(find.byType(PageListView), findsOneWidget);
    });

    testWidgets('displays page previews when loaded', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          // ignore: argument_type_not_assignable
          overrides: [
            pagePreviewProvider.overrideWith(
              (ref, pageNumber) => Future.value('Preview $pageNumber'),
            ),
            pageFontFamilyProvider.overrideWith(
              (ref, pageNumber) => Future.value('Uthmani'),
            ),
          ],
          child: MaterialApp(home: Scaffold(body: const PageListView())),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
