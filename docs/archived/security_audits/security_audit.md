# Security Audit Report - Mushaf App

**Date**: 2025-11-04
**App Version**: 1.0.0-beta.1+1
**Audit Scope**: Complete application security review

## Executive Summary

This security audit identified several security concerns and recommendations for the Mushaf App. The application generally follows good security practices with parameterized database queries and proper error handling. However, there are areas for improvement, particularly around input validation, network security, and data protection.

**Overall Security Rating**: ⚠️ **MEDIUM** - Good security practices with some areas needing attention.

---

## Critical Issues

### ✅ CRITICAL-1: SQL Injection Vulnerability in Database Service [FIXED]

**Location**: `lib/services/database_service.dart:504` (now line 508-509)

**Issue**: **CRITICAL SQL INJECTION VULNERABILITY** - The `getAyahsOnPage()` method uses string interpolation for an IN clause, which is vulnerable to SQL injection.

```dart
where: '${DbConstants.idCol} IN (${wordIds.join(', ')})',
```

**Risk**: While `wordIds` is parsed from database data (not direct user input), this pattern is unsafe and could be exploited if:

- The database data is ever compromised
- The parsing logic has bugs
- Future code changes introduce user-controlled data

**Recommendation**:

```dart
// UNSAFE (current code):
where: '${DbConstants.idCol} IN (${wordIds.join(', ')})',

// SAFE (should be):
final placeholders = List.filled(wordIds.length, '?').join(', ');
where: '${DbConstants.idCol} IN ($placeholders)',
whereArgs: wordIds.toList(),
```

**Severity**: 🔴 CRITICAL - ✅ **FIXED** (2024-12-19)

**Status**: Fixed by replacing string interpolation with parameterized query using placeholders and `whereArgs`.

---

### 🔴 CRITICAL-2: SQL Injection Risk in Search Service

**Location**: `lib/services/search_service.dart:247-248, 257-258, 293-301, 324-334`

**Issue**: Search queries use string interpolation for IN clauses, which is vulnerable to SQL injection.

```dart
// Line 293-301: Uses placeholders correctly
final placeholders = List.filled(verseKeysList.length, '?').join(', ');
where: 'verse_key IN ($placeholders)',
whereArgs: verseKeysList,

// Line 324-334: Also uses placeholders correctly
final fallbackPlaceholders = List.filled(missingFromScript.length, '?').join(', ');
where: 'verse_key IN ($fallbackPlaceholders)',
whereArgs: missingFromScript,
```

**Note**: The search service actually uses parameterized queries correctly for IN clauses. However, the LIKE patterns with user input need validation.

**Risk**: While parameterized queries are used, the LIKE pattern construction with `%` could be exploited if the underlying library has vulnerabilities.

**Recommendation**:

- Add input sanitization to remove or escape special SQL characters
- Limit query length to prevent DoS attacks
- Consider using FTS (Full-Text Search) for better security and performance

**Severity**: 🔴 HIGH

---

### 🔴 CRITICAL-3: Unvalidated Audio URLs

**Location**: `lib/services/audio_service.dart:105, 154`

**Issue**: Audio URLs are loaded directly from the database without validation. If the database is compromised or contains malicious URLs, the app could load content from untrusted sources.

```dart
await _audioPlayer.setUrl(surahAudio.audioUrl);
```

**Risk**:

- Potential for XSS or code injection if audio player is vulnerable
- MITM attacks if URLs are over HTTP
- Malicious content could be loaded

**Recommendation**:

- Validate audio URLs against a whitelist of trusted domains
- Ensure all URLs use HTTPS
- Add URL scheme validation (must be http:// or https://)
- Implement certificate pinning for audio CDN

**Severity**: 🔴 HIGH

---

## High Priority Issues

### 🟡 HIGH-1: Insufficient Input Validation

**Location**: Multiple files

**Issue**: Several user inputs lack proper validation:

1. **Search Query** (`lib/services/search_service.dart:204`):

   - No length limits
   - No character restrictions
   - Could cause DoS with extremely long queries

2. **Surah/Ayah Numbers** (`lib/services/bookmarks_service.dart:83-87`):
   - Basic validation exists (1-114 for surah, >0 for ayah)
   - But no validation in database service methods like `getAyahText()`

**Recommendation**:

```dart
// Add validation helper
void validateSearchQuery(String query) {
  if (query.length > 500) {
    throw ArgumentError('Search query too long');
  }
  // Remove potentially dangerous characters
  final sanitized = query.replaceAll(RegExp(r'[<>"\']'), '');
  // ... use sanitized
}
```

**Severity**: 🟡 MEDIUM-HIGH

---

### 🟡 HIGH-2: Path Traversal in File Operations

**Location**: `lib/services/database_service.dart:173-202`, `lib/services/search_service.dart:174-201`

**Issue**: Database files are copied from assets using file paths. While the paths are hardcoded, there's no explicit validation to prevent path traversal attacks if the asset path is ever constructed from user input.

```dart
final dbPath = p.join(docsDir.path, fileName);
await _copyDbFromAssets(assetFileName: fileName, destinationPath: dbPath);
```

**Risk**: If `fileName` could ever come from user input or external sources, path traversal attacks could write files outside the intended directory.

**Recommendation**:

- Add path validation to ensure files stay within the documents directory
- Use `p.normalize()` and validate the resolved path
- Whitelist allowed database file names

**Severity**: 🟡 MEDIUM-HIGH

---

### 🟡 HIGH-3: Sensitive Data in SharedPreferences

**Location**: `lib/providers.dart`, `lib/services/bookmarks_service.dart`

**Issue**: SharedPreferences stores user data without encryption. While this is standard for Flutter apps, sensitive data like reading progress and bookmarks could be accessed if the device is compromised.

**Recommendation**:

- Use `flutter_secure_storage` for sensitive data
- Encrypt bookmarks and reading progress data
- Consider using encrypted SQLite for user data instead of SharedPreferences

**Severity**: 🟡 MEDIUM

---

## Medium Priority Issues

### 🟠 MEDIUM-1: Debug Logging in Production

**Location**: Multiple files (99 instances of `debugPrint`)

**Issue**: While `debugPrint` is gated by `kDebugMode`, there's a risk that sensitive information could be logged if debug mode is accidentally enabled in production.

**Examples**:

- Error messages containing database paths
- Stack traces in catch blocks
- User queries and search terms

**Recommendation**:

- Audit all `debugPrint` statements to ensure no sensitive data is logged
- Consider using a logging library with proper log levels
- Remove or redact sensitive information from error messages

**Severity**: 🟠 MEDIUM

---

### 🟠 MEDIUM-2: Missing Network Security Configuration

**Location**: `android/app/src/main/AndroidManifest.xml`

**Issue**: No network security configuration is defined. Android 9+ requires explicit network security configuration for cleartext traffic.

**Recommendation**:

- Add `android:networkSecurityConfig` to AndroidManifest
- Create `res/xml/network_security_config.xml` to restrict cleartext traffic
- Ensure all network traffic uses HTTPS

**Severity**: 🟠 MEDIUM

---

### 🟠 MEDIUM-3: Database Access Without Encryption

**Location**: `lib/services/app_data_service.dart`

**Issue**: User data is stored in SQLite without encryption. If the device is compromised, bookmarks, reading progress, and memorization data could be accessed.

**Recommendation**:

- Consider using `sqflite_encrypted` or similar for sensitive user data
- At minimum, encrypt sensitive fields before storage
- Implement proper key management

**Severity**: 🟠 MEDIUM

---

### 🟠 MEDIUM-4: Raw SQL Queries

**Location**: `lib/services/database_service.dart:331`, `lib/services/reading_progress_service.dart`

**Issue**: Some queries use `rawQuery()` with string interpolation for table/column names. While these use constants, they're less maintainable and could introduce vulnerabilities if constants are modified.

```dart
await _layoutDb!.rawQuery(
  'SELECT ${DbConstants.surahNumberCol}, MIN(${DbConstants.pageNumberCol}) as ${DbConstants.startPageAlias} FROM ${DbConstants.pagesTable} WHERE ${DbConstants.surahNumberCol} > 0 GROUP BY ${DbConstants.surahNumberCol}',
);
```

**Recommendation**:

- Prefer parameterized queries where possible
- Document why raw queries are necessary
- Add validation that constants contain only safe characters

**Severity**: 🟠 LOW-MEDIUM

---

## Low Priority Issues

### 🔵 LOW-1: Missing Permissions Review

**Location**: `android/app/src/main/AndroidManifest.xml`

**Issue**: No explicit permissions are declared, which is good, but should be verified that no plugins require additional permissions that could be security risks.

**Recommendation**:

- Review all dependencies for required permissions
- Document why each permission is needed
- Use `android:maxSdkVersion` for permissions not needed on newer Android versions

**Severity**: 🔵 LOW

---

### 🔵 LOW-2: No Certificate Pinning

**Issue**: If the app makes network requests (audio URLs), there's no certificate pinning implemented.

**Recommendation**:

- Implement certificate pinning for audio CDN
- Use `dio` with `certificate_pinning` or similar solution

**Severity**: 🔵 LOW (if audio URLs are external)

---

### 🔵 LOW-3: No Rate Limiting

**Location**: Search and database operations

**Issue**: No rate limiting on search queries or database operations could allow DoS attacks.

**Recommendation**:

- Implement rate limiting for search queries
- Add debouncing to search input
- Limit maximum query length

**Severity**: 🔵 LOW

---

## Platform-Specific Security

### Android

✅ **Good Practices**:

- Uses `singleTop` launch mode
- Proper activity configuration
- No dangerous permissions declared

⚠️ **Missing**:

- Network security configuration
- Backup restrictions (should disable automatic backups for sensitive data)

### iOS

✅ **Good Practices**:

- Standard Info.plist configuration
- No excessive permissions

⚠️ **Missing**:

- App Transport Security configuration
- Keychain configuration for sensitive data

---

## Dependency Security

### Current Dependencies

All dependencies appear to be well-maintained and recent:

- `sqflite: ^2.4.2` ✅
- `path_provider: ^2.1.5` ✅
- `flutter_riverpod: ^3.0.3` ✅
- `shared_preferences: ^2.5.3` ✅
- `just_audio: ^0.9.40` ✅

**Recommendation**:

- Run `flutter pub outdated` regularly
- Consider using `dependabot` or similar for automated updates
- Review dependency changelogs for security patches

---

## Recommended Security Improvements

### Immediate Actions (Critical)

1. ✅ **CRITICAL: Fix SQL Injection in Database Service** (PRIORITY 1) - **COMPLETED**

   - **File**: `lib/services/database_service.dart:504` (now lines 502-509)
   - **Fix**: ✅ Replaced string interpolation with parameterized query for IN clause
   - **Impact**: Prevents SQL injection vulnerability
   - **Status**: Fixed on 2024-12-19

2. ✅ **Validate and sanitize search queries**

   - Add length limits (max 500 characters)
   - Sanitize special characters
   - Implement query timeout

3. ✅ **Validate audio URLs**

   - Whitelist trusted domains
   - Enforce HTTPS
   - Add URL scheme validation

4. ✅ **Add input validation**
   - Validate all user inputs at service boundaries
   - Add type checking and range validation
   - Implement input sanitization helpers

### Short-term (High Priority)

5. ✅ **Encrypt sensitive user data**

   - Use `flutter_secure_storage` for preferences
   - Encrypt SQLite database or sensitive fields

6. ✅ **Implement network security**

   - Add Android network security config
   - Configure iOS App Transport Security
   - Implement certificate pinning for audio URLs

7. ✅ **Improve file operations security**
   - Add path validation for file operations
   - Whitelist allowed file names
   - Use `p.normalize()` and validate resolved paths

### Medium-term (Medium Priority)

8. ✅ **Audit logging statements**

   - Review all `debugPrint` calls
   - Remove sensitive data from logs
   - Implement proper log levels

9. ✅ **Add rate limiting**

   - Implement debouncing for search
   - Add query rate limits
   - Monitor for DoS patterns

10. ✅ **Document security practices**

- Create security guidelines for developers
- Document threat model
- Establish security review process

---

## Security Best Practices Checklist

- [x] Parameterized database queries (mostly)
- [x] Input validation (partial - needs improvement)
- [x] Error handling (good)
- [ ] Input sanitization (needs implementation)
- [ ] Network security configuration (missing)
- [ ] Data encryption (missing)
- [ ] Certificate pinning (missing)
- [ ] Rate limiting (missing)
- [x] Proper error messages (no sensitive data exposed)
- [ ] Security logging (needs audit)

---

## Threat Model

### Potential Attack Vectors

1. **SQL Injection**: Mitigated by parameterized queries, but search LIKE patterns need validation
2. **Path Traversal**: Low risk as paths are hardcoded, but should add validation
3. **Malicious Audio URLs**: Medium risk - need URL validation
4. **Data Theft**: Medium risk - device compromise could access unencrypted data
5. **DoS Attacks**: Low-medium risk - no rate limiting on search/database operations

### Data at Risk

- **Bookmarks**: User-created bookmarks (surah:ayah pairs)
- **Reading Progress**: Session data and statistics
- **Memorization Data**: User progress in memorization
- **Search History**: User search queries (if stored)

---

## Conclusion

The Mushaf App demonstrates good security practices in many areas, particularly with parameterized database queries and proper error handling. However, there are several critical and high-priority issues that should be addressed:

1. **Critical**: Validate and sanitize search queries and audio URLs
2. **High**: Implement input validation, file path validation, and data encryption
3. **Medium**: Add network security configurations and audit logging

The app is generally secure for a local-first application, but improvements in input validation, network security, and data protection would significantly enhance the security posture.

---

## Next Steps

1. Create GitHub issues for each critical and high-priority item
2. Prioritize fixes based on this audit
3. Implement security improvements in phases
4. Schedule regular security audits (quarterly recommended)
5. Consider third-party security audit for production release

---

**Report Generated**: 2024-12-19
**Auditor**: AI Security Analysis
**Next Review**: Recommended in 3 months or before production release
