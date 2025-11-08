import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/error_helpers.dart';

/// A reusable widget for building UI from AsyncValue.
///
/// This widget reduces boilerplate by providing consistent handling of
/// loading, error, and data states across the application.
///
/// Extracted to maintain DRY principles and ensure consistent error handling.
class AsyncValueBuilder<T> extends StatelessWidget {
  final AsyncValue<T> asyncValue;
  final Widget Function(BuildContext context, T data) builder;
  final Widget? loading;
  final Widget Function(BuildContext context, Object error, StackTrace stack)?
  error;
  final Widget? empty;

  const AsyncValueBuilder({
    super.key,
    required this.asyncValue,
    required this.builder,
    this.loading,
    this.error,
    this.empty,
  });

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      data: (data) {
        // Handle empty data if empty widget is provided
        if (empty != null && _isEmpty(data)) {
          return empty!;
        }
        return builder(context, data);
      },
      loading: () =>
          loading ?? const Center(child: CircularProgressIndicator()),
      error: (err, stack) {
        if (error != null) {
          return error!(context, err, stack);
        }
        // Default error widget
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('حدث خطأ', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  getUserFriendlyErrorMessage(err),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Checks if data is empty (for lists, strings, etc.)
  bool _isEmpty(T data) {
    if (data is List) {
      return data.isEmpty;
    }
    if (data is String) {
      return data.isEmpty;
    }
    if (data is Map) {
      return data.isEmpty;
    }
    return false;
  }

  // Removed _getUserFriendlyError - use getUserFriendlyErrorMessage from error_helpers.dart
}
