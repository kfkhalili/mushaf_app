import 'package:flutter/material.dart';
import '../constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/mushaf_screen.dart';
import '../providers.dart';

/// Navigates to MushafScreen with the specified initial page.
///
/// This centralizes navigation to MushafScreen across all list views
/// (Surah, Juz, Page) for consistency and maintainability.
///
/// [context] - BuildContext for navigation
/// [pageNumber] - The page number to navigate to (1-based)
/// [clearLastPage] - Whether to clear the 'last_page' preference before navigation
/// [ref] - WidgetRef for accessing providers (required if clearLastPage is true)
///
/// WHY: Consolidated from navigateToMushafScreen and navigateToMushafPage
/// to provide a single, consistent API with optional preference clearing.
Future<void> navigateToMushafScreen(
  BuildContext context,
  int pageNumber, {
  bool clearLastPage = false,
  WidgetRef? ref,
}) async {
  // Clear last_page preference if requested
  if (clearLastPage && ref != null) {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.remove('last_page');
  }

  // Check if context is still mounted after async gap
  if (!context.mounted) return;

  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => MushafScreen(initialPage: pageNumber),
    ),
  );
}

/// Slide direction for slide transitions.
enum SlideDirection {
  /// Slide from left to right
  fromLeft,

  /// Slide from right to left
  fromRight,
}

/// Pushes a page with a slide transition.
///
/// WHY: Consolidated from pushSlideFromLeft and pushSlideFromRight
/// to eliminate code duplication (~35 lines reduced to single function).
///
/// [context] - BuildContext for navigation
/// [page] - The widget to navigate to
/// [direction] - The direction to slide from (default: fromRight)
Future<T?> pushSlideTransition<T>(
  BuildContext context,
  Widget page, {
  SlideDirection direction = SlideDirection.fromRight,
}) {
  final begin = direction == SlideDirection.fromLeft
      ? const Offset(-1.0, 0.0)
      : const Offset(1.0, 0.0);
  const end = Offset(0.0, 0.0);
  const curve = Curves.easeInOut;

  return Navigator.of(context).push<T>(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      // When popping, reverse the animation
      reverseTransitionDuration: AppDurations.medium,
    ),
  );
}

/// Pushes a page with a slide transition from the left.
///
/// WHY: Convenience wrapper for backward compatibility.
/// Use pushSlideTransition with SlideDirection.fromLeft for new code.
@Deprecated('Use pushSlideTransition with SlideDirection.fromLeft instead')
Future<T?> pushSlideFromLeft<T>(BuildContext context, Widget page) {
  return pushSlideTransition<T>(
    context,
    page,
    direction: SlideDirection.fromLeft,
  );
}

/// Pushes a page with a slide transition from the right.
///
/// WHY: Convenience wrapper for backward compatibility.
/// Use pushSlideTransition with SlideDirection.fromRight for new code.
@Deprecated('Use pushSlideTransition with SlideDirection.fromRight instead')
Future<T?> pushSlideFromRight<T>(BuildContext context, Widget page) {
  return pushSlideTransition<T>(
    context,
    page,
    direction: SlideDirection.fromRight,
  );
}

/// Replaces the current route with a new route.
///
/// WHY: Centralizes pushReplacement navigation pattern for consistency.
///
/// [context] - BuildContext for navigation
/// [page] - The widget to navigate to
Future<void> pushReplacement(BuildContext context, Widget page) async {
  await Navigator.of(
    context,
  ).pushReplacement(MaterialPageRoute(builder: (context) => page));
}

/// Replaces the current route and then pushes a new route.
///
/// WHY: Centralizes the pushReplacement + push pattern used by SplashScreen.
///
/// [context] - BuildContext for navigation
/// [replacementPage] - The widget to replace the current route with
/// [pushedPage] - The widget to push on top of the replacement
Future<void> pushReplacementAndPush(
  BuildContext context,
  Widget replacementPage,
  Widget pushedPage,
) async {
  await Navigator.of(
    context,
  ).pushReplacement(MaterialPageRoute(builder: (context) => replacementPage));

  // Check if context is still mounted after async gap
  if (!context.mounted) return;

  await Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (context) => pushedPage));
}
