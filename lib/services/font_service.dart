import 'package:flutter/services.dart';
import 'dart:collection'; // For LinkedHashMap
import '../constants.dart';

/// WHY: LRU cache implementation using LinkedHashMap.
/// LinkedHashMap maintains insertion order, allowing O(1) operations.
class _LRUCache<K, V> {
  final LinkedHashMap<K, V> _cache = LinkedHashMap<K, V>();
  final int maxSize;

  _LRUCache(this.maxSize);

  V? get(K key) {
    if (!_cache.containsKey(key)) {
      return null;
    }
    // Move to end (most recently used) by removing and re-inserting
    final value = _cache.remove(key);
    if (value != null) {
      _cache[key] = value;
    }
    return value;
  }

  void put(K key, V value) {
    // If key exists, update and move to end
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    } else if (_cache.length >= maxSize) {
      // Remove least recently used (first item)
      final firstKey = _cache.keys.first;
      _cache.remove(firstKey);
    }
    _cache[key] = value;
  }

  bool containsKey(K key) => _cache.containsKey(key);
}

class FontService {
  // WHY: Use LRU cache to limit memory usage (max 50 fonts cached).
  // Evicts least recently used fonts when cache is full.
  final _LRUCache<String, String> _loadedFonts = _LRUCache<String, String>(
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
