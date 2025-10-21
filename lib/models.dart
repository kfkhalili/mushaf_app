import 'package:flutter/foundation.dart';

// --- New Model for Surah List ---
@immutable
class SurahInfo {
  final int surahNumber;
  final String nameArabic;
  final String revelationPlace;
  final int startingPage;

  const SurahInfo({
    required this.surahNumber,
    required this.nameArabic,
    required this.revelationPlace,
    required this.startingPage,
  });
}

// --- Existing Models ---
@immutable
class Word {
  final String text;
  // WHY: We must know the surah/ayah for each word to control visibility.
  final int surahNumber;
  final int ayahNumber;

  const Word({
    required this.text,
    required this.surahNumber,
    required this.ayahNumber,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Word &&
          text == other.text &&
          surahNumber == other.surahNumber &&
          ayahNumber == other.ayahNumber;

  @override
  int get hashCode => Object.hash(text, surahNumber, ayahNumber);
}

@immutable
class LineInfo {
  final int lineNumber;
  final String lineType;
  final bool isCentered;
  final int surahNumber;
  final String? surahName;
  final List<Word> words;

  const LineInfo({
    required this.lineNumber,
    required this.lineType,
    required this.isCentered,
    required this.surahNumber,
    this.surahName,
    this.words = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LineInfo &&
          lineNumber == other.lineNumber &&
          lineType == other.lineType &&
          isCentered == other.isCentered &&
          surahNumber == other.surahNumber &&
          surahName == other.surahName &&
          listEquals(words, other.words);

  @override
  int get hashCode => Object.hash(
    lineNumber,
    lineType,
    isCentered,
    surahNumber,
    surahName,
    Object.hashAll(words),
  );
}

@immutable
class PageLayout {
  final int pageNumber;
  final List<LineInfo> lines;
  const PageLayout({required this.pageNumber, required this.lines});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageLayout &&
          pageNumber == other.pageNumber &&
          listEquals(lines, other.lines);

  @override
  int get hashCode => Object.hash(pageNumber, Object.hashAll(lines));
}

@immutable
class PageData {
  final PageLayout layout;
  final String pageFontFamily;
  final String pageSurahName;
  final int pageSurahNumber;
  final int juzNumber;
  final int hizbNumber;

  const PageData({
    required this.layout,
    required this.pageFontFamily,
    required this.pageSurahName,
    required this.pageSurahNumber,
    required this.juzNumber,
    required this.hizbNumber,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageData &&
          layout == other.layout &&
          pageFontFamily == other.pageFontFamily &&
          pageSurahName == other.pageSurahName &&
          pageSurahNumber == other.pageSurahNumber &&
          juzNumber == other.juzNumber &&
          hizbNumber == other.hizbNumber;

  @override
  int get hashCode => Object.hash(
    layout,
    pageFontFamily,
    pageSurahName,
    pageSurahNumber,
    juzNumber,
    hizbNumber,
  );
}
