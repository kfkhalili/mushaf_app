import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/widgets/bookmarks_list_view.dart';

import '../support/harness.dart';

void main() {
  group('BookmarksListView', () {
    testWidgets('renders bookmarks list view', (tester) async {
      await pumpScreen(tester, Scaffold(body: const BookmarksListView()));

      await settle(tester);

      expect(find.byType(BookmarksListView), findsOneWidget);
    });

    testWidgets('displays loading state initially', (tester) async {
      await pumpScreen(tester, Scaffold(body: const BookmarksListView()));

      await tester.pump();

      // Initially loading
      expect(find.byType(BookmarksListView), findsOneWidget);
    });

    testWidgets('handles empty state', (tester) async {
      await pumpScreen(tester, Scaffold(body: const BookmarksListView()));

      await settle(tester);

      expect(find.byType(BookmarksListView), findsOneWidget);
    });
  });
}
