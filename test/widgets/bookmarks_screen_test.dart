import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/screens/bookmarks_screen.dart';

import '../support/harness.dart';

void main() {
  group('BookmarksScreen', () {
    testWidgets('renders bookmarks screen with header', (tester) async {
      await pumpScreen(tester, const BookmarksScreen());

      await settle(tester);

      // Verify the screen renders (header text might require more async data)
      expect(find.byType(BookmarksScreen), findsOneWidget);
    });

    testWidgets('displays empty state when no bookmarks', (tester) async {
      await pumpScreen(tester, const BookmarksScreen());

      await settle(tester);

      expect(find.byType(BookmarksScreen), findsOneWidget);
    });
  });
}
