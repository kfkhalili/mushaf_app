import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../utils/helpers.dart'; // For convertToEasternArabicNumerals
import '../constants.dart';

class PageListView extends StatelessWidget {
  const PageListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      // WHY: Use the named constant for total page count.
      itemCount: totalPages,
      itemBuilder: (context, index) {
        final int pageNumber = index + 1;
        return PageListItem(pageNumber: pageNumber);
      },
      separatorBuilder: (context, index) =>
          const Divider(height: 1, indent: 24, endIndent: 24),
    );
  }
}

class PageListItem extends ConsumerWidget {
  final int pageNumber;

  const PageListItem({super.key, required this.pageNumber});

  // REMOVED: _navigateToPage, now uses helper

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Watch provider for preview text.
    final pagePreviewAsync = ref.watch(pagePreviewProvider(pageNumber));
    // Watch provider for the correct font family name.
    final pageFontFamilyAsync = ref.watch(pageFontFamilyProvider(pageNumber));

    // WHY: Define common loading and error widgets.
    final loadingWidget = const SizedBox(
      width: 60,
      height: 20,
      child: LinearProgressIndicator(minHeight: 4),
    );
    final errorWidget = Icon(
      Icons.error_outline,
      color: theme.colorScheme.error,
      size: 20,
    );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      leading: Text(
        convertToEasternArabicNumerals(pageNumber.toString()),
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
      // WHY: Build the trailing widget based on the combined state of both providers.
      trailing: pagePreviewAsync.when(
        data: (previewText) {
          // WHY: Only proceed to check font if preview text is loaded.
          return pageFontFamilyAsync.when(
            data: (fontFamilyName) {
              // WHY: Only display text if BOTH text and font are successfully loaded.
              if (fontFamilyName != fallbackFontFamily) {
                return Text(
                  previewText,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontFamily: fontFamilyName, // Use the specific page font
                    fontSize: 22,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                );
              } else {
                // WHY: If the font service returned the fallback, treat it as an error/loading state for the preview.
                return loadingWidget;
              }
            },
            // WHY: Show loading indicator while the font is loading.
            loading: () => loadingWidget,
            // WHY: Show error icon if the font fails to load.
            error: (err, stack) => errorWidget,
          );
        },
        // WHY: Show loading indicator while preview text is loading.
        loading: () => loadingWidget,
        // WHY: Show error icon if preview text fails to load.
        error: (err, stack) => errorWidget,
      ),
      onTap: () {
        // WHY: Use the centralized navigation helper.
        navigateToMushafPage(context, pageNumber);
      },
    );
  }
}
