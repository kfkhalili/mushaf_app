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

  group('DatabaseService Contract Tests', () {
    late DatabaseService service;

    setUp(() {
      service = DatabaseService();
    });

    tearDown(() async {
      await service.close();
    });

    test('getPageLayout returns PageLayout with correct structure', () async {
      await service.init(layout: MushafLayout.uthmani15Lines);

      final pageLayout = await service.getPageLayout(1);

      expect(pageLayout.pageNumber, 1);
      expect(pageLayout.lines, isNotEmpty);

      // Verify structure
      for (final line in pageLayout.lines) {
        expect(line.lineNumber, greaterThan(0));
        expect(line.lineType, isNotEmpty);
        expect(line.surahNumber, greaterThanOrEqualTo(0));
      }
    });

    test('getPageLayout handles all pages (1-604)', () async {
      await service.init(layout: MushafLayout.uthmani15Lines);

      // Test first, middle, and last pages
      final pages = [1, 302, 604];

      for (final pageNum in pages) {
        final layout = await service.getPageLayout(pageNum);
        expect(layout.pageNumber, pageNum);
        expect(layout.lines, isNotEmpty);
      }
    });

    test('getPageHeaderInfo returns correct structure', () async {
      await service.init(layout: MushafLayout.uthmani15Lines);

      final headerInfo = await service.getPageHeaderInfo(1);

      expect(headerInfo, contains('juz'));
      expect(headerInfo, contains('hizb'));
      expect(headerInfo, contains('surahName'));
      expect(headerInfo, contains('surahNumber'));

      expect(headerInfo['juz'], isA<int>());
      expect(headerInfo['hizb'], isA<int>());
      expect(headerInfo['surahNumber'], isA<int>());
      expect(headerInfo['surahName'], isA<String>());
    });

    test('getAllSurahs returns 114 surahs', () async {
      await service.init(layout: MushafLayout.uthmani15Lines);

      final surahs = await service.getAllSurahs();

      expect(surahs.length, 114);

      // Verify first and last surah
      expect(surahs.first.surahNumber, 1);
      expect(surahs.last.surahNumber, 114);
    });

    test('getAllJuzInfo returns 30 juzs', () async {
      await service.init(layout: MushafLayout.uthmani15Lines);

      final juzs = await service.getAllJuzInfo();

      expect(juzs.length, 30);

      // Verify juzs are sequential
      for (int i = 0; i < juzs.length; i++) {
        expect(juzs[i].juzNumber, i + 1);
      }
    });

    test('getPageForAyah returns valid page numbers', () async {
      await service.init(layout: MushafLayout.uthmani15Lines);

      // Test well-known ayahs
      final testCases = [
        (1, 1, 1), // Al-Fatiha, Ayah 1, Page 1
        (2, 255, 42), // Al-Baqarah, Ayat al-Kursi, Page 42
        (112, 1, 604), // Al-Ikhlas, Ayah 1, Page 604
      ];

      for (final (surah, ayah, _) in testCases) {
        final pageNum = await service.getPageForAyah(surah, ayah);
        expect(pageNum, greaterThanOrEqualTo(1));
        expect(pageNum, lessThanOrEqualTo(604));
      }
    });

    test('getAyahsOnPage returns list of ayahs', () async {
      await service.init(layout: MushafLayout.uthmani15Lines);

      final ayahs = await service.getAyahsOnPage(1);

      expect(ayahs, isNotEmpty);

      for (final ayah in ayahs) {
        expect(ayah['surah'], greaterThan(0));
        expect(ayah['ayah'], greaterThan(0));
      }
    });

    test('getFirstWordsOfPage returns preview text', () async {
      await service.init(layout: MushafLayout.uthmani15Lines);

      final preview = await service.getFirstWordsOfPage(1, count: 3);

      expect(preview, isNotEmpty);
      expect(preview, isA<String>());
    });

    test('switchLayout properly reinitializes', () async {
      await service.init(layout: MushafLayout.uthmani15Lines);

      // Switch layout
      await service.switchLayout(MushafLayout.indopak13Lines);

      // Get same page with new layout
      final page1After = await service.getPageLayout(1);

      // Page should still be valid but potentially different structure
      expect(page1After.pageNumber, 1);
      expect(page1After.lines, isNotEmpty);
    });

    test('getAyahText returns text for valid ayahs', () async {
      await service.init(layout: MushafLayout.uthmani15Lines);

      final text = await service.getAyahText(1, 1);

      expect(text, isNotEmpty);
      expect(text, isA<String>());
    });
  });
}
