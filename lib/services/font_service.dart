import 'package:flutter/services.dart';
import 'dart:collection'; // For HashMap
import '../constants.dart';

class FontService {
  // Use HashMap for potentially faster lookups
  final HashMap<String, String> _loadedFonts = HashMap<String, String>();
  final HashMap<String, String> _loadedCommonFonts = HashMap<String, String>();

  Future<String> loadFontForPage(
    int pageNumber, {
    MushafLayout layout = MushafLayout.uthmani15Lines,
  }) async {
    // Check cache first
    final String cacheKey = '${layout.name}_$pageNumber';
    final String? cachedFamily = _loadedFonts[cacheKey];
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
    }

    try {
      final FontLoader fontLoader = FontLoader(pageFontFamily);
      // Load font data asynchronously
      final Future<ByteData> fontData = rootBundle.load(fontAssetPath);
      fontLoader.addFont(fontData);
      // Wait for loading to complete
      await fontLoader.load();

      _loadedFonts[cacheKey] = pageFontFamily;
      return pageFontFamily;
    } catch (e) {
      // Provide more specific error context
      throw Exception(
        "FontService: Error loading font for page $pageNumber with layout ${layout.name} from '$fontAssetPath'. Ensure the file exists in assets and is declared in pubspec.yaml. Original error: $e",
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
    }

    try {
      final FontLoader fontLoader = FontLoader(fontFamily);
      final Future<ByteData> fontData = rootBundle.load(fontAssetPath);
      fontLoader.addFont(fontData);
      await fontLoader.load();

      _loadedCommonFonts[layout.name] = fontFamily;
      return fontFamily;
    } catch (e) {
      throw Exception(
        "FontService: Error loading common font for layout ${layout.name} from '$fontAssetPath'. Ensure the file exists in assets and is declared in pubspec.yaml. Original error: $e",
      );
    }
  }
}
