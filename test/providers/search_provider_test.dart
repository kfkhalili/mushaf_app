import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/providers.dart';

void main() {
  group('SearchProvider', () {
    test('searchQueryProvider initializes to empty string', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(searchQueryProvider), '');
    });

    test('setQuery updates search query', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchQueryProvider.notifier).setQuery('test');
      expect(container.read(searchQueryProvider), 'test');
    });

    test('searchHistoryProvider initializes to empty list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(searchHistoryProvider), isEmpty);
    });

    test('addToHistory adds query to history', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchHistoryProvider.notifier).addToHistory('test1');
      expect(container.read(searchHistoryProvider), contains('test1'));
    });

    test('addToHistory prevents duplicates', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchHistoryProvider.notifier).addToHistory('test1');
      container.read(searchHistoryProvider.notifier).addToHistory('test1');

      final history = container.read(searchHistoryProvider);
      expect(history.where((h) => h == 'test1').length, 1);
    });

    test('clearHistory removes all history', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(searchHistoryProvider.notifier).addToHistory('test1');
      container.read(searchHistoryProvider.notifier).addToHistory('test2');
      container.read(searchHistoryProvider.notifier).clearHistory();

      expect(container.read(searchHistoryProvider), isEmpty);
    });
  });
}
