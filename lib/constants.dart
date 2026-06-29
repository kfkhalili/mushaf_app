import 'package:flutter/material.dart';

// --- DATABASE FILENAMES ---
const String layoutDbFileName = 'uthmani-15-lines.db';
const String indopakLayoutDbFileName = 'indopak-13-lines-layout-qudratullah.db';
const String digitalKhattLayoutDbFileName = 'digital-khatt-15-lines.db';
const String indopak9LinesLayoutDbFileName = 'indopak-9-lines-gaba.db';
const String scriptDbFileName = 'qpc-v2.db';
const String indopakScriptDbFileName = 'indopak-nastaleeq.db';
const String digitalKhattScriptDbFileName = 'digital-khatt-v2.db';
const String metadataDbFileName = 'quran-metadata-surah-name.sqlite';
const String juzDbFileName = 'quran-metadata-juz.sqlite';
const String hizbDbFileName = 'quran-metadata-hizb.sqlite';
const String imlaeiAyahDbFileName = 'imlaei-script-ayah-by-ayah.db';
const String topicsDbFileName = 'topics.db';
const String audioDbFileName = 'surah-recitation-abdullah-ali-jabir.db';
const String tafsirDbFileName = 'ar-tafsir-muyassar.db';
const String imlaeiSimpleDbFileName = 'imlaei-simple.db';

/// Every read-only SQLite database bundled under `assets/db/`.
///
/// WHY: Single source of truth for the whitelist [BundledDatabaseStore] checks
/// before copying an asset, so a stray name can never load an arbitrary file.
const List<String> bundledDatabaseFileNames = <String>[
  layoutDbFileName,
  indopakLayoutDbFileName,
  digitalKhattLayoutDbFileName,
  indopak9LinesLayoutDbFileName,
  scriptDbFileName,
  indopakScriptDbFileName,
  digitalKhattScriptDbFileName,
  metadataDbFileName,
  juzDbFileName,
  hizbDbFileName,
  imlaeiAyahDbFileName,
  imlaeiSimpleDbFileName,
  topicsDbFileName,
  audioDbFileName,
  tafsirDbFileName,
];

// --- MUSHAF LAYOUT OPTIONS ---
enum MushafLayout {
  uthmani15Lines,
  indopak13Lines,
  digitalKhatt15Lines,
  indopak9Lines,
}

extension MushafLayoutExtension on MushafLayout {
  String get layoutDatabaseFileName {
    switch (this) {
      case MushafLayout.uthmani15Lines:
        return layoutDbFileName;
      case MushafLayout.indopak13Lines:
        return indopakLayoutDbFileName;
      case MushafLayout.digitalKhatt15Lines:
        return digitalKhattLayoutDbFileName;
      case MushafLayout.indopak9Lines:
        return indopak9LinesLayoutDbFileName;
    }
  }

  // WHY: Derived from the font registry, keyed by the layout's font_name, so the
  // word-text source always matches the font the layout was authored for (a
  // mismatch is what broke the 9-line layout's line-fill). See [mushafFontSpec].
  String get scriptDatabaseFileName => mushafFontSpec(this).scriptDbFileName;

  String get displayName {
    switch (this) {
      case MushafLayout.uthmani15Lines:
        return 'عثماني (١٥ سطر)';
      case MushafLayout.indopak13Lines:
        return 'إندوباك (١٣ سطر)';
      case MushafLayout.digitalKhatt15Lines:
        return 'خط رقمي (١٥ سطر)';
      case MushafLayout.indopak9Lines:
        return 'إندوباك (٩ سطر)';
    }
  }
}

// --- TEXT CONSTANTS ---
const String basmallah = '\uFDFD'; // ﷽

// --- FONT CONSTANTS ---
const String surahNameFontFamily = 'SurahNames';
const String quranCommonFontFamily = 'QuranCommon';
const String indopakFontFamily = 'IndopakFont';
const String digitalKhattFontFamily = 'DigitalKhattV2';

// --- FONT REGISTRY (keyed by the layout DB's info.font_name) ---
// WHY: One source of truth for "given a layout's authored font_name, how do we
// render it" — the font family + asset + the matching script (word-text) DB.
// Selecting font and script together from the same key makes the divergence
// that broke the 9-line layout (font_name said "indopak", code used DigitalKhatt)
// structurally impossible. A test asserts [mushafLayoutFontName] matches each
// DB's actual info.font_name, so a new/relabelled layout can't silently break.
@immutable
class MushafFontSpec {
  /// Word-text source DB for this font.
  final String scriptDbFileName;

  /// Page-specific layouts (QPC "me_quran") use a per-page font: [family] is a
  /// prefix and [assetPath] contains a `{page}` placeholder. Single-font layouts
  /// use [family]/[assetPath] verbatim for every page.
  final bool pageSpecific;
  final String family;
  final String assetPath;

  const MushafFontSpec({
    required this.scriptDbFileName,
    required this.family,
    required this.assetPath,
    this.pageSpecific = false,
  });

  String familyForPage(int page) => pageSpecific ? '$family$page' : family;
  String assetForPage(int page) =>
      pageSpecific ? assetPath.replaceAll('{page}', '$page') : assetPath;
}

const MushafFontSpec _qpcSpec = MushafFontSpec(
  scriptDbFileName: scriptDbFileName,
  pageSpecific: true,
  family: 'Page',
  assetPath: 'assets/fonts/qpc-v2-page-by-page-fonts/p{page}.ttf',
);
const MushafFontSpec _digitalKhattSpec = MushafFontSpec(
  scriptDbFileName: digitalKhattScriptDbFileName,
  family: digitalKhattFontFamily,
  assetPath: 'assets/fonts/DigitalKhattV2.otf',
);
const MushafFontSpec _indopakSpec = MushafFontSpec(
  scriptDbFileName: indopakScriptDbFileName,
  family: indopakFontFamily,
  assetPath: 'assets/fonts/indopak-font.ttf',
);

/// info.font_name -> how to render it.
const Map<String, MushafFontSpec> mushafFontRegistry = {
  'me_quran': _qpcSpec,
  'digitalkhatt': _digitalKhattSpec,
  'indopak': _indopakSpec,
  'mushaf-indopak-nastaleeq-hanafi-compressed': _indopakSpec,
};

/// Each layout's authored font_name (mirrors the layout DB's info.font_name;
/// verified against the actual DBs by a test).
const Map<MushafLayout, String> mushafLayoutFontName = {
  MushafLayout.uthmani15Lines: 'me_quran',
  MushafLayout.indopak13Lines: 'mushaf-indopak-nastaleeq-hanafi-compressed',
  MushafLayout.digitalKhatt15Lines: 'digitalkhatt',
  MushafLayout.indopak9Lines: 'indopak',
};

/// Resolves a layout to its [MushafFontSpec] via its font_name.
MushafFontSpec mushafFontSpec(MushafLayout layout) =>
    mushafFontRegistry[mushafLayoutFontName[layout]]!;

// --- RESPONSIVE SIZING ---
const double baseFontSize = 20.0;
const double referenceScreenWidth = 428.0;
const double referenceScreenHeight = 926.0;

// Per-layout base reading size for the single-ayah detail view.
// WHY: The page body is sized by measurement (see PageFit) and no longer uses
// these. They remain the *reading base* for AyahDetailsScreen, which shows one
// ayah enlarged for study (scaled by [ayahDetailsFontScale]).
const Map<MushafLayout, double> layoutMaxFontSizes = {
  MushafLayout.uthmani15Lines: 20.0,
  MushafLayout.indopak13Lines: 24.0,
  MushafLayout.digitalKhatt15Lines: 20.0,
  MushafLayout.indopak9Lines: 28.0, // Fewer lines/page ⇒ larger glyphs
};

// --- AYAH DETAILS (single-ayah reading view) ---
// WHY: The detail view shows one ayah larger than the page body for study.
const double ayahDetailsFontScale =
    1.5; // multiplies the per-layout reading base
const double ayahDetailsWordSpacing = 8.0; // horizontal gap between words
const double ayahDetailsRunSpacing = 4.0; // vertical gap between wrapped lines

// Per-layout line-box height (leading) as a multiple of the body font size.
// WHY: This is an intentional *typographic design* value — the vertical rhythm
// (how much breathing room each line gets), chosen per script — NOT a quantity
// derivable from font ascent/descent (those give ~1.0–1.3; the generous mushaf
// spacing is deliberate). PageFit divides the page height by the sum of these so
// the lines fill the page at this rhythm. Tune per layout for the script's feel.
const Map<MushafLayout, double> layoutLineHeights = {
  MushafLayout.uthmani15Lines: 2.1,
  MushafLayout.indopak13Lines: 2.05, // Nastaliq sits tighter
  MushafLayout.digitalKhatt15Lines: 2.1,
  MushafLayout.indopak9Lines: 2.2, // Fewer lines ⇒ more generous rhythm
};

// --- STYLING CONSTANTS ---

// Font Size Multipliers
const double surahNameScaleFactor = 1.4; // For the frame glyph
const double headerScaleFactor = 2.0; // For text inside surah frame
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

// Line Height (deprecated - use layoutLineHeights instead)
const double baseLineHeight = 2.1; // For Ayah text

// Line-box height (leading) for ornament rows (surah-name frame + header
// overlay, basmallah) — a typographic design value, tighter than body text.
// Shared by the renderer (MushafLine) and the page-fit measurement (which needs
// each row's true height to size the page without overflow). See [PageFit].
const double ornamentLineHeight = 1.5;

// WHY: One-logical-pixel vertical rounding guard, shaved off the available
// height in PageFit so an exact-fit page can't overflow by a sub-pixel fraction
// from TextPainter rounding. An absolute pixel (not a percentage): rounding
// error is sub-pixel regardless of font size, so a fixed epsilon is the
// principled guard rather than a blanket shrink.
const double pageFitVerticalEpsilon = 1.0;

// Padding Values
const double pageHorizontalPadding = 16.0;
const double pageBottomPadding = 45.0;
const double headerHorizontalPadding = 20.0;
const double footerBottomPadding = 16.0;
const double footerRightPadding = 16.0;
const double footerLeftPadding = 24.0;

// --- NAVIGATION ---
const double kBottomNavBarHeight = 64.0;
const double kBottomNavLabelFontSize = 22.0;
const double kBottomNavIconSize = 34.0;

// --- APP HEADER ---
const double kAppHeaderHeight = 56.0;
const double kAppHeaderTitleFontSize = 20.0;
const double kAppHeaderIconSize = 24.0;

// --- HEADER GLYPH BASE SIZES ---
// WHY: Base font sizes for the juz/hizb and surah-name glyphs in the app header
// (scaled by the responsive factor) and the bookmark card. Single source of
// truth for these two; the list-row glyphs use their own larger sizes by design.
const double kJuzGlyphBaseSize = 24.0;
const double kSurahGlyphBaseSize = 28.0;

// --- DESIGN TOKENS: OPACITY ---
// WHY: Semantic opacity scale replacing scattered `withValues(alpha: …)`
// literals, so "hairline border" / "muted text" mean one value everywhere.
class AppOpacity {
  static const double hairline = 0.1; // borders, faint dividers
  static const double faint = 0.3; // empty-state icons, disabled glyphs
  static const double muted = 0.4; // tertiary text/hints
  static const double soft = 0.5;
  static const double secondary = 0.6; // secondary text
  static const double strong = 0.7;
  static const double prominent = 0.8;

  const AppOpacity._();
}

// --- DESIGN TOKENS: ANIMATION DURATIONS ---
// WHY: Named UI animation timings replacing magic Duration literals. Functional
// timings (audio polling/seek, splash delay, snackbars) stay local to their use.
class AppDurations {
  static const Duration micro = Duration(milliseconds: 120);
  static const Duration short = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300); // transitions
  static const Duration ayahNavDelay = Duration(milliseconds: 400);

  const AppDurations._();
}

// --- MEMORIZATION ---
// WHY: Number of words to show initially when memorization mode starts.
const int initialWordCount = 15;

// --- FONT CACHE LIMITS ---
// WHY: Maximum number of fonts to keep in memory cache to prevent memory pressure.
// With 604 page-specific fonts, we limit cache to prevent loading all fonts.
const int maxFontCacheSize = 50;

// --- SEARCH CACHE LIMITS ---
// WHY: Maximum cache sizes for SearchService to prevent unbounded memory growth.
class SearchCacheLimits {
  // WHY: Maximum number of search queries to cache (recent searches).
  static const int maxSearchCacheSize = 50;

  // WHY: Maximum number of Surah name lookups to cache (covers all 114 Surahs).
  static const int maxSurahNameCacheSize = 114;

  // WHY: Maximum number of verse-to-page lookups to cache (recent lookups).
  static const int maxVerseToPageCacheSize = 200;

  // WHY: Private constructor to prevent instantiation.
  const SearchCacheLimits._();
}

// --- QUERY LIMITS ---
// WHY: Centralizes query limit values to avoid magic numbers throughout codebase.
class QueryLimits {
  // WHY: Common limit for single result queries (used 20+ times).
  static const int singleResult = 1;

  // WHY: Maximum number of days for streak calculation safety limit.
  static const int maxStreakDays = 365;

  // WHY: Private constructor to prevent instantiation.
  const QueryLimits._();
}

// --- SEARCH LIMITS ---
// WHY: Centralizes search-related query limits.
class SearchLimits {
  // WHY: Maximum number of search results to return per query.
  static const int maxSearchResults = 100;

  // WHY: Private constructor to prevent instantiation.
  const SearchLimits._();
}

// --- PREVIEW LIMITS ---
// WHY: Centralizes preview-related query limits.
class PreviewLimits {
  // WHY: Maximum number of lines to fetch for page preview.
  // Fetches a few lines in case the first line is empty or basmallah.
  static const int maxPreviewLines = 5;

  // WHY: Private constructor to prevent instantiation.
  const PreviewLimits._();
}

// --- SEARCH HISTORY CONSTANTS ---
// WHY: Centralizes search history-related constants.
class SearchHistoryConstants {
  // WHY: SharedPreferences key for storing search history.
  static const String preferencesKey = 'search_history';

  // WHY: Maximum number of history items to store and display.
  static const int maxHistoryItems = 20;

  // WHY: Private constructor to prevent instantiation.
  const SearchHistoryConstants._();
}

// --- PRIMARY COLOR CONSTANTS ---
// WHY: Centralizes primary color presets and default values.
class PrimaryColorConstants {
  // WHY: Default primary color for light/dark themes.
  static const int defaultColor = 0xFF009688; // Colors.teal[500]

  // WHY: Default primary color for sepia theme.
  static const int defaultSepiaColor = 0xFF795548; // Colors.brown[500]

  // WHY: SharedPreferences key for storing primary color.
  static const String preferencesKey = 'primary_color';

  // WHY: Predefined color presets for user selection.
  static const List<ColorPreset> presets = [
    ColorPreset(name: 'شرشير', color: 0xFF009688), // Teal
    ColorPreset(name: 'أزرق', color: 0xFF2196F3), // Blue
    ColorPreset(name: 'بنفسجي', color: 0xFF9C27B0), // Purple
    ColorPreset(name: 'أخضر', color: 0xFF4CAF50), // Green
    ColorPreset(name: 'برتقالي', color: 0xFFFF9800), // Orange
    ColorPreset(name: 'أحمر', color: 0xFFF44336), // Red
    ColorPreset(name: 'وردي', color: 0xFFE91E63), // Pink
    ColorPreset(name: 'أزرق داكن', color: 0xFF1976D2), // Dark Blue
    ColorPreset(name: 'أخضر داكن', color: 0xFF388E3C), // Dark Green
    ColorPreset(name: 'نيلي', color: 0xFF3F51B5), // Indigo
  ];

  // WHY: Private constructor to prevent instantiation.
  const PrimaryColorConstants._();
}

// WHY: Represents a color preset with name and color value.
class ColorPreset {
  final String name;
  final int color;

  const ColorPreset({required this.name, required this.color});

  Color get colorValue => Color(color);
}

// --- DATE CALCULATIONS ---
// WHY: Centralizes date calculation constants to avoid magic numbers.
class DateCalculations {
  // WHY: Standard week duration for "this week" calculations.
  static const Duration weekDuration = Duration(days: 7);

  // WHY: Standard month duration (approximate).
  static const Duration monthDuration = Duration(days: 30);

  // WHY: Private constructor to prevent instantiation.
  const DateCalculations._();
}

// --- APP CONSTANTS (Newly Added) ---

// WHY: Centralize the total page count for use in PageView builders and ListViews.
// Layout-specific page counts come from each layout's `info` table via
// DatabaseService.getTotalPages(); this is only a safe fallback (Uthmani size).
const int totalPages = 604;

// WHY: Upper bound for page-number validation across ALL layouts. Layouts vary
// in length (Uthmani 604, Indopak 849, Indopak 9-line 1890), so a per-layout
// total is passed to validatePageNumber when known; this is the absolute ceiling.
const int maxSupportedPages = 2000;

/// WHY: Centralizes all database table and column names as constants
/// to prevent typos and make schema changes easier to manage.
class DbConstants {
  // --- Table Names ---
  static const String pagesTable = 'pages';
  static const String wordsTable = 'words';
  static const String chaptersTable = 'chapters';
  static const String juzTable = 'juz';
  static const String hizbsTable = 'hizbs';
  static const String versesTable = 'verses';
  static const String infoTable = 'info';

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
  static const String versesCountCol = 'verses_count';

  // --- Juz & Hizb Tables ---
  static const String juzNumberCol = 'juz_number';
  static const String hizbNumberCol = 'hizb_number';
  static const String firstVerseKeyCol = 'first_verse_key';
  static const String lastVerseKeyCol = 'last_verse_key';
  static const String verseKeyCol = 'verse_key';

  // --- Audio Tables ---
  static const String surahListTable = 'surah_list';
  static const String segmentsTable = 'segments';
  // surahNumberCol is defined in Common Columns above
  // Note: Audio tables use ayah_number (with underscore) instead of ayah
  static const String audioAyahNumberCol = 'ayah_number';
  static const String audioUrlCol = 'audio_url';
  static const String durationCol = 'duration';
  static const String durationSecCol = 'duration_sec';
  static const String timestampFromCol = 'timestamp_from';
  static const String timestampToCol = 'timestamp_to';
  static const String segmentsCol = 'segments';

  // --- Topics/Ontology Tables ---
  static const String topicsTable = 'topics';
  static const String topicVerseMapTable = 'TopicVerseMap';
  static const String relatedTopicsMapTable = 'RelatedTopicsMap';
  static const String topicIdCol = 'topic_id';
  static const String nameCol = 'name';
  static const String arabicNameCol = 'arabic_name';
  static const String parentIdCol = 'parent_id';
  static const String thematicParentIdCol = 'thematic_parent_id';
  static const String ontologyParentIdCol = 'ontology_parent_id';
  static const String descriptionCol = 'description';
  static const String wikiLinkCol = 'wiki_link';
  static const String thematicCol = 'thematic';
  static const String ontologyCol = 'ontology';
  static const String mapIdCol = 'map_id';
  static const String sourceTopicIdCol = 'source_topic_id';
  static const String relatedTopicIdCol = 'related_topic_id';

  // --- Bookmarks Table ---
  static const String bookmarksTable = 'bookmarks';
  // surahNumberCol and ayahNumberCol are already defined in Common Columns
  static const String cachedPageNumberCol = 'cached_page_number';
  static const String createdAtCol = 'created_at';
  static const String noteCol = 'note';

  // --- Reading Progress Table ---
  static const String readingSessionsTable = 'reading_sessions';
  // pageNumberCol is already defined in Common Columns
  static const String sessionDateCol = 'session_date';
  static const String timestampCol = 'timestamp';
  static const String durationSecondsCol = 'duration_seconds';

  // --- App Data Database Tables (Unified Storage) ---
  static const String memorizationSessionsTable = 'memorization_sessions';
  static const String userPreferencesTable = 'user_preferences';

  // --- Memorization Sessions Columns ---
  static const String firstAyahIndexCol = 'first_ayah_index';
  static const String lastAyahIndexShownCol = 'last_ayah_index_shown';
  static const String passCountCol = 'pass_count';
  static const String windowDataCol = 'window_data';
  static const String lastUpdatedAtCol = 'last_updated_at';
  // createdAtCol is already defined in Bookmarks Table section above

  // --- User Preferences Columns ---
  static const String keyCol = 'key';
  static const String valueCol = 'value';
  static const String updatedAtCol = 'updated_at';

  // --- Info Table ---
  static const String numberOfPagesCol = 'number_of_pages';
  static const String layoutNameCol = 'name';
  static const String linesPerPageCol = 'lines_per_page';
  static const String fontNameCol = 'font_name';

  // --- Query Helpers ---
  static const String startPageAlias = 'start_page';
}

// Feature flags
const bool enableMemorizationBeta = true;

// --- MIGRATION CONSTANTS ---
// WHY: Centralizes legacy database filenames for migration service.
// Prevents magic strings and typos when referencing old database files.
class MigrationConstants {
  // WHY: Legacy database filenames from before unified app_data.db migration
  static const String legacyBookmarksDb = 'bookmarks.db';
  static const String legacyReadingProgressDb = 'reading_progress.db';

  // WHY: Private constructor to prevent instantiation.
  const MigrationConstants._();
}
