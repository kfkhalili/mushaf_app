// --- DATABASE FILENAMES ---
const String layoutDbFileName = 'uthmani-15-lines.db';
const String scriptDbFileName = 'qpc-v2.db';
const String metadataDbFileName = 'quran-metadata-surah-name.sqlite';
const String juzDbFileName = 'quran-metadata-juz.sqlite';
const String hizbDbFileName = 'quran-metadata-hizb.sqlite';

// --- TEXT CONSTANTS ---
const String basmallah = '\uFDFD'; // ﷽

// --- FONT CONSTANTS ---
const String surahNameFontFamily = 'SurahNames';
const String quranCommonFontFamily = 'QuranCommon';
const String fallbackFontFamily = 'QPCV2'; // Used for Quran text fallback

// --- RESPONSIVE SIZING ---
const double baseFontSize = 20.0;
const double referenceScreenWidth = 428.0;
const double referenceScreenHeight = 926.0;
const double maxLineContentWidth = 600.0;

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
const double baseLineHeight = 2.2; // For Ayah text
// const double tightLineHeight = 1.5; // Used directly in line_widget.dart

// Padding Values
const double pageHorizontalPadding = 16.0;
const double pageBottomPadding = 45.0;
const double headerHorizontalPadding = 20.0;
const double headerJuzHizbSpacing = 12.0; // Not currently used but kept
const double footerBottomPadding = 16.0;
const double footerRightPadding = 16.0;
const double footerLeftPadding = 24.0;

// --- MEMORIZATION ---
// WHY: Number of words to show initially when memorization mode starts.
const int initialWordCount = 15;
