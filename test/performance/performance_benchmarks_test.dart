import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mushaf_app/services/database_service.dart';
import 'package:mushaf_app/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Initialize sqflite for testing (required for non-device tests)
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Mock path_provider platform channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getApplicationDocumentsDirectory') {
              // Return a temporary directory for tests
              return Directory.systemTemp.path;
            }
            throw UnimplementedError();
          },
        );
  });

  tearDownAll(() {
    // Clear mock handlers
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
  });

  group('Performance Benchmarks', () {
    late DatabaseService service;

    setUp(() async {
      service = DatabaseService();
      await service.init(layout: MushafLayout.uthmani15Lines);
    });

    tearDown(() async {
      await service.close();
    });

    test('getPageLayout performance benchmark', () async {
      final stopwatch = Stopwatch()..start();

      // Measure average time for 10 page loads
      for (int i = 0; i < 10; i++) {
        await service.getPageLayout(1);
      }

      stopwatch.stop();
      final averageTime = stopwatch.elapsedMilliseconds / 10;

      // Should complete in under 500ms per page
      expect(averageTime, lessThan(500));
    });

    test('getAllSurahs performance benchmark', () async {
      final stopwatch = Stopwatch()..start();

      await service.getAllSurahs();

      stopwatch.stop();

      // Should complete in under 1000ms
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('getAllJuzInfo performance benchmark', () async {
      final stopwatch = Stopwatch()..start();

      await service.getAllJuzInfo();

      stopwatch.stop();

      // Should complete in under 2000ms
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    test('getPageForAyah performance benchmark', () async {
      final stopwatch = Stopwatch()..start();

      // Test multiple lookups
      final testCases = [(1, 1), (2, 255), (112, 1)];

      for (final (surah, ayah) in testCases) {
        await service.getPageForAyah(surah, ayah);
      }

      stopwatch.stop();
      final averageTime = stopwatch.elapsedMilliseconds / testCases.length;

      // Should complete in under 1000ms per lookup
      expect(averageTime, lessThan(1000));
    });

    test('database initialization performance benchmark', () async {
      final stopwatch = Stopwatch()..start();

      final newService = DatabaseService();
      await newService.init(layout: MushafLayout.uthmani15Lines);

      stopwatch.stop();

      // Should complete in under 5000ms
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));

      await newService.close();
    });
  });
}
