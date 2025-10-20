import 'package:flutter/services.dart';
import 'dart:collection'; // For HashMap

class FontService {
  // Use HashMap for potentially faster lookups
  final HashMap<int, String> _loadedFonts = HashMap<int, String>();

  Future<String> loadFontForPage(int pageNumber) async {
    // Check cache first
    final String? cachedFamily = _loadedFonts[pageNumber];
    if (cachedFamily != null) {
      return cachedFamily;
    }

    final String pageFontFamily = 'Page$pageNumber';
    final String fontAssetPath =
        'assets/fonts/QPC V2 Font.ttf/p$pageNumber.ttf';

    try {
      final FontLoader fontLoader = FontLoader(pageFontFamily);
      // Load font data asynchronously
      final Future<ByteData> fontData = rootBundle.load(fontAssetPath);
      fontLoader.addFont(fontData);
      // Wait for loading to complete
      await fontLoader.load();

      _loadedFonts[pageNumber] = pageFontFamily;
      return pageFontFamily;
    } catch (e) {
      // Provide more specific error context
      throw Exception(
        "FontService: Error loading font for page $pageNumber from '$fontAssetPath'. Ensure the file exists in assets and is declared in pubspec.yaml. Original error: $e",
      );
    }
  }
}
