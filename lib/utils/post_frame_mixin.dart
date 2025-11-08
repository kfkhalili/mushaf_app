import 'package:flutter/material.dart';

/// Utility class that provides post-frame callback functionality.
///
/// This class handles the common pattern of executing code after the current
/// frame is built, which is useful for initialization, focus management,
/// and synchronization tasks.
///
/// WHY: Eliminates code duplication across multiple screens and widgets
/// that need to execute code after the frame is built.
///
/// Works with both State and ConsumerState since both have the mounted property.
class PostFrameMixin {
  /// Executes a callback after the current frame is built.
  ///
  /// This is useful for:
  /// - Requesting focus on input fields
  /// - Initializing state after build
  /// - Synchronizing with external state
  ///
  /// [state] - The State object (for checking mounted property)
  /// [callback] - The callback to execute after the frame is built
  /// [checkMounted] - Whether to check if the widget is still mounted before executing (default: true)
  static void runAfterFrame(
    State state,
    VoidCallback callback, {
    bool checkMounted = true,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (checkMounted && !state.mounted) return;
      callback();
    });
  }

  /// Executes a callback after the current frame is built with a delay.
  ///
  /// This is useful for:
  /// - Deferring initialization
  /// - Waiting for animations to complete
  /// - Staggering multiple operations
  ///
  /// [state] - The State object (for checking mounted property)
  /// [callback] - The callback to execute after the frame and delay
  /// [delay] - The delay after the frame is built (default: Duration.zero)
  /// [checkMounted] - Whether to check if the widget is still mounted before executing (default: true)
  static void runAfterFrameWithDelay(
    State state,
    VoidCallback callback, {
    Duration delay = Duration.zero,
    bool checkMounted = true,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (delay > Duration.zero) {
        await Future.delayed(delay);
      }
      if (checkMounted && !state.mounted) return;
      callback();
    });
  }
}
