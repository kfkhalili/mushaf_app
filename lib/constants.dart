// --- DATABASE FILENAMES ---
const String layoutDbFileName = 'uthmani-15-lines.db';
const String indopakLayoutDbFileName = 'indopak-13-lines-layout-qudratullah.db';
const String scriptDbFileName = 'qpc-v2.db';
const String indopakScriptDbFileName = 'indopak-nastaleeq.db';
const String metadataDbFileName = 'quran-metadata-surah-name.sqlite';
const String juzDbFileName = 'quran-metadata-juz.sqlite';
const String hizbDbFileName = 'quran-metadata-hizb.sqlite';

// --- MUSHAF LAYOUT OPTIONS ---
enum MushafLayout { uthmani15Lines, indopak13Lines }

extension MushafLayoutExtension on MushafLayout {
  String get layoutDatabaseFileName {
    switch (this) {
      case MushafLayout.uthmani15Lines:
        return layoutDbFileName;
      case MushafLayout.indopak13Lines:
        return indopakLayoutDbFileName;
    }
  }

  String get scriptDatabaseFileName {
    switch (this) {
      case MushafLayout.uthmani15Lines:
        return scriptDbFileName;
      case MushafLayout.indopak13Lines:
        return indopakScriptDbFileName;
    }
  }

  String get displayName {
    switch (this) {
      case MushafLayout.uthmani15Lines:
        return 'عثماني (١٥ سطر)';
      case MushafLayout.indopak13Lines:
        return 'إندوباك (١٣ سطر)';
    }
  }

  String get fontFamily {
    switch (this) {
      case MushafLayout.uthmani15Lines:
        return quranCommonFontFamily;
      case MushafLayout.indopak13Lines:
        return indopakFontFamily;
    }
  }
}

// --- TEXT CONSTANTS ---
const String basmallah = '\uFDFD'; // ﷽

// --- FONT CONSTANTS ---
const String surahNameFontFamily = 'SurahNames';
const String quranCommonFontFamily = 'QuranCommon';
const String indopakFontFamily = 'IndopakFont';

// --- RESPONSIVE SIZING ---
const double baseFontSize = 20.0;
const double referenceScreenWidth = 428.0;
const double referenceScreenHeight = 926.0;
const double maxLineContentWidth = 600.0;

// --- FONT SIZE SETTINGS ---
const double minFontSize = 12.0;
const double maxFontSize = 24.0;
const double defaultFontSize = 20.0;
const double fontSizeStep = 2.0;

// Font size options for dropdown
const List<double> fontSizeOptions = [12.0, 14.0, 16.0, 18.0, 20.0, 22.0, 24.0];

// Font size labels in Arabic
final Map<double, String> fontSizeLabels = {
  12.0: 'صغير جداً',
  14.0: 'صغير',
  16.0: 'صغير متوسط',
  18.0: 'متوسط صغير',
  20.0: 'متوسط',
  22.0: 'متوسط كبير',
  24.0: 'كبير جداً',
};

// Preview text (first verse of Al-Fatiha)
const String fontPreviewText = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';

// --- STYLING CONSTANTS ---

// Font Size Multipliers
const double surahNameScaleFactor = 1.4; // For the frame glyph
const double headerScaleFactor = 2.0; // For text inside surah frame
const double basmallahScaleFactor = 0.95;

// Font Size Clamping (Min, Max)
const double minAyahFontSize = 16.0;
const double maxAyahFontSize = 30.0;
const double minSurahNameFontSize = 22.0;
const maxSurahNameFontSize = 40.0;
const double minSurahHeaderFontSize = 24.0;
const maxSurahHeaderFontSize = 44.0;
const double minBasmallahFontSize = 15.0;
const maxBasmallahFontSize = 28.0;

// Line Height
const double baseLineHeight = 2.1; // For Ayah text
// const double tightLineHeight = 1.5; // Used directly in line_widget.dart

// Padding Values
const double pageHorizontalPadding = 16.0;
const double pageBottomPadding = 45.0;
const double headerHorizontalPadding = 20.0;
const double headerJuzHizbSpacing = 12.0; // Not currently used but kept
const double footerBottomPadding = 16.0;
const double footerRightPadding = 16.0;
const double footerLeftPadding = 24.0;

// --- NAVIGATION ---
const double kBottomNavBarHeight = 64.0;
const double kBottomNavLabelFontSize = 22.0;
const double kBottomNavIconSize = 34.0;
const double kCountdownCircleDiameter = 56.0;

// --- APP HEADER ---
const double kAppHeaderHeight = 56.0;
const double kAppHeaderTitleFontSize = 20.0;
const double kAppHeaderIconSize = 24.0;

// --- MEMORIZATION ---
// WHY: Number of words to show initially when memorization mode starts.
const int initialWordCount = 15;

// --- APP CONSTANTS (Newly Added) ---

// WHY: Centralize the total page count for use in PageView builders and ListViews.
const int totalPages = 604;

/// WHY: Centralizes all database table and column names as constants
/// to prevent typos and make schema changes easier to manage.
class DbConstants {
  // --- Table Names ---
  static const String pagesTable = 'pages';
  static const String wordsTable = 'words';
  static const String chaptersTable = 'chapters';
  static const String juzTable = 'juz';
  static const String hizbsTable = 'hizbs';

  // --- Common Columns ---
  static const String idCol = 'id';
  static const String surahNumberCol = 'surah_number';
  static const String ayahNumberCol = 'ayah';
  static const String surahCol = 'surah';
  static const String pageNumberCol = 'page_number';
  static const String lineNumberCol = 'line_number';
  static const String lineTypeCol = 'line_type';

  // --- Pages Table ---
  static const String firstWordIdCol = 'first_word_id';
  static const String lastWordIdCol = 'last_word_id';
  static const String isCenteredCol = 'is_centered';

  // --- Words Table ---
  static const String textCol = 'text';

  // --- Chapters Table ---
  static const String nameArabicCol = 'name_arabic';
  static const String revelationPlaceCol = 'revelation_place';

  // --- Juz & Hizb Tables ---
  static const String juzNumberCol = 'juz_number';
  static const String hizbNumberCol = 'hizb_number';
  static const String firstVerseKeyCol = 'first_verse_key';
  static const String lastVerseKeyCol = 'last_verse_key';

  // --- Query Helpers ---
  static const String startPageAlias = 'start_page';
}
