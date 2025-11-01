import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:mushaf_app/services/reading_progress_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('ReadingProgressService', () {
    late SqliteReadingProgressService service;

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
      service = SqliteReadingProgressService();
    });

    tearDown(() async {
      // Cleanup database
      try {
        await service.clearAllData();
      } catch (e) {
        // Ignore cleanup errors
      }
    });

    test('recordPageView records valid page numbers', () async {
      await service.recordPageView(1);
      final stats = await service.getStatistics();
      expect(stats.totalPagesRead, 1);
    });

    test(
      'recordPageView throws ArgumentError for invalid page numbers',
      () async {
        expect(() => service.recordPageView(0), throwsA(isA<ArgumentError>()));
        expect(
          () => service.recordPageView(605),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test('getStatistics returns empty statistics initially', () async {
      final stats = await service.getStatistics();
      expect(stats.totalPagesRead, 0);
      expect(stats.totalReadingDays, 0);
      expect(stats.currentStreak, 0);
    });

    test('getPagesReadToday returns 0 initially', () async {
      final pagesToday = await service.getPagesReadToday();
      expect(pagesToday, 0);
    });

    test('getCurrentStreak returns 0 initially', () async {
      final streak = await service.getCurrentStreak();
      expect(streak, 0);
    });

    test('getStatistics calculates total pages correctly', () async {
      await service.recordPageView(1);
      await service.recordPageView(2);
      await service.recordPageView(3);

      final stats = await service.getStatistics();
      expect(stats.totalPagesRead, 3);
    });

    test('clearAllData removes all data', () async {
      await service.recordPageView(1);
      await service.clearAllData();

      final stats = await service.getStatistics();
      expect(stats.totalPagesRead, 0);
    });
  });
}
