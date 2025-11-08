import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared utilities for working with AsyncValue.
///
/// These functions extract common AsyncValue patterns to maintain
/// DRY principles and ensure consistent handling across the application.

/// Extracts a string value from AsyncValue with default fallback.
///
/// This is useful for extracting titles, names, or other string values
/// from AsyncValue without duplicating the when() pattern.
///
/// Example:
/// ```dart
/// final title = extractString(
///   asyncValue,
///   (data) => data.name,
///   defaultValue: '',
/// );
/// ```
String extractString<T>(
  AsyncValue<T> asyncValue,
  String Function(T data) extractor, {
  String defaultValue = '',
}) {
  return asyncValue.when(
    data: extractor,
    loading: () => defaultValue,
    error: (_, _) => defaultValue,
  );
}

/// Extracts an integer value from AsyncValue with default fallback.
///
/// This is useful for extracting numeric values from AsyncValue
/// without duplicating the when() pattern.
///
/// Example:
/// ```dart
/// final count = extractInt(
///   asyncValue,
///   (data) => data.count,
///   defaultValue: 0,
/// );
/// ```
int extractInt<T>(
  AsyncValue<T> asyncValue,
  int Function(T data) extractor, {
  int defaultValue = 0,
}) {
  return asyncValue.when(
    data: extractor,
    loading: () => defaultValue,
    error: (_, _) => defaultValue,
  );
}

/// Extracts a boolean value from AsyncValue with default fallback.
///
/// This is useful for extracting boolean flags from AsyncValue
/// without duplicating the when() pattern.
///
/// Example:
/// ```dart
/// final isActive = extractBool(
///   asyncValue,
///   (data) => data.isActive,
///   defaultValue: false,
/// );
/// ```
bool extractBool<T>(
  AsyncValue<T> asyncValue,
  bool Function(T data) extractor, {
  bool defaultValue = false,
}) {
  return asyncValue.when(
    data: extractor,
    loading: () => defaultValue,
    error: (_, _) => defaultValue,
  );
}
