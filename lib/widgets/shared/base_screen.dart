import 'package:flutter/material.dart';
import 'app_header.dart';

/// Base screen widget that provides consistent scaffold structure for all screens.
///
/// This widget encapsulates the common pattern used across all screens:
/// - Directionality (RTL)
/// - SafeArea
/// - AppHeader
/// - Expanded body content
///
/// This ensures consistency and reduces duplication across all 11 screens.
class BaseScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onBookmarkPressed;
  final VoidCallback? onExplorePressed;
  final bool showBackButton;
  final Widget? trailing;
  final bool titleOnRight;
  final bool isSelectionScreen;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const BaseScreen({
    super.key,
    required this.title,
    required this.body,
    this.onSearchPressed,
    this.onBookmarkPressed,
    this.onExplorePressed,
    this.showBackButton = false,
    this.trailing,
    this.titleOnRight = false,
    this.isSelectionScreen = false,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              AppHeader(
                title: title,
                onSearchPressed: onSearchPressed,
                onBookmarkPressed: onBookmarkPressed,
                onExplorePressed: onExplorePressed,
                showBackButton: showBackButton,
                trailing: trailing,
                titleOnRight: titleOnRight,
                isSelectionScreen: isSelectionScreen,
              ),
              Expanded(child: body),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
