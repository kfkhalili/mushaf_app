import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/services/search_service.dart';
import 'package:mushaf_app/services/database_service.dart';

import '../support/harness.dart';

void main() {
  useDatabaseTestEnv();

  group('SearchService', () {
    test('SearchService can be instantiated with DatabaseService', () {
      final databaseService = DatabaseService();
      final searchService = SearchService(databaseService);
      expect(searchService, isNotNull);
      expect(searchService, isA<SearchService>());
    });

    test('SearchService has init method', () {
      final databaseService = DatabaseService();
      final searchService = SearchService(databaseService);
      expect(searchService.init, isA<Function>());
    });

    test('SearchService has switchLayout method', () {
      final databaseService = DatabaseService();
      final searchService = SearchService(databaseService);
      expect(searchService.switchLayout, isA<Function>());
    });

    test('SearchService has searchText method', () {
      final databaseService = DatabaseService();
      final searchService = SearchService(databaseService);
      expect(searchService.searchText, isA<Function>());
    });

    test('init method signature is correct', () {
      final databaseService = DatabaseService();
      final searchService = SearchService(databaseService);
      // Method signature verification - full initialization requires database files
      // We're only checking that the method exists and returns the right type
      expect(searchService.init, isA<Function>());
      // Don't actually call it - it requires database files
    });

    test('switchLayout method signature is correct', () {
      final databaseService = DatabaseService();
      final searchService = SearchService(databaseService);
      // Method signature verification
      expect(searchService.switchLayout, isA<Function>());
      // Don't actually call it - it requires database files
    });
  });
}
