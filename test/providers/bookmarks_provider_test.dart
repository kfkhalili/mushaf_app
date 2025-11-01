import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mushaf_app/providers.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('BookmarksNotifier', () {
    late ProviderContainer container;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();

      // Set up mock SharedPreferences for migration service
      SharedPreferences.setMockInitialValues({});

      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      // Mock path_provider
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (call) async {
              if (call.method == 'getApplicationDocumentsDirectory') {
                return Directory.systemTemp.path;
              }
              return null;
            },
          );
    });

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() async {
      // Wait a bit before disposing to allow async operations to complete
      await Future.delayed(const Duration(milliseconds: 100));
      container.dispose();
    });

    tearDownAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            null,
          );
    });

    test('initializes with list', () async {
      // Wait for the provider to initialize properly
      // The provider loads bookmarks from the database asynchronously
      final bookmarks = await container.read(bookmarksProvider.future);
      expect(bookmarks, isA<List>());
      // List may be empty or contain migrated data
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}
