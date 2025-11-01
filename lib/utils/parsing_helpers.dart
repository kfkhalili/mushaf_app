// WHY: Shared utility for parsing dynamic values from database queries.
//
// This eliminates code duplication and ensures consistent parsing behavior
// across all services that need to parse integers from database results.
//
// Database query results return dynamic types, so we need a safe way to
// parse them to integers. This utility provides a consistent, safe parsing
// function that handles null values, type checking, and parsing errors.

/// Safely parses an integer from a dynamic value.
///
/// Returns 0 if value is null or cannot be parsed.
///
/// Handles multiple input types:
/// - `null` → 0
/// - `int` → returns as-is
/// - `String` → parses string to int, returns 0 on failure
/// - Other types → converts to string then parses, returns 0 on failure
int parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return int.tryParse(value.toString()) ?? 0;
}
