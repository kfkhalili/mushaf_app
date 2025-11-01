import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mushaf_app/services/bookmarks_service.dart';
import 'package:mushaf_app/services/database_service.dart';

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

  group('BookmarksService Contract Tests', () {
    late SqliteBookmarksService service;
    late DatabaseService dbService;

    setUp(() async {
      dbService = DatabaseService();
      await dbService.init();
      service = SqliteBookmarksService(dbService);
    });

    tearDown(() async {
      await service.clearAllBookmarks();
      await dbService.close();
    });

    test('addBookmark creates bookmark successfully', () async {
      await service.addBookmark(1, 1);

      final isBookmarked = await service.isBookmarked(1, 1);
      expect(isBookmarked, true);
    });

    test('removeBookmark deletes bookmark successfully', () async {
      await service.addBookmark(1, 1);
      await service.removeBookmark(1, 1);

      final isBookmarked = await service.isBookmarked(1, 1);
      expect(isBookmarked, false);
    });

    test('getBookmarkByAyah returns bookmark when exists', () async {
      await service.addBookmark(2, 255);

      final bookmark = await service.getBookmarkByAyah(2, 255);

      expect(bookmark, isNotNull);
      expect(bookmark?.surahNumber, 2);
      expect(bookmark?.ayahNumber, 255);
    });

    test('getBookmarkByAyah returns null when not bookmarked', () async {
      final bookmark = await service.getBookmarkByAyah(99, 999);

      expect(bookmark, isNull);
    });

    test('getAllBookmarks returns all bookmarks', () async {
      await service.addBookmark(1, 1);
      await service.addBookmark(2, 255);
      await service.addBookmark(112, 1);

      final bookmarks = await service.getAllBookmarks();

      expect(bookmarks.length, 3);
    });

    test('getAllBookmarks sorts by newest first by default', () async {
      await service.addBookmark(1, 1);
      await Future.delayed(const Duration(milliseconds: 10));
      await service.addBookmark(2, 255);

      final bookmarks = await service.getAllBookmarks();

      expect(bookmarks.first.surahNumber, 2);
      expect(bookmarks.first.ayahNumber, 255);
    });

    test('getAllBookmarks sorts by oldest first when requested', () async {
      await service.addBookmark(1, 1);
      await Future.delayed(const Duration(milliseconds: 10));
      await service.addBookmark(2, 255);

      final bookmarks = await service.getAllBookmarks(newestFirst: false);

      expect(bookmarks.first.surahNumber, 1);
      expect(bookmarks.first.ayahNumber, 1);
    });

    test('clearAllBookmarks removes all bookmarks', () async {
      await service.addBookmark(1, 1);
      await service.addBookmark(2, 255);

      await service.clearAllBookmarks();

      final bookmarks = await service.getAllBookmarks();
      expect(bookmarks, isEmpty);
    });

    test(
      'addBookmark throws ArgumentError for invalid surah numbers',
      () async {
        expect(() => service.addBookmark(0, 1), throwsArgumentError);
        expect(() => service.addBookmark(115, 1), throwsArgumentError);
      },
    );

    test('addBookmark throws ArgumentError for invalid ayah numbers', () async {
      expect(() => service.addBookmark(1, 0), throwsArgumentError);
      expect(() => service.addBookmark(1, -1), throwsArgumentError);
    });

    test('bookmark operations are idempotent', () async {
      await service.addBookmark(1, 1);
      await service.addBookmark(1, 1); // Should not error

      final isBookmarked = await service.isBookmarked(1, 1);
      expect(isBookmarked, true);
    });
  });
}
