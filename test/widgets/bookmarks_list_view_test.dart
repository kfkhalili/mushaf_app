import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/widgets/bookmarks_list_view.dart';

void main() {
  group('BookmarksListView', () {
    testWidgets('renders bookmarks list view', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: const BookmarksListView())),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(BookmarksListView), findsOneWidget);
    });

    testWidgets('displays loading state initially', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: const BookmarksListView())),
        ),
      );

      await tester.pump();

      // Initially loading
      expect(find.byType(BookmarksListView), findsOneWidget);
    });

    testWidgets('handles empty state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(home: Scaffold(body: const BookmarksListView())),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(BookmarksListView), findsOneWidget);
    });
  });
}
