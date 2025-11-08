import 'package:flutter/material.dart';

/// Mixin that provides PageController synchronization functionality.
///
/// This mixin handles the common pattern of syncing a PageController
/// with external state (e.g., provider values) using post-frame callbacks.
///
/// WHY: Eliminates code duplication between MushafScreen and SelectionScreen
/// which both need to sync PageController with provider state.
mixin PageControllerSyncMixin<T extends StatefulWidget> on State<T> {
  /// Syncs the PageController to the target index.
  ///
  /// Uses a post-frame callback to avoid modifying the controller during build.
  /// Supports both instant (jumpToPage) and animated (animateToPage) navigation.
  ///
  /// [controller] - The PageController to sync
  /// [targetIndex] - The target page index (0-based)
  /// [animated] - Whether to animate the transition (default: false for instant)
  /// [duration] - Animation duration (only used if animated is true)
  /// [curve] - Animation curve (only used if animated is true)
  void syncPageController(
    PageController controller,
    int targetIndex, {
    bool animated = false,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    if (!controller.hasClients) return;

    final currentIndex = controller.page?.round() ?? -1;
    if (currentIndex == targetIndex) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !controller.hasClients) return;

      final currentIndex = controller.page?.round() ?? -1;
      if (currentIndex == targetIndex) return;

      if (animated) {
        controller.animateToPage(targetIndex, duration: duration, curve: curve);
      } else {
        controller.jumpToPage(targetIndex);
      }
    });
  }

  /// Syncs the PageController to the target page number (1-based).
  ///
  /// Convenience method that converts 1-based page numbers to 0-based indices.
  ///
  /// [controller] - The PageController to sync
  /// [targetPage] - The target page number (1-based)
  /// [animated] - Whether to animate the transition (default: false for instant)
  /// [duration] - Animation duration (only used if animated is true)
  /// [curve] - Animation curve (only used if animated is true)
  void syncPageControllerToPage(
    PageController controller,
    int targetPage, {
    bool animated = false,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    if (targetPage < 1) return;
    syncPageController(
      controller,
      targetPage - 1,
      animated: animated,
      duration: duration,
      curve: curve,
    );
  }
}
