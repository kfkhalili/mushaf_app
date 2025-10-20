// --- DATABASE FILENAMES ---
import 'package:flutter/material.dart';

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
const String fallbackFontFamily = 'QPCV2'; // Name for the default font

// --- RESPONSIVE SIZING ---
const double baseFontSize = 21.0;
const double referenceScreenWidth = 428.0;

// --- STYLING CONSTANTS ---

// Font Size Multipliers (relative to baseFontSize * scaleFactor)
const double surahNameScaleFactor = 1.5;
const double surahHeaderScaleFactorRelativeToName =
    1.5; // Was 1.8, adjusted to your value
const double basmallahScaleFactor = 1.5;

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
const double defaultLineHeight = 1.8;

// Padding Values
const double pageHorizontalPadding = 16.0;
const double pageBottomPadding = 45.0; // Space for page number footer
const double headerHorizontalPadding = 16.0;
const double headerJuzHizbSpacing = 12.0;
const double footerBottomPadding = 16.0;
const double footerRightPadding = 16.0; // Standard right padding
const double footerLeftPadding =
    24.0; // Extra padding on the left (visual right in RTL)

// Text Styles (optional but good for consistency)
const TextStyle headerFooterBaseStyle = TextStyle(
  fontSize: 14,
  color: Colors.black87,
);
const TextStyle footerPageNumStyle = TextStyle(
  fontSize: 16,
  color: Colors.black87,
);
