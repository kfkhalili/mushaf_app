import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:mushaf_app/services/database_service.dart';
import 'package:mushaf_app/services/recitation_range.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
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

  group('RecitationRange.resolveEndAyah', () {
    late DatabaseService db;
    late RecitationRange range;

    setUp(() async {
      db = DatabaseService();
      await db.init();
      range = RecitationRange(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('surah option ends at the last ayah of the start surah', () async {
      final end = await range.resolveEndAyah(
        start: (surah: 2, ayah: 1),
        option: RecitationEndOption.surah,
      );
      expect(end, isNotNull);
      expect(end!.surah, 2);
      expect(end.ayah, 286); // Al-Baqarah has 286 ayahs.
    });

    test('juz option ends at the last ayah of the containing juz', () async {
      final end = await range.resolveEndAyah(
        start: (surah: 1, ayah: 1),
        option: RecitationEndOption.juz,
      );
      expect(end, isNotNull);
      // Juz 1 spans Al-Fatiha 1:1 to Al-Baqarah 2:141.
      expect(end!.surah, 2);
      expect(end.ayah, 141);
    });

    test('page option ends at the last ayah on the given page', () async {
      final end = await range.resolveEndAyah(
        start: (surah: 1, ayah: 1),
        option: RecitationEndOption.page,
        currentPage: 1,
      );
      expect(end, isNotNull);
      // Page 1 is Al-Fatiha (7 ayahs).
      expect(end!.surah, 1);
      expect(end.ayah, 7);
    });

    test('page option returns null when no page is provided', () async {
      final end = await range.resolveEndAyah(
        start: (surah: 1, ayah: 1),
        option: RecitationEndOption.page,
      );
      expect(end, isNull);
    });
  });
}
