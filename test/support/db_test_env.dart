import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Installs the database-backed test environment shared by every service and
/// provider test: the sqflite FFI factory, a mocked `path_provider` pointed at
/// a throwaway temp directory unique to this test file, and a clean
/// `SharedPreferences` before each test.
///
/// WHY this module exists: this ~25-line setup block was copy-pasted across 18
/// test files and had already drifted between copies — one threw
/// `UnimplementedError` from the mock handler, another returned `null`; one used
/// `methodCall` and another `call`; every file pointed `path_provider` at the
/// *same* `Directory.systemTemp`, so the writable `app_data.db` leaked on-disk
/// state across files and was the documented reason for `concurrency: 1`.
/// Concentrating the setup here gives one place to fix the mock and one
/// isolated documents directory per file.
///
/// Call once at the top of a test file's `main()`:
///
/// ```dart
/// void main() {
///   useDatabaseTestEnv();
///   // ... groups / tests ...
/// }
/// ```
///
/// Pass [prefs] to seed `SharedPreferences` before each test.
void useDatabaseTestEnv({Map<String, Object> prefs = const {}}) {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory documentsDir;

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // WHY: A fresh directory per test file isolates the writable app_data.db so
    // no state survives into the next file. The bundled read-only DBs are
    // re-copied here on demand by BundledDatabaseStore.
    documentsDir = await Directory.systemTemp.createTemp('mushaf_test_');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async {
            if (call.method == 'getApplicationDocumentsDirectory') {
              return documentsDir.path;
            }
            // Other path_provider lookups are unused in tests.
            return null;
          },
        );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues(prefs);
  });

  tearDownAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    if (await documentsDir.exists()) {
      await documentsDir.delete(recursive: true);
    }
  });
}
