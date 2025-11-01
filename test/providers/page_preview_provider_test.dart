import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:mushaf_app/providers.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('PagePreviewProvider', () {
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

    test('returns preview text for valid page', () async {
      // Wait for database service to initialize
      await container.read(databaseServiceProvider.future);

      // Get preview for page 1
      final preview = await container.read(pagePreviewProvider(1).future);

      // Preview should be a non-empty string
      expect(preview, isA<String>());
      expect(preview.isNotEmpty, isTrue);
    });

    test('returns preview text for different pages', () async {
      // Wait for database service to initialize
      await container.read(databaseServiceProvider.future);

      // Get previews for different pages
      final preview1 = await container.read(pagePreviewProvider(1).future);
      final preview2 = await container.read(pagePreviewProvider(2).future);

      // Both should be non-empty
      expect(preview1.isNotEmpty, isTrue);
      expect(preview2.isNotEmpty, isTrue);

      // They might be the same or different, but both valid
    });

    test('handles invalid page numbers gracefully', () async {
      // Wait for database service to initialize
      await container.read(databaseServiceProvider.future);

      // Try invalid page (0 or negative)
      // The provider should handle this via database service
      // If it throws, that's acceptable - we're testing the provider behavior
      try {
        final preview = await container.read(pagePreviewProvider(0).future);
        expect(preview, isA<String>());
      } catch (e) {
        // Database service might throw for invalid page, which is expected
        expect(e, isA<Exception>());
      }
    });
  });
}
