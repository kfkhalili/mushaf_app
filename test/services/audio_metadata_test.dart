import 'package:flutter_test/flutter_test.dart';
import 'package:mushaf_app/exceptions/database_exceptions.dart';
import 'package:mushaf_app/services/audio_metadata.dart';

import '../support/harness.dart';

void main() {
  useDatabaseTestEnv();

  group('AudioMetadata', () {
    late AudioMetadata audio;

    setUp(() async {
      audio = AudioMetadata();
      await audio.init();
    });

    tearDown(() async {
      await audio.close();
    });

    test('surahAudio returns a usable audio URL for a surah', () async {
      final result = await audio.surahAudio(2);
      expect(result, isNotNull);
      expect(result!.surahNumber, 2);
      expect(result.audioUrl, isNotEmpty);
    });

    test('ayahSegment returns timings for a specific ayah', () async {
      final segment = await audio.ayahSegment(2, 1);
      expect(segment, isNotNull);
      expect(segment!.surahNumber, 2);
      expect(segment.ayahNumber, 1);
    });

    test('surahSegments are ordered and cover the whole surah', () async {
      final segments = await audio.surahSegments(2);
      expect(segments, isNotEmpty);
      expect(segments.first.ayahNumber, 1);
      // Al-Baqarah has 286 ayat — this is the source getLastAyahInSurah reads.
      expect(segments.last.ayahNumber, 286);
    });

    test('throws when queried before init', () {
      final uninitialized = AudioMetadata();
      expect(
        () => uninitialized.surahAudio(1),
        throwsA(isA<DatabaseNotInitializedException>()),
      );
    });
  });
}
