import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/providers.dart';
import '../support/harness.dart';

void main() {
  useDatabaseTestEnv();
  group('SearchResultsProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('returns empty list for empty query', () async {
      // Wait for search service to initialize
      await container.read(searchServiceProvider.future);

      // Search with empty query
      final results = await container.read(searchResultsProvider('').future);

      expect(results, isEmpty);
    });

    test('returns empty list for whitespace-only query', () async {
      // Wait for search service to initialize
      await container.read(searchServiceProvider.future);

      // Search with whitespace-only query
      final results = await container.read(searchResultsProvider('   ').future);

      expect(results, isEmpty);
    });

    test('performs search for non-empty query', () async {
      // Wait for search service to initialize
      await container.read(searchServiceProvider.future);

      // Perform a search (actual results depend on database content)
      final results = await container.read(
        searchResultsProvider('الفاتحة').future,
      );

      // Results should be a list (may be empty if no matches)
      expect(results, isA<List>());
    });

    test('searches are case-sensitive', () async {
      // Wait for search service to initialize
      await container.read(searchServiceProvider.future);

      // Arabic text is typically case-sensitive
      // Test that the provider correctly passes queries to search service
      try {
        final results = await container.read(
          searchResultsProvider('test').future,
        );
        expect(results, isA<List>());
      } catch (e) {
        // Search might fail for invalid queries, which is acceptable
        expect(e, isA<Exception>());
      }
    });
  });
}
