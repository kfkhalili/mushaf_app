import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:mushaf_app/providers.dart';
import 'package:mushaf_app/models.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('ReadingStatisticsProviders', () {
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

    test('readingStatisticsProvider returns statistics', () async {
      // Reading statistics provider should return valid statistics
      final statistics = await container.read(readingStatisticsProvider.future);

      expect(statistics, isA<ReadingStatistics>());
      expect(statistics.pagesToday, greaterThanOrEqualTo(0));
      expect(statistics.pagesThisWeek, greaterThanOrEqualTo(0));
      expect(statistics.pagesThisMonth, greaterThanOrEqualTo(0));
    });

    test('pagesReadTodayProvider returns count', () async {
      // Pages read today provider should return a count
      final count = await container.read(pagesReadTodayProvider.future);

      expect(count, isA<int>());
      expect(count, greaterThanOrEqualTo(0));
    });

    test('currentStreakProvider returns streak count', () async {
      // Current streak provider should return a streak count
      final streak = await container.read(currentStreakProvider.future);

      expect(streak, isA<int>());
      expect(streak, greaterThanOrEqualTo(0));
    });

    test('readingStatisticsProvider includes all required fields', () async {
      // Verify statistics include all required fields
      final statistics = await container.read(readingStatisticsProvider.future);

      // All fields should be non-null and valid
      expect(statistics.pagesToday, isNotNull);
      expect(statistics.pagesThisWeek, isNotNull);
      expect(statistics.pagesThisMonth, isNotNull);
      expect(statistics.daysThisWeek, isNotNull);
      expect(statistics.daysThisMonth, isNotNull);
      expect(statistics.averagePagesPerDay, isNotNull);
    });
  });
}

