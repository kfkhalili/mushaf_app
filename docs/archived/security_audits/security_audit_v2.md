# Security Audit Report v2 - Mushaf App

**Date**: 2025-11-04
**App Version**: 1.0.0-beta.1+1
**Audit Scope**: In-depth follow-up security review after initial fixes

## Executive Summary

This follow-up security audit was conducted after implementing the fixes from the initial security audit. The review identified **3 additional security issues** that were missed in the first audit:

1. **Unvalidated surah name input** in `getSurahByName()` method
2. **Information leakage** through error messages displayed to users
3. **Inconsistent validation** in reading progress service

**Overall Security Rating**: ⚠️ **MEDIUM-HIGH** - Most critical issues fixed, but some remaining concerns need attention.

---

## New Issues Found

### 🔴 HIGH-1: Unvalidated Input in getSurahByName()

**Location**: `lib/services/database_service.dart:335-346`

**Issue**: The `getSurahByName()` method accepts a `surahName` string parameter and uses it directly in a LIKE query without validation. While the search service validates its queries, this method could be called directly from other parts of the codebase.

```dart
Future<List<Map<String, dynamic>>> getSurahByName(String surahName) async {
  // ...
  return _metadataDb!.query(
    DbConstants.chaptersTable,
    columns: [DbConstants.idCol],
    where: '${DbConstants.nameArabicCol} LIKE ?',
    whereArgs: ['%$surahName%'],
  );
}
```

**Risk**:

- No length validation (DoS potential with extremely long strings)
- No character sanitization (though parameterized queries mitigate SQL injection)
- Could be called directly without going through search service validation

**Current Usage**:

- Called from `lib/services/search_service.dart:545` via `searchBySurahName()`
- The search service validates the input, but this method could be called directly

**Recommendation**:

1. Add input validation at the start of `getSurahByName()` method
2. Use the existing `validateSearchQuery()` helper or create a similar validation
3. Limit surah name length (e.g., max 100 characters)

**Severity**: 🟡 **HIGH** - Defense in depth needed

---

### 🟡 MEDIUM-1: Information Leakage Through Error Messages

**Location**: `lib/screens/explore_hub_screen.dart:214`

**Issue**: Error messages are displayed directly to users using `error.toString()`, which could leak sensitive information like:

- Database file paths
- Stack traces (in debug builds)
- Internal error details
- System information

```dart
Text(
  error.toString(),  // ❌ Could leak sensitive info
  textAlign: TextAlign.center,
  style: Theme.of(context).textTheme.bodyMedium,
),
```

**Risk**:

- Exposes internal system details to attackers
- Could reveal file system structure
- Stack traces might leak code structure
- Database errors might reveal schema information

**Recommendation**:

1. Create user-friendly error messages instead of displaying raw exceptions
2. Map technical errors to generic user-facing messages
3. Only show detailed errors in debug mode
4. Log full error details server-side (if applicable) or in debug logs only

**Example Fix**:

```dart
// Instead of error.toString()
Text(
  _getUserFriendlyErrorMessage(error),
  // ...
),

String _getUserFriendlyErrorMessage(Object error) {
  if (error is DatabaseConnectionException) {
    return 'لا يمكن الاتصال بقاعدة البيانات';
  } else if (error is DatabaseNotFoundException) {
    return 'البيانات المطلوبة غير موجودة';
  } else {
    return 'حدث خطأ غير متوقع';
  }
}
```

**Severity**: 🟡 **MEDIUM** - Information disclosure risk

---

### 🟡 MEDIUM-2: Inconsistent Validation in Reading Progress Service

**Location**: `lib/services/reading_progress_service.dart:67-91`

**Issue**: The `recordPageView()` method uses manual validation instead of the centralized validation helpers. While the validation logic is correct, it's inconsistent with the rest of the codebase and could become out of sync.

```dart
Future<void> recordPageView(int pageNumber) async {
  // Manual validation instead of using validatePageNumber()
  if (pageNumber < 1) {
    throw ArgumentError('Page number must be >= 1');
  }
  // ... more manual validation
}
```

**Risk**:

- Validation logic could diverge from centralized helpers
- Code duplication
- Potential inconsistencies if validation rules change

**Recommendation**:

1. Use the existing `validatePageNumber()` helper from `validation_helpers.dart`
2. Remove duplicate validation logic
3. Ensure consistency across all services

**Severity**: 🟡 **MEDIUM** - Code quality and consistency issue

---

## Issues Already Fixed (Verified)

### ✅ SQL Injection in Database Service

- **Status**: Fixed
- **Location**: `lib/services/database_service.dart:504` (now uses parameterized queries)

### ✅ Search Query Validation

- **Status**: Fixed
- **Location**: `lib/services/search_service.dart` (uses `validateSearchQuery()`)

### ✅ Audio URL Validation

- **Status**: Fixed
- **Location**: `lib/services/audio_service.dart` (uses `validateAudioUrl()`)

### ✅ Input Validation for Surah/Ayah Numbers

- **Status**: Fixed
- **Location**: `lib/services/database_service.dart` (multiple methods use validation helpers)

### ✅ Path Validation for File Operations

- **Status**: Fixed
- **Location**: All database copy operations use `validateFilePath()` and `validateDatabaseFileName()`

---

## Positive Security Findings

### ✅ Good Practices Found

1. **Parameterized Queries**: All SQL queries use parameterized queries correctly
2. **Path Validation**: File operations validate paths against whitelists
3. **Input Validation**: Most user inputs are validated using centralized helpers
4. **Error Handling**: Proper exception hierarchy with structured error types
5. **No Hardcoded Secrets**: No API keys or secrets found in code
6. **Secure Storage**: Database files are stored in app documents directory
7. **Type Safety**: Strong typing with proper null safety

---

## Recommendations Summary

### Immediate Actions (High Priority)

1. **Add validation to `getSurahByName()` method**

   - Use `validateSearchQuery()` or create similar validation
   - Add length limit (max 100 characters)
   - File: `lib/services/database_service.dart:335`

2. **Fix error message leakage**

   - Replace `error.toString()` with user-friendly messages
   - Only show detailed errors in debug mode
   - File: `lib/screens/explore_hub_screen.dart:214`

3. **Use centralized validation in reading progress service**
   - Replace manual validation with `validatePageNumber()` helper
   - File: `lib/services/reading_progress_service.dart:67-91`

### Short-term (Medium Priority)

4. **Review all error displays**

   - Audit all error message displays in UI
   - Ensure no sensitive information is exposed
   - Create error message mapping utility

5. **Add input validation tests**
   - Test validation helpers with edge cases
   - Test invalid inputs across all services
   - Ensure consistent error handling

### Medium-term (Low Priority)

6. **Security logging**

   - Add security event logging for suspicious activities
   - Log failed validation attempts
   - Monitor for potential attacks

7. **Code review process**
   - Establish security review checklist
   - Review all new code for security issues
   - Regular security audits

---

## Testing Recommendations

### Security Testing

1. **Input Validation Tests**

   - Test with extremely long strings (>1000 characters)
   - Test with special characters and SQL injection attempts
   - Test with path traversal attempts (`../`, `..\\`, etc.)

2. **Error Handling Tests**

   - Verify error messages don't leak sensitive information
   - Test error handling in production vs debug mode
   - Verify user-friendly error messages are displayed

3. **Path Validation Tests**
   - Test path traversal attempts
   - Test with invalid file names
   - Test with special characters in paths

---

## Conclusion

The initial security fixes have significantly improved the application's security posture. The three new issues identified are important but not critical. The application follows good security practices overall, with proper use of parameterized queries, input validation, and path validation.

**Priority Actions**:

1. Fix `getSurahByName()` validation (5 minutes)
2. Fix error message leakage (15 minutes)
3. Use centralized validation in reading progress service (5 minutes)

**Estimated Total Time**: 25 minutes

---

## Appendix: Security Checklist

### ✅ Completed

- [x] SQL injection vulnerabilities fixed
- [x] Input validation for search queries
- [x] Audio URL validation
- [x] Path validation for file operations
- [x] Input validation for surah/ayah numbers
- [x] Parameterized queries throughout

### ⚠️ In Progress

- [ ] Validation for `getSurahByName()` method
- [ ] Error message sanitization
- [ ] Consistent validation across all services

### 📋 Future

- [ ] Security logging
- [ ] Regular security audits
- [ ] Security testing suite
