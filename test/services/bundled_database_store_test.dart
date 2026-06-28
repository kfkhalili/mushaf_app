import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mushaf_app/constants.dart';
import 'package:mushaf_app/exceptions/database_exceptions.dart';
import 'package:mushaf_app/services/bundled_database_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Initialize sqflite for testing (required for non-device tests).
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Mock path_provider so the store copies into a temp directory.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getApplicationDocumentsDirectory') {
              return Directory.systemTemp.path;
            }
            throw UnimplementedError();
          },
        );
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
  });

  group('BundledDatabaseStore', () {
    const store = BundledDatabaseStore();

    test('opens a whitelisted bundled database read-only', () async {
      final db = await store.open(metadataDbFileName);
      addTearDown(db.close);

      expect(db.isOpen, isTrue);
      // A trivial query proves the connection is usable.
      final result = await db.rawQuery('SELECT 1 AS value');
      expect(result.first['value'], 1);
    });

    test('rejects an asset name that is not on the whitelist', () async {
      expect(
        () => store.open('definitely-not-a-bundled.db'),
        throwsA(isA<DatabaseConnectionException>()),
      );
    });

    test('rejects a name that attempts path traversal', () async {
      // Not on the whitelist, so it is refused before any file is touched.
      expect(
        () => store.open('../escape.db'),
        throwsA(isA<DatabaseConnectionException>()),
      );
    });

    test('whitelist covers every bundled database name', () {
      // Guards against a new bundled DB being added without whitelisting it.
      expect(bundledDatabaseFileNames, contains(layoutDbFileName));
      expect(bundledDatabaseFileNames, contains(scriptDbFileName));
      expect(bundledDatabaseFileNames, contains(imlaeiSimpleDbFileName));
      expect(bundledDatabaseFileNames, contains(audioDbFileName));
      expect(bundledDatabaseFileNames, contains(tafsirDbFileName));
      expect(bundledDatabaseFileNames, contains(topicsDbFileName));
    });
  });
}
