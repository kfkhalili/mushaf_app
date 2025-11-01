import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/widgets/bookmark_item_card.dart';
import 'package:mushaf_app/models.dart';

void main() {
  group('BookmarkItemCard', () {
    testWidgets('renders bookmark information', (tester) async {
      final bookmark = Bookmark(
        id: 1,
        surahNumber: 1,
        ayahNumber: 1,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: BookmarkItemCard(bookmark: bookmark)),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(BookmarkItemCard), findsOneWidget);
    });

    testWidgets('displays surah and ayah information', (tester) async {
      final bookmark = Bookmark(
        id: 1,
        surahNumber: 1,
        ayahNumber: 1,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: BookmarkItemCard(bookmark: bookmark)),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(BookmarkItemCard), findsOneWidget);
    });
  });
}
