import 'package:path/path.dart' as p;

// WHY: Shared validation utilities for input sanitization and security.
//
// This provides consistent validation across the app to prevent:
// - SQL injection (through input sanitization)
// - DoS attacks (through length limits)
// - Path traversal (through path validation)
// - Malicious URLs (through URL validation)

/// Validates and sanitizes a search query.
///
/// Returns the sanitized query or throws [ArgumentError] if invalid.
///
/// Validation rules:
/// - Maximum length: 500 characters
/// - Removes potentially dangerous characters
/// - Trims whitespace
///
/// Throws [ArgumentError] if query is too long or empty after sanitization.
String validateSearchQuery(String query) {
  if (query.trim().isEmpty) {
    throw ArgumentError('Search query cannot be empty');
  }

  final trimmed = query.trim();
  if (trimmed.length > 500) {
    throw ArgumentError('Search query too long (max 500 characters)');
  }

  // Remove potentially dangerous SQL characters
  // Note: We still use parameterized queries, but this adds defense in depth
  final sanitized = trimmed
      .replaceAll('<', '')
      .replaceAll('>', '')
      .replaceAll('"', '')
      .replaceAll("'", '');

  if (sanitized.isEmpty) {
    throw ArgumentError('Search query contains only invalid characters');
  }

  return sanitized;
}

/// Validates a surah number (1-114).
///
/// Throws [ArgumentError] if surah number is out of range.
void validateSurahNumber(int surahNumber) {
  if (surahNumber < 1 || surahNumber > 114) {
    throw ArgumentError(
      'Surah number must be between 1 and 114, got: $surahNumber',
    );
  }
}

/// Validates an ayah number (must be > 0 and < 286).
///
/// Throws [ArgumentError] if ayah number is invalid.
void validateAyahNumber(int ayahNumber) {
  if (ayahNumber < 1 || ayahNumber > 286) {
    throw ArgumentError(
      'Ayah number must be greater than 0 and less than 286, got: $ayahNumber',
    );
  }
}

/// Validates both surah and ayah numbers.
///
/// Throws [ArgumentError] if either number is invalid.
void validateSurahAyah(int surahNumber, int ayahNumber) {
  validateSurahNumber(surahNumber);
  validateAyahNumber(ayahNumber);
}

/// Validates a page number (1-604).
///
/// Throws [ArgumentError] if page number is out of range.
void validatePageNumber(int pageNumber) {
  if (pageNumber < 1 || pageNumber > 604) {
    throw ArgumentError(
      'Page number must be between 1 and 604, got: $pageNumber',
    );
  }
}

/// Validates an audio URL.
///
/// Returns the validated URL or throws [ArgumentError] if invalid.
///
/// Validation rules:
/// - Must be http:// or https://
/// - Must be a valid URL format
/// - Optional: Can check against whitelist of trusted domains
///
/// Throws [ArgumentError] if URL is invalid or uses unsupported scheme.
String validateAudioUrl(String url) {
  if (url.trim().isEmpty) {
    throw ArgumentError('Audio URL cannot be empty');
  }

  final trimmed = url.trim();

  // Check URL scheme
  if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
    throw ArgumentError(
      'Audio URL must use http:// or https:// scheme, got: $trimmed',
    );
  }

  // Basic URL validation - ensure it's a well-formed URL
  try {
    final uri = Uri.parse(trimmed);
    if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw ArgumentError('Invalid URL scheme: ${uri.scheme}');
    }
    if (uri.host.isEmpty) {
      throw ArgumentError('URL must have a host');
    }
  } catch (e) {
    if (e is ArgumentError) {
      rethrow;
    }
    throw ArgumentError('Invalid URL format: $trimmed');
  }

  return trimmed;
}

/// Validates a file path to prevent path traversal attacks.
///
/// Ensures the resolved path is within the allowed directory.
///
/// [filePath] - The path to validate
/// [allowedDirectory] - The directory that the file must be within
///
/// Returns the normalized path if valid.
///
/// Throws [ArgumentError] if path is outside the allowed directory.
String validateFilePath(String filePath, String allowedDirectory) {
  final path = p.normalize(filePath);
  final allowed = p.normalize(allowedDirectory);

  // Ensure the resolved path is within the allowed directory
  if (!path.startsWith(allowed)) {
    throw ArgumentError(
      'Path traversal detected: $filePath is outside $allowedDirectory',
    );
  }

  return path;
}

/// Validates a database file name against a whitelist.
///
/// [fileName] - The file name to validate
/// [allowedNames] - List of allowed file names
///
/// Throws [ArgumentError] if file name is not in the whitelist.
void validateDatabaseFileName(String fileName, List<String> allowedNames) {
  if (!allowedNames.contains(fileName)) {
    throw ArgumentError(
      'Invalid database file name: $fileName. Must be one of: ${allowedNames.join(", ")}',
    );
  }
}
