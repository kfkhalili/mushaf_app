# Security Audit Report v6 - Mushaf App

**Date**: 2025-11-04
**App Version**: 1.0.0-beta.1+1
**Audit Scope**: Comprehensive security review focusing on DateTime parsing, JSON deserialization, and unsafe type casts

## Executive Summary

This sixth security audit was conducted with extreme thoroughness, examining areas that previous audits may have missed, particularly around DateTime parsing, JSON deserialization, and unsafe type casts in services that handle user data. The review identified **6 new security issues** that require attention:

1. **Unsafe DateTime.parse() calls without exception handling** in BookmarksService and ReadingProgressService
2. **Unsafe type casts without null checks** in BookmarksService
3. **Unsafe JSON deserialization** in MemorizationStorageSqlite
4. **Unsafe type casts in reading progress queries** without null checks
5. **Unvalidated parsed surah/ayah numbers** in DatabaseService helper method
6. **Unsafe type casts in reading progress statistics** without null checks

**Overall Security Rating**: ✅ **GOOD** - Strong security foundation with minor improvements needed for robust error handling and type safety.

---

## New Issues Found

### 🟡 MEDIUM-1: Unsafe DateTime.parse() Calls Without Exception Handling

**Location**: `lib/services/bookmarks_service.dart:219, 260`, `lib/services/reading_progress_service.dart:304, 384, 413`

**Issue**: `DateTime.parse()` is called on database string values without try-catch blocks. If the database contains corrupted or malformed date strings, `DateTime.parse()` will throw a `FormatException`, potentially causing app crashes.

**Example 1 - BookmarksService**:

```219:219:lib/services/bookmarks_service.dart
            createdAt: DateTime.parse(row[DbConstants.createdAtCol] as String),
```

**Example 2 - ReadingProgressService**:

```304:305:lib/services/reading_progress_service.dart
        .map((row) => DateTime.parse(row[DbConstants.sessionDateCol] as String))
        .toList();
```

**Risk**:

- Corrupted database data could cause app crashes
- Malformed date strings from database migration could cause failures
- No graceful handling of invalid date formats
- Could cause data loss if exceptions propagate

**Current Practice**:

- `MemorizationStorageSqlite` wraps `DateTime.parse()` in try-catch (good example)
- Most date parsing is done without exception handling
- Database date strings are assumed to be valid ISO 8601 format

**Recommendation**:

1. Wrap all `DateTime.parse()` calls in try-catch blocks
2. Provide safe defaults (e.g., current date) when parsing fails
3. Log warnings in debug mode for invalid date formats
4. Skip invalid entries in bulk operations

**Example Fix**:

```dart
// ✅ GOOD - Safe DateTime parsing
DateTime? parseDateSafely(String? dateStr) {
  if (dateStr == null) return null;
  try {
    return DateTime.parse(dateStr);
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Invalid date format: $dateStr');
    }
    return null; // Safe default
  }
}

// Usage
final createdAt = parseDateSafely(row[DbConstants.createdAtCol] as String?)
    ?? DateTime.now(); // Safe default
```

**Severity**: 🟡 **MEDIUM** - Data corruption could cause crashes

---

### 🟡 MEDIUM-2: Unsafe Type Casts Without Null Checks in BookmarksService

**Location**: `lib/services/bookmarks_service.dart:196, 197, 209, 210, 215, 256, 257, 258`

**Issue**: Type casts using `as int` without null checks. While database queries should return consistent types, corrupted data or schema changes could cause runtime exceptions.

**Example 1 - Bulk Ayah Collection**:

```196:198:lib/services/bookmarks_service.dart
                surahNumber: row[DbConstants.surahNumberCol] as int,
                ayahNumber: row[DbConstants.ayahNumberCol] as int,
              ),
```

**Example 2 - Bookmark Creation**:

```209:210:lib/services/bookmarks_service.dart
        final surahNumber = row[DbConstants.surahNumberCol] as int;
        final ayahNumber = row[DbConstants.ayahNumberCol] as int;
```

**Risk**:

- Runtime exceptions if database data is corrupted
- Schema changes could cause widespread failures
- No graceful handling of unexpected data types
- Could cause app crashes if data is invalid

**Current Practice**:

- `SearchService` uses nullable casts (`as String?`) with null checks (good example)
- `DatabaseService` uses nullable casts for most string fields
- `BookmarksService` still uses non-nullable casts without checks

**Recommendation**:

1. Use nullable casts (`as int?`) and check for null
2. Validate parsed surah/ayah numbers after casting
3. Provide safe defaults or skip invalid entries
4. Log warnings in debug mode for invalid data

**Example Fix**:

```dart
// ✅ GOOD - Safe type casting with validation
final int? surahNumberNullable = row[DbConstants.surahNumberCol] as int?;
final int? ayahNumberNullable = row[DbConstants.ayahNumberCol] as int?;

if (surahNumberNullable == null || ayahNumberNullable == null) {
  if (kDebugMode) {
    debugPrint('Missing surah/ayah in bookmark data');
  }
  continue; // Skip invalid entries
}

// Validate parsed values
try {
  validateSurahNumber(surahNumberNullable);
  validateAyahNumber(ayahNumberNullable);
} catch (e) {
  if (kDebugMode) {
    debugPrint('Invalid surah/ayah in bookmark: $surahNumberNullable:$ayahNumberNullable');
  }
  continue; // Skip invalid entries
}

final int surahNumber = surahNumberNullable;
final int ayahNumber = ayahNumberNullable;
```

**Severity**: 🟡 **MEDIUM** - Type safety and defense in depth

---

### 🟡 MEDIUM-3: Unsafe JSON Deserialization in MemorizationStorageSqlite

**Location**: `lib/services/memorization_storage_sqlite.dart:64-65`

**Issue**: `jsonDecode()` is called with a non-nullable cast `as String`, and the result is cast to `Map<String, dynamic>` without validation. If the JSON is malformed or the structure is unexpected, this could cause runtime exceptions.

**Example**:

```63:65:lib/services/memorization_storage_sqlite.dart
      final windowJson =
          jsonDecode(row[DbConstants.windowDataCol] as String)
              as Map<String, dynamic>;
```

**Risk**:

- Malformed JSON could cause exceptions
- Unexpected JSON structure could cause type errors
- No validation of JSON structure before use
- Could cause data loss if exceptions propagate

**Current Practice**:

- The method wraps the entire block in try-catch (good)
- However, the nullable cast and type validation could be improved
- No validation of JSON structure before accessing fields

**Recommendation**:

1. Use nullable cast for the database string field
2. Validate JSON structure before accessing fields
3. Check for required fields before deserialization
4. Provide more detailed error messages in debug mode

**Example Fix**:

```dart
// ✅ GOOD - Safe JSON deserialization
final String? windowDataStr = row[DbConstants.windowDataCol] as String?;
if (windowDataStr == null) {
  if (kDebugMode) {
    debugPrint('Missing window data in memorization session');
  }
  return null; // Safe default
}

try {
  final decoded = jsonDecode(windowDataStr);
  if (decoded is! Map<String, dynamic>) {
    throw FormatException('Expected Map, got ${decoded.runtimeType}');
  }
  final windowJson = decoded;

  // Validate required fields
  if (!windowJson.containsKey('ayahIndices') ||
      !windowJson.containsKey('opacities') ||
      !windowJson.containsKey('tapsSinceReveal')) {
    throw FormatException('Missing required fields in window data');
  }

  return MemorizationSessionState(
    // ... rest of deserialization
  );
} catch (e) {
  if (kDebugMode) {
    debugPrint('Error deserializing memorization session: $e');
  }
  return null; // Safe default
}
```

**Severity**: 🟡 **MEDIUM** - Type safety and data validation

---

### 🟡 MEDIUM-4: Unsafe Type Casts in Reading Progress Queries

**Location**: `lib/services/reading_progress_service.dart:304, 356, 382, 411`

**Issue**: Type casts using `as String` or `as int` without null checks in reading progress queries. While the queries should return consistent types, corrupted data could cause runtime exceptions.

**Example 1 - DateTime Parsing**:

```304:305:lib/services/reading_progress_service.dart
        .map((row) => DateTime.parse(row[DbConstants.sessionDateCol] as String))
        .toList();
```

**Example 2 - Page Number Casting**:

```356:357:lib/services/reading_progress_service.dart
        .map((row) => row[DbConstants.pageNumberCol] as int)
        .toSet()
```

**Risk**:

- Runtime exceptions if database data is corrupted
- Schema changes could cause widespread failures
- No graceful handling of unexpected data types
- Could cause app crashes if data is invalid

**Current Practice**:

- Most other services use nullable casts with null checks
- `ReadingProgressService` still uses non-nullable casts without checks
- Statistics queries use nullable casts with null coalescing (good)

**Recommendation**:

1. Use nullable casts (`as String?`, `as int?`) and check for null
2. Wrap `DateTime.parse()` in try-catch blocks
3. Filter out invalid entries in bulk operations
4. Log warnings in debug mode for invalid data

**Example Fix**:

```dart
// ✅ GOOD - Safe type casting with exception handling
final dates = dateResults
    .map((row) {
      final String? dateStr = row[DbConstants.sessionDateCol] as String?;
      if (dateStr == null) return null;
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Invalid date format in reading progress: $dateStr');
        }
        return null;
      }
    })
    .whereType<DateTime>() // Filter out null values
    .toList();
```

**Severity**: 🟡 **MEDIUM** - Type safety and error handling

---

### 🟢 LOW-1: Unvalidated Parsed Surah/Ayah Numbers in DatabaseService Helper

**Location**: `lib/services/database_service.dart:496-497`

**Issue**: Parsed surah/ayah numbers from database results are used directly without validation. While the values are checked for > 0, they are not validated against the valid ranges (surah 1-114, ayah > 0).

**Example**:

```496:499:lib/services/database_service.dart
          final int surah = parseInt(words.first[DbConstants.surahCol]);
          final int ayah = parseInt(words.first[DbConstants.ayahNumberCol]);
          if (surah > 0 && ayah > 0) {
            return {'surah': surah, 'ayah': ayah}; // Found it
```

**Risk**:

- Invalid surah/ayah numbers (e.g., surah 200, ayah 500) could cause unexpected behavior
- Database corruption could result in invalid values being used
- Inconsistent with other methods that validate surah/ayah numbers
- Could cause errors downstream when invalid values are used

**Current Practice**:

- `SearchService` validates parsed surah/ayah numbers (good example)
- `OntologyService` validates parsed surah/ayah numbers (good example)
- `DatabaseService.getPageForAyah()` validates input parameters
- This helper method should also validate parsed values

**Recommendation**:

1. Validate parsed surah/ayah numbers after parsing
2. Use existing `validateSurahNumber()` and `validateAyahNumber()` helpers
3. Skip invalid entries or return safe defaults

**Example Fix**:

```dart
// ✅ GOOD - Validate parsed values
final int surah = parseInt(words.first[DbConstants.surahCol]);
final int ayah = parseInt(words.first[DbConstants.ayahNumberCol]);

try {
  validateSurahNumber(surah);
  validateAyahNumber(ayah);
  if (surah > 0 && ayah > 0) {
    return {'surah': surah, 'ayah': ayah};
  }
} catch (e) {
  if (kDebugMode) {
    debugPrint('Invalid surah/ayah in database: $surah:$ayah');
  }
  // Continue to next iteration
}
```

**Severity**: 🟢 **LOW** - Defense in depth and consistency

---

### 🟢 LOW-2: Unsafe Type Casts in Reading Progress Statistics

**Location**: `lib/services/reading_progress_service.dart:163, 178, 193, 208, 223, 238, 247`

**Issue**: Statistics queries use `.first['count'] as int? ?? 0`, which is safe, but the pattern could be improved for consistency and clarity.

**Example**:

```163:163:lib/services/reading_progress_service.dart
    return result.first['count'] as int? ?? 0;
```

**Risk**:

- Low risk - already uses nullable cast with null coalescing
- Could be improved for consistency with other services
- No explicit check for empty results before accessing `.first`

**Current Practice**:

- Uses nullable cast with null coalescing (safe)
- However, accessing `.first` without checking `isNotEmpty` could throw if result is empty
- Other services check `isNotEmpty` before accessing `.first`

**Recommendation**:

1. Check `isNotEmpty` before accessing `.first` for consistency
2. Keep the nullable cast pattern for type safety
3. This is a minor improvement for consistency

**Example Fix**:

```dart
// ✅ GOOD - Check isNotEmpty before accessing .first
if (result.isNotEmpty) {
  return result.first['count'] as int? ?? 0;
}
return 0; // Safe default
```

**Severity**: 🟢 **LOW** - Consistency improvement

---

## Verification of Previous Fixes

All issues from previous security audits (v1-v5) have been verified as fixed:

- ✅ SQL injection vulnerabilities - Fixed
- ✅ Unvalidated inputs - Fixed
- ✅ Path traversal vulnerabilities - Fixed
- ✅ Information leakage through error messages - Fixed
- ✅ Unvalidated parsed surah/ayah numbers - Fixed (SearchService, OntologyService)
- ✅ Exception toString() methods - Fixed
- ✅ Unsafe type casts - Fixed (SearchService, DatabaseService)

---

## Security Code Quality Analysis

### SQL Query Security

**Status**: ✅ **EXCELLENT**

- All queries use parameterized queries
- No string interpolation found
- IN clauses use placeholders correctly
- LIKE queries use parameterized patterns

### File Operation Security

**Status**: ✅ **EXCELLENT**

- All file operations validate paths
- Database file names validated against whitelists
- Path traversal prevention implemented
- Consistent pattern across all services

### Input Validation Security

**Status**: ✅ **GOOD** (with minor improvements needed)

- Most user inputs validated using centralized helpers
- Search queries validated
- Surah/ayah numbers validated (mostly)
- Page numbers validated
- Audio URLs validated
- **Remaining**: DateTime parsing, JSON deserialization, some type casts

### Error Handling Security

**Status**: ✅ **GOOD** (with minor improvements needed)

- Most screens use user-friendly error messages
- Custom exception hierarchy
- Debug logging only in debug mode
- **Remaining**: DateTime.parse() exception handling, JSON deserialization error handling

### Data Parsing Security

**Status**: ✅ **GOOD** (with minor improvements needed)

- Safe parsing utilities (`parseInt()` returns 0 on failure)
- Type checking before parsing
- Handles null values gracefully
- **Remaining**: DateTime.parse() exception handling, JSON structure validation

---

## Recommendations Summary

### High Priority (Medium Severity)

1. **Fix DateTime.parse() exception handling** in BookmarksService and ReadingProgressService
2. **Fix unsafe type casts** in BookmarksService (use nullable casts with null checks)
3. **Fix unsafe JSON deserialization** in MemorizationStorageSqlite (add structure validation)

### Low Priority

1. **Add validation for parsed surah/ayah numbers** in DatabaseService helper method
2. **Improve consistency** in ReadingProgressService statistics queries

---

## Conclusion

The Mushaf App has a strong security foundation with excellent SQL query security, file operation security, and input validation. The remaining issues are primarily related to robust error handling and type safety improvements, which are important for defense in depth and graceful degradation.

**Next Steps**:

1. Fix DateTime.parse() exception handling (Medium priority)
2. Fix unsafe type casts in BookmarksService (Medium priority)
3. Fix unsafe JSON deserialization (Medium priority)
4. Add validation for parsed surah/ayah numbers (Low priority)
5. Improve consistency in statistics queries (Low priority)

---

**Audit Completed**: 2025-11-04
**Auditor**: AI Security Review System
**Next Audit**: Recommended after implementing fixes
