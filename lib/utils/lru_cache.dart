import 'dart:collection'; // For LinkedHashMap

/// WHY: LRU (Least Recently Used) cache implementation using LinkedHashMap.
///
/// LinkedHashMap maintains insertion order, allowing O(1) operations.
/// When cache reaches maxSize, least recently used items are evicted.
///
/// This is a reusable utility for services that need bounded caches.
class LRUCache<K, V> {
  final LinkedHashMap<K, V> _cache = LinkedHashMap<K, V>();
  final int maxSize;

  LRUCache(this.maxSize);

  /// WHY: Gets value from cache, moving it to end (most recently used).
  /// Returns null if key doesn't exist.
  ///
  /// Optimization: Directly calls remove() which returns null if key doesn't exist,
  /// eliminating redundant containsKey() check.
  V? get(K key) {
    // Move to end (most recently used) by removing and re-inserting
    final value = _cache.remove(key);
    if (value != null) {
      _cache[key] = value;
      return value;
    }
    return null; // Key doesn't exist
  }

  /// WHY: Puts value in cache, evicting least recently used if at capacity.
  /// If key exists, updates value and moves to end.
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

  /// WHY: Checks if key exists in cache.
  bool containsKey(K key) => _cache.containsKey(key);

  /// WHY: Clears all entries from cache.
  void clear() => _cache.clear();

  /// WHY: Gets current cache size.
  int get length => _cache.length;
}
