import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/providers.dart';
import 'package:mushaf_app/constants.dart';

void main() {
  group('Provider Contract Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('currentPageProvider initializes correctly', () {
      final page = container.read(currentPageProvider);
      expect(page, 1);
    });

    test('currentPageProvider.setPage updates state', () {
      container.read(currentPageProvider.notifier).setPage(5);
      expect(container.read(currentPageProvider), 5);
    });

    test('mushafLayoutSettingProvider initializes correctly', () {
      final layout = container.read(mushafLayoutSettingProvider);
      expect(layout, MushafLayout.uthmani15Lines);
    });

    test('mushafLayoutSettingProvider.setLayout updates state', () {
      container
          .read(mushafLayoutSettingProvider.notifier)
          .setLayout(MushafLayout.indopak13Lines);

      expect(
        container.read(mushafLayoutSettingProvider),
        MushafLayout.indopak13Lines,
      );
    });

    test('fontSizeSettingProvider responds to layout changes', () {
      final initialSize = container.read(fontSizeSettingProvider);

      container
          .read(mushafLayoutSettingProvider.notifier)
          .setLayout(MushafLayout.indopak13Lines);

      final newSize = container.read(fontSizeSettingProvider);
      expect(newSize, isNot(initialSize));
    });

    test('selectionTabIndexProvider initializes correctly', () {
      final tabIndex = container.read(selectionTabIndexProvider);
      expect(tabIndex, 0);
    });

    test('selectionTabIndexProvider.setTabIndex updates state', () {
      container.read(selectionTabIndexProvider.notifier).setTabIndex(1);
      expect(container.read(selectionTabIndexProvider), 1);
    });

    test('searchQueryProvider initializes with empty string', () {
      final query = container.read(searchQueryProvider);
      expect(query, '');
    });

    test('searchQueryProvider.setQuery updates state', () {
      container.read(searchQueryProvider.notifier).setQuery('test query');
      expect(container.read(searchQueryProvider), 'test query');
    });

    test('searchQueryProvider.clearQuery resets to empty', () {
      container.read(searchQueryProvider.notifier).setQuery('test');
      container.read(searchQueryProvider.notifier).clearQuery();
      expect(container.read(searchQueryProvider), '');
    });

    test('searchHistoryProvider initializes with empty list', () {
      final history = container.read(searchHistoryProvider);
      expect(history, isEmpty);
    });

    test('searchHistoryProvider.addToHistory adds query', () {
      container.read(searchHistoryProvider.notifier).addToHistory('test');
      final history = container.read(searchHistoryProvider);
      expect(history, contains('test'));
    });

    test('searchHistoryProvider respects max history items', () {
      final notifier = container.read(searchHistoryProvider.notifier);

      // Add more than max (20) items
      for (int i = 0; i < 25; i++) {
        notifier.addToHistory('query_$i');
      }

      final history = container.read(searchHistoryProvider);
      expect(history.length, lessThanOrEqualTo(20));
    });
  });
}
