import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/providers.dart';
import 'package:mushaf_app/constants.dart';
import '../support/harness.dart';

void main() {
  useDatabaseTestEnv();
  group('TotalPagesProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('reads total pages from database for Uthmani layout', () async {
      // Wait for database service to initialize
      final dbService = await container.read(databaseServiceProvider.future);

      // Initialize with Uthmani layout
      await dbService.init(layout: MushafLayout.uthmani15Lines);

      // Read total pages through provider
      final totalPages = await container.read(totalPagesProvider.future);

      // Should read from actual database (604 for Uthmani)
      expect(totalPages, greaterThan(0));
      expect(totalPages, 604);
    });

    test('reads total pages from database for Indopak layout', () async {
      // Wait for database service to initialize
      final dbService = await container.read(databaseServiceProvider.future);

      // Initialize with Indopak layout
      await dbService.init(layout: MushafLayout.indopak13Lines);

      // Read total pages through provider
      final totalPages = await container.read(totalPagesProvider.future);

      // Should read from actual database info table
      expect(totalPages, greaterThan(0));
      // Value depends on what's in the indopak database
    });

    test('reads 1890 pages for the Indopak 9-line layout', () async {
      final dbService = await container.read(databaseServiceProvider.future);

      await dbService.init(layout: MushafLayout.indopak9Lines);

      final totalPages = await container.read(totalPagesProvider.future);

      expect(totalPages, 1890);
    });

    test('updates when layout changes', () async {
      // Wait for database service to initialize
      final dbService = await container.read(databaseServiceProvider.future);

      // Start with Uthmani
      await dbService.init(layout: MushafLayout.uthmani15Lines);
      final uthmaniTotal = await container.read(totalPagesProvider.future);

      // Switch to Indopak
      await dbService.switchLayout(MushafLayout.indopak13Lines);
      // Invalidate provider to force re-read
      container.invalidate(totalPagesProvider);
      final indopakTotal = await container.read(totalPagesProvider.future);

      // Both should be valid values read from their respective databases
      expect(uthmaniTotal, greaterThan(0));
      expect(indopakTotal, greaterThan(0));
    });
  });
}
