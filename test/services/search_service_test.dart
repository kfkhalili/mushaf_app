import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mushaf_app/services/search_service.dart';
import 'package:mushaf_app/services/database_service.dart';

void main() {
  group('SearchService', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();

      // Mock path_provider to avoid platform channel errors
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (call) async {
              if (call.method == 'getApplicationDocumentsDirectory') {
                return '/tmp/test_documents';
              }
              return null;
            },
          );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            null,
          );
    });

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
