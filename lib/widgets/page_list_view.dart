import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart'; // WHY: Add this import to find your new providers
import '../utils/helpers.dart'; // For convertToEasternArabicNumerals
import '../constants.dart';
import 'shared/leading_number_text.dart'; // WHY: Import the new reusable widget

class PageListView extends ConsumerStatefulWidget {
  const PageListView({super.key});

  @override
  ConsumerState<PageListView> createState() => _PageListViewState();
}

class _PageListViewState extends ConsumerState<PageListView> {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Use pageData to get both layout (for preview text) and font family.
    final pageDataAsync = ref.watch(pageDataProvider(pageNumber));

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
      // WHY: Use the new reusable LeadingNumberText widget.
      leading: LeadingNumberText(number: pageNumber),
      // Build trailing preview using pageData (font + layout-derived preview text).
      trailing: pageDataAsync.when(
        data: (pageData) {
          // Derive preview text from first ayah words on the page.
          String previewText = '';
          int remaining = 3;
          for (final line in pageData.layout.lines) {
            if (line.lineType == 'ayah' && remaining > 0) {
              for (final word in line.words) {
                if (word.ayahNumber > 0) {
                  if (previewText.isNotEmpty) previewText += ' ';
                  previewText += word.text;
                  remaining -= 1;
                  if (remaining == 0) break;
                }
              }
            }
            if (remaining == 0) break;
          }
          if (previewText.isEmpty) {
            previewText = '…';
          }

          return Text(
            previewText,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: pageData.pageFontFamily,
              fontSize: 22,
              color: theme.textTheme.bodyLarge?.color,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          );
        },
        loading: () => loadingWidget,
        error: (err, stack) => errorWidget,
      ),
      onTap: () {
        // WHY: Use the centralized navigation helper.
        navigateToMushafPage(context, pageNumber);
      },
    );
  }
}
