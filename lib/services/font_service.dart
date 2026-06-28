import 'dart:collection'; // For HashMap
import 'package:flutter/services.dart';
import '../constants.dart';
import '../exceptions/database_exceptions.dart';
import '../utils/lru_cache.dart';

class FontService {
  // WHY: Use LRU cache to limit memory usage (max 50 fonts cached).
  // Evicts least recently used fonts when cache is full.
  final LRUCache<String, String> _loadedFonts = LRUCache<String, String>(
    maxFontCacheSize,
  );

  // WHY: Common fonts are few (2 layouts), so unlimited cache is safe.
  final HashMap<String, String> _loadedCommonFonts = HashMap<String, String>();

  Future<String> loadFontForPage(
    int pageNumber, {
    MushafLayout layout = MushafLayout.uthmani15Lines,
  }) async {
    // Check cache first (LRU get moves item to most recently used)
    final String cacheKey = '${layout.name}_$pageNumber';
    final String? cachedFamily = _loadedFonts.get(cacheKey);
    if (cachedFamily != null) {
      return cachedFamily;
    }

    String pageFontFamily;
    String fontAssetPath;

    switch (layout) {
      case MushafLayout.uthmani15Lines:
        pageFontFamily = 'Page$pageNumber';
        fontAssetPath =
            'assets/fonts/qpc-v2-page-by-page-fonts/p$pageNumber.ttf';
        break;
      case MushafLayout.indopak13Lines:
        // For Indopak, we use the common font for all pages
        pageFontFamily = indopakFontFamily;
        fontAssetPath = 'assets/fonts/indopak-font.ttf';
        break;
      case MushafLayout.digitalKhatt15Lines:
        // For DigitalKhatt, we use the common font for all pages
        pageFontFamily = digitalKhattFontFamily;
        fontAssetPath = 'assets/fonts/DigitalKhattV2.otf';
        break;
      case MushafLayout.indopak9Lines:
        // Reuses the Digital Khatt font (single font for all pages)
        pageFontFamily = digitalKhattFontFamily;
        fontAssetPath = 'assets/fonts/DigitalKhattV2.otf';
        break;
    }

    try {
      final FontLoader fontLoader = FontLoader(pageFontFamily);
      // Load font data asynchronously
      final Future<ByteData> fontData = rootBundle.load(fontAssetPath);
      fontLoader.addFont(fontData);
      // Wait for loading to complete
      await fontLoader.load();

      // WHY: LRU put may evict least recently used font if cache is full.
      _loadedFonts.put(cacheKey, pageFontFamily);
      return pageFontFamily;
    } catch (e, stackTrace) {
      // Provide more specific error context
      throw FontException(
        "Error loading font for page $pageNumber with layout ${layout.name} from '$fontAssetPath'. Ensure the file exists in assets and is declared in pubspec.yaml",
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<String> loadCommonFont({
    MushafLayout layout = MushafLayout.uthmani15Lines,
  }) async {
    // Check cache first
    final String? cachedFamily = _loadedCommonFonts[layout.name];
    if (cachedFamily != null) {
      return cachedFamily;
    }

    String fontFamily;
    String fontAssetPath;

    switch (layout) {
      case MushafLayout.uthmani15Lines:
        fontFamily = quranCommonFontFamily;
        fontAssetPath = 'assets/fonts/quran-common.ttf';
        break;
      case MushafLayout.indopak13Lines:
        fontFamily = indopakFontFamily;
        fontAssetPath = 'assets/fonts/indopak-font.ttf';
        break;
      case MushafLayout.digitalKhatt15Lines:
        fontFamily = digitalKhattFontFamily;
        fontAssetPath = 'assets/fonts/DigitalKhattV2.otf';
        break;
      case MushafLayout.indopak9Lines:
        fontFamily = digitalKhattFontFamily;
        fontAssetPath = 'assets/fonts/DigitalKhattV2.otf';
        break;
    }

    try {
      final FontLoader fontLoader = FontLoader(fontFamily);
      final Future<ByteData> fontData = rootBundle.load(fontAssetPath);
      fontLoader.addFont(fontData);
      await fontLoader.load();

      _loadedCommonFonts[layout.name] = fontFamily;
      return fontFamily;
    } catch (e, stackTrace) {
      throw FontException(
        "Error loading common font for layout ${layout.name} from '$fontAssetPath'. Ensure the file exists in assets and is declared in pubspec.yaml",
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
