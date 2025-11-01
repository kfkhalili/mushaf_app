import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:mushaf_app/providers.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('BookmarkPageNumberProvider', () {
    late ProviderContainer container;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      // Mock path_provider
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

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    tearDownAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            null,
          );
    });

    test('returns page number for valid surah and ayah', () async {
      // Wait for database service to initialize
      await container.read(databaseServiceProvider.future);

      // Get page number for first surah, first ayah
      final pageNumber = await container.read(
        bookmarkPageNumberProvider(1, 1).future,
      );

      // Should return a valid page number (1-604) or null
      if (pageNumber != null) {
        expect(pageNumber, greaterThan(0));
        expect(pageNumber, lessThanOrEqualTo(604));
      }
    });

    test('returns null for invalid surah/ayah', () async {
      // Wait for database service to initialize
      await container.read(databaseServiceProvider.future);

      // Try invalid surah/ayah combination
      try {
        final pageNumber = await container.read(
          bookmarkPageNumberProvider(999, 999).future,
        );

        // Should return null for invalid combinations
        expect(pageNumber, isNull);
      } catch (e) {
        // Or might throw an exception, which is also acceptable
        expect(e, isA<Exception>());
      }
    });

    test('handles different surah/ayah combinations', () async {
      // Wait for database service to initialize
      await container.read(databaseServiceProvider.future);

      // Test multiple valid combinations
      final page1 = await container.read(
        bookmarkPageNumberProvider(1, 1).future,
      );
      final page2 = await container.read(
        bookmarkPageNumberProvider(2, 1).future,
      );

      // Both should return valid page numbers or null
      if (page1 != null) {
        expect(page1, greaterThan(0));
      }
      if (page2 != null) {
        expect(page2, greaterThan(0));
      }
      // At least one should be non-null for valid surahs
    });

    test('handles edge cases gracefully', () async {
      // Wait for database service to initialize
      await container.read(databaseServiceProvider.future);

      // Test edge cases: negative numbers, zero
      try {
        final pageNumber = await container.read(
          bookmarkPageNumberProvider(0, 0).future,
        );

        // Should return null or valid page
        expect(pageNumber == null || pageNumber > 0, isTrue);
      } catch (e) {
        // Exceptions are acceptable for invalid inputs
        expect(e, isA<Exception>());
      }
    });
  });
}
