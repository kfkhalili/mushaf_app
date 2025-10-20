import 'package:flutter/foundation.dart'; // For list equality

@immutable // Make models immutable for better state management
class Word {
  final String text;
  const Word({required this.text});

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Word && text == other.text;

  @override
  int get hashCode => text.hashCode;
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
          listEquals(words, other.words); // Use listEquals for lists

  @override
  int get hashCode => Object.hash(
    lineNumber,
    lineType,
    isCentered,
    surahNumber,
    surahName,
    Object.hashAll(words),
  ); // Use Object.hashAll
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
  final int juzNumber;
  final int hizbNumber;

  const PageData({
    required this.layout,
    required this.pageFontFamily,
    required this.pageSurahName,
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
          juzNumber == other.juzNumber &&
          hizbNumber == other.hizbNumber;

  @override
  int get hashCode =>
      Object.hash(layout, pageFontFamily, pageSurahName, juzNumber, hizbNumber);
}
