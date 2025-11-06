import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../utils/helpers.dart'; // For convertToEasternArabicNumerals
import 'shared/leading_number_text.dart';

class PageListView extends ConsumerStatefulWidget {
  const PageListView({super.key});

  @override
  ConsumerState<PageListView> createState() => _PageListViewState();
}

class _PageListViewState extends ConsumerState<PageListView> {
  @override
  Widget build(BuildContext context) {
    final totalPagesAsync = ref.watch(totalPagesProvider);

    return totalPagesAsync.when(
      data: (totalPages) => ListView.separated(
        // WHY: Use the total pages from the database for the current layout.
        itemCount: totalPages,
        itemBuilder: (context, index) {
          final int pageNumber = index + 1;
          return PageListItem(pageNumber: pageNumber);
        },
        separatorBuilder: (index, _) =>
            const Divider(height: 1, indent: 24, endIndent: 24),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading pages: $error')),
    );
  }
}

class PageListItem extends ConsumerWidget {
  final int pageNumber;

  const PageListItem({super.key, required this.pageNumber});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pagePreviewWithFontAsync = ref.watch(
      pagePreviewWithFontProvider(pageNumber),
    );

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
      trailing: LeadingNumberText(number: pageNumber),
      leading: pagePreviewWithFontAsync.when(
        data: (combined) {
          final (previewText, fontFamilyName) = combined;
          return Text(
            previewText.isEmpty ? '…' : previewText,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: fontFamilyName,
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
        // Capture Navigator and mounted state before async gap
        final navigator = Navigator.of(context);
        final isMounted = context.mounted;
        navigateToMushafPage(navigator, isMounted, pageNumber, ref);
      },
    );
  }
}
