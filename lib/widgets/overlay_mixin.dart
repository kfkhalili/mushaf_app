import 'package:flutter/material.dart';

/// WHY: Provides reusable overlay management functionality to eliminate
/// code duplication when widgets need to show and dismiss overlays.
///
/// This mixin handles the common pattern of creating, showing, and dismissing
/// overlay entries, ensuring proper cleanup in dispose().
mixin OverlayMixin<T extends StatefulWidget> on State<T> {
  OverlayEntry? _overlayEntry;

  /// Shows an overlay at the specified position.
  /// [overlayWidget] is the widget to display in the overlay.
  /// [context] is the BuildContext to get the overlay from.
  ///
  /// If an overlay is already showing, it will be dismissed first.
  void showOverlay(Widget overlayWidget, BuildContext context) {
    dismissOverlay();
    _overlayEntry = OverlayEntry(builder: (_) => overlayWidget);
    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Dismisses the current overlay if one exists.
  /// Also clears any state related to the overlay.
  void dismissOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  /// Returns whether an overlay is currently showing.
  bool get isOverlayShowing => _overlayEntry != null;

  /// WHY: Ensures overlay is cleaned up when widget is disposed.
  /// Subclasses should call super.dispose() to ensure cleanup.
  @override
  void dispose() {
    // WHY: Remove overlay when widget is disposed to prevent memory leaks.
    // Don't call dismissOverlay() as it may try to call setState() on disposed widget.
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }
}
