import 'package:flutter/material.dart';

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
const String fallbackFontFamily = 'QPCV2';

// --- RESPONSIVE SIZING ---
const double baseFontSize = 21.0;
const double referenceScreenWidth = 428.0;

// --- STYLING CONSTANTS ---

// Font Size Multipliers
const double surahNameScaleFactor = 1.5;
const double surahHeaderScaleFactorRelativeToName = 1.5;
const double basmallahScaleFactor = 0.95;

// Font Size Clamping (Min, Max)
const double minAyahFontSize = 16.0;
const double maxAyahFontSize = 30.0;
const double minSurahNameFontSize = 22.0;
const double maxSurahNameFontSize = 40.0;
const double minSurahHeaderFontSize = 24.0;
const double maxSurahHeaderFontSize = 44.0;
const double minBasmallahFontSize = 15.0;
const double maxBasmallahFontSize = 28.0;

// Line Height
const double baseLineHeight = 2.4;
// Line Height Clamping (Min, Max)
const double minLineHeight = 1.8;
const double maxLineHeight = 3.5;

// Padding Values
const double pageHorizontalPadding = 16.0;
const double pageBottomPadding = 45.0;
const double headerHorizontalPadding = 20.0;
const double headerJuzHizbSpacing = 12.0;
const double footerBottomPadding = 16.0;
const double footerRightPadding = 16.0;
const double footerLeftPadding = 24.0;

// Text Styles
const TextStyle headerFooterBaseStyle = TextStyle(
  fontSize: 14,
  color: Colors.black87,
);
const TextStyle footerPageNumStyle = TextStyle(
  fontSize: 16,
  color: Colors.black87,
);
