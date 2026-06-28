import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

// --- Search Result Model ---
@immutable
class SearchResult extends Equatable {
  final String text;
  final int surahNumber;
  final int ayahNumber;
  final int pageNumber;
  final String surahName;
  final String context; // Surrounding text for context
  final int wordPosition; // Position of the word in the ayah

  const SearchResult({
    required this.text,
    required this.surahNumber,
    required this.ayahNumber,
    required this.pageNumber,
    required this.surahName,
    required this.context,
    required this.wordPosition,
  });

  @override
  List<Object?> get props => [
    text,
    surahNumber,
    ayahNumber,
    pageNumber,
    surahName,
    context,
    wordPosition,
  ];
}

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
class Word extends Equatable {
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
  List<Object?> get props => [text, surahNumber, ayahNumber];
}

@immutable
class LineInfo extends Equatable {
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
  List<Object?> get props => [
    lineNumber,
    lineType,
    isCentered,
    surahNumber,
    surahName,
    words,
  ];
}

@immutable
class PageLayout extends Equatable {
  final int pageNumber;
  final List<LineInfo> lines;
  const PageLayout({required this.pageNumber, required this.lines});

  @override
  List<Object?> get props => [pageNumber, lines];
}

@immutable
class PageData extends Equatable {
  final PageLayout layout;
  final String pageFontFamily;
  final String pageSurahName;
  final int pageSurahNumber;
  final int juzNumber;
  final int hizbNumber;
  final bool isLoading;

  const PageData({
    required this.layout,
    required this.pageFontFamily,
    required this.pageSurahName,
    required this.pageSurahNumber,
    required this.juzNumber,
    required this.hizbNumber,
    this.isLoading = false,
  });

  // Factory constructor for a loading state
  factory PageData.loading() {
    return PageData(
      layout: const PageLayout(pageNumber: 0, lines: []),
      pageFontFamily: '',
      pageSurahName: '',
      pageSurahNumber: 0,
      juzNumber: 0,
      hizbNumber: 0,
      isLoading: true,
    );
  }

  PageData copyWith({
    PageLayout? layout,
    String? pageFontFamily,
    String? pageSurahName,
    int? pageSurahNumber,
    int? juzNumber,
    int? hizbNumber,
    bool? isLoading,
  }) {
    return PageData(
      layout: layout ?? this.layout,
      pageFontFamily: pageFontFamily ?? this.pageFontFamily,
      pageSurahName: pageSurahName ?? this.pageSurahName,
      pageSurahNumber: pageSurahNumber ?? this.pageSurahNumber,
      juzNumber: juzNumber ?? this.juzNumber,
      hizbNumber: hizbNumber ?? this.hizbNumber,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    layout,
    pageFontFamily,
    pageSurahName,
    pageSurahNumber,
    juzNumber,
    hizbNumber,
    isLoading,
  ];
}

@immutable
class JuzInfo {
  final int juzNumber;
  final int startingPage;
  // We don't need the name explicitly, as we'll use the font glyphs.

  const JuzInfo({required this.juzNumber, required this.startingPage});
}

// --- Bookmark Model ---
@immutable
class Bookmark extends Equatable {
  final int id; // Primary key (auto-increment)
  final int surahNumber; // Universal - Surah number (1-114)
  final int ayahNumber; // Universal - Ayah number within surah
  final int?
  cachedPageNumber; // Optional: current layout's page (for performance, invalidated on layout change)
  final DateTime createdAt; // When bookmark was created
  final String? note; // Optional user note (future enhancement)
  final String? ayahText; // Optional: text of the ayah

  const Bookmark({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    this.cachedPageNumber,
    required this.createdAt,
    this.note,
    this.ayahText,
  });

  Bookmark copyWith({
    int? id,
    int? surahNumber,
    int? ayahNumber,
    int? cachedPageNumber,
    DateTime? createdAt,
    String? note,
    String? ayahText,
  }) {
    return Bookmark(
      id: id ?? this.id,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      cachedPageNumber: cachedPageNumber ?? this.cachedPageNumber,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      ayahText: ayahText ?? this.ayahText,
    );
  }

  // Get formatted verse reference (e.g., "2:255")
  String get verseReference => '$surahNumber:$ayahNumber';

  @override
  List<Object?> get props => [
    id,
    surahNumber,
    ayahNumber,
    cachedPageNumber,
    createdAt,
    note,
    ayahText,
  ];
}

// --- Reading Session Model ---
@immutable
class ReadingSession extends Equatable {
  final int id; // Primary key (auto-increment)
  final DateTime sessionDate; // Date of reading session
  final int pageNumber; // Page that was read
  final DateTime timestamp; // Exact time page was viewed
  final int? durationSeconds; // Optional: How long page was viewed (future)

  const ReadingSession({
    required this.id,
    required this.sessionDate,
    required this.pageNumber,
    required this.timestamp,
    this.durationSeconds,
  });

  ReadingSession copyWith({
    int? id,
    DateTime? sessionDate,
    int? pageNumber,
    DateTime? timestamp,
    int? durationSeconds,
  }) {
    return ReadingSession(
      id: id ?? this.id,
      sessionDate: sessionDate ?? this.sessionDate,
      pageNumber: pageNumber ?? this.pageNumber,
      timestamp: timestamp ?? this.timestamp,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  @override
  List<Object?> get props => [
    id,
    sessionDate,
    pageNumber,
    timestamp,
    durationSeconds,
  ];
}

// --- Reading Statistics Model ---
@immutable
class ReadingStatistics {
  final int totalPagesRead; // Unique pages read (all-time)
  final int totalReadingDays; // Days with at least 1 page read
  final int currentStreak; // Current consecutive days streak
  final int longestStreak; // Longest streak ever achieved
  final int pagesToday; // Pages read today
  final int pagesThisWeek; // Pages read this week
  final int pagesThisMonth; // Pages read this month
  final int daysThisWeek; // Days read this week (1-7)
  final int daysThisMonth; // Days read this month
  final double averagePagesPerDay; // Average pages per reading day

  const ReadingStatistics({
    required this.totalPagesRead,
    required this.totalReadingDays,
    required this.currentStreak,
    required this.longestStreak,
    required this.pagesToday,
    required this.pagesThisWeek,
    required this.pagesThisMonth,
    required this.daysThisWeek,
    required this.daysThisMonth,
    required this.averagePagesPerDay,
  });

  // Deprecated: Use totalPages parameter instead
  // This getter uses hardcoded 604 which doesn't work for different layouts
  @Deprecated('Use overallProgressForTotalPages instead')
  double get overallProgress => totalPagesRead / 604; // 0.0 to 1.0

  // Deprecated: Use totalPages parameter instead
  @Deprecated('Use overallProgressPercentForTotalPages instead')
  int get overallProgressPercent => (overallProgress * 100).round();

  // Calculate progress for a specific total page count
  double overallProgressForTotalPages(int totalPages) =>
      totalPagesRead / totalPages;
  int overallProgressPercentForTotalPages(int totalPages) =>
      (overallProgressForTotalPages(totalPages) * 100).round();
}

// --- Audio Models ---
@immutable
class SurahAudio extends Equatable {
  final int surahNumber;
  final String audioUrl;
  final int duration; // Duration in seconds

  const SurahAudio({
    required this.surahNumber,
    required this.audioUrl,
    required this.duration,
  });

  @override
  List<Object?> get props => [surahNumber, audioUrl, duration];
}

@immutable
class AyahSegment extends Equatable {
  final int surahNumber;
  final int ayahNumber;
  final int durationSec;
  final int timestampFrom;
  final int timestampTo;
  final String segments;

  const AyahSegment({
    required this.surahNumber,
    required this.ayahNumber,
    required this.durationSec,
    required this.timestampFrom,
    required this.timestampTo,
    required this.segments,
  });

  @override
  List<Object?> get props => [
    surahNumber,
    ayahNumber,
    durationSec,
    timestampFrom,
    timestampTo,
    segments,
  ];
}

// --- Audio State Model ---
@immutable
class AudioState extends Equatable {
  final bool isPlaying;
  final int? currentSurahNumber;
  final int? currentAyahNumber;
  final int? endAyahNumber; // End ayah for range playback
  final Duration? position;
  final Duration? duration;

  const AudioState({
    required this.isPlaying,
    this.currentSurahNumber,
    this.currentAyahNumber,
    this.endAyahNumber,
    this.position,
    this.duration,
  });

  AudioState copyWith({
    bool? isPlaying,
    int? currentSurahNumber,
    int? currentAyahNumber,
    int? endAyahNumber,
    Duration? position,
    Duration? duration,
  }) {
    return AudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentSurahNumber: currentSurahNumber ?? this.currentSurahNumber,
      currentAyahNumber: currentAyahNumber ?? this.currentAyahNumber,
      endAyahNumber: endAyahNumber ?? this.endAyahNumber,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }

  @override
  List<Object?> get props => [
    isPlaying,
    currentSurahNumber,
    currentAyahNumber,
    endAyahNumber,
    position,
    duration,
  ];
}

// --- Layout Info Model ---
@immutable
class LayoutInfo extends Equatable {
  final String name;
  final int linesPerPage;

  const LayoutInfo({required this.name, required this.linesPerPage});

  @override
  List<Object?> get props => [name, linesPerPage];
}
