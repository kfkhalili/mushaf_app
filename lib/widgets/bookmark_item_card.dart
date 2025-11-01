import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models.dart';
import '../providers.dart';
import '../utils/helpers.dart';
import '../constants.dart';

class BookmarkItemCard extends ConsumerWidget {
  final Bookmark bookmark;

  const BookmarkItemCard({super.key, required this.bookmark});

  Future<void> _handleTap(BuildContext context, WidgetRef ref) async {
    dev.log(
      "BookmarkItemCard: _handleTap START for s:${bookmark.surahNumber} a:${bookmark.ayahNumber}",
      name: "BOOKMARK_TAP",
    );
    // Show a brief loading message
    // Capture context-dependent values BEFORE async gap
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final isMounted = context.mounted;

    messenger.showSnackBar(
      const SnackBar(
        content: Text('...جاري الفتح'),
        duration: Duration(milliseconds: 1000),
      ),
    );

    try {
      dev.log("BookmarkItemCard: Awaiting page number", name: "BOOKMARK_TAP");
      final pageNumber = await ref.read(
        bookmarkPageNumberProvider(
          bookmark.surahNumber,
          bookmark.ayahNumber,
        ).future,
      );
      dev.log(
        "BookmarkItemCard: Page number received: $pageNumber",
        name: "BOOKMARK_TAP",
      );

      // Hide the loading snackbar once we have a result
      messenger.hideCurrentSnackBar();

      if (!isMounted) {
        dev.log(
          "BookmarkItemCard: Widget is unmounted, aborting navigation.",
          name: "BOOKMARK_TAP",
        );
        return;
      }

      if (pageNumber != null) {
        dev.log(
          "BookmarkItemCard: Navigating to page $pageNumber",
          name: "BOOKMARK_TAP",
        );
        navigateToMushafPage(navigator, isMounted, pageNumber);
      } else {
        dev.log(
          "BookmarkItemCard: Page number is null, showing error.",
          name: "BOOKMARK_TAP",
        );
        messenger.showSnackBar(
          const SnackBar(
            content: Text('لا يمكن العثور على الصفحة لهذا المصحف'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, s) {
      dev.log(
        "BookmarkItemCard: ERROR in _handleTap",
        name: "BOOKMARK_TAP",
        error: e,
        stackTrace: s,
      );
      if (!isMounted) {
        dev.log(
          "BookmarkItemCard: Widget is unmounted, not showing error snackbar.",
          name: "BOOKMARK_TAP",
        );
        return;
      }
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('خطأ في العثور على الصفحة: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    // Capture context before async gap to prevent crash if widget is disposed.
    final messenger = ScaffoldMessenger.of(context);
    final isMounted = context.mounted;

    await ref
        .read(bookmarksProvider.notifier)
        .removeBookmark(bookmark.surahNumber, bookmark.ayahNumber);

    if (isMounted) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('تم حذف العلامة المرجعية'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final verseRefParts = bookmark.verseReference.split(':');
    final ayahNumEastern = convertToEasternArabicNumerals(verseRefParts[1]);
    final verseReference = 'الآية $ayahNumEastern';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Dismissible(
        key: Key('bookmark-${bookmark.id}'),
        direction: DismissDirection.startToEnd,
        background: Container(
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
            color: theme.colorScheme.error,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 28,
          ),
        ),
        onDismissed: (direction) => _handleDelete(context, ref),
        child: InkWell(
          onTap: () => _handleTap(context, ref),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: IntrinsicHeight(
              child: Row(
                textDirection: TextDirection.rtl,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bookmark,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            Builder(
                              builder: (context) {
                                final surahNumPadded = bookmark.surahNumber
                                    .toString()
                                    .padLeft(3, '0');
                                final surahNameGlyph =
                                    'surah$surahNumPadded surah-icon';
                                return Text(
                                  surahNameGlyph,
                                  style: TextStyle(
                                    fontFamily: surahNameFontFamily,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w500,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          verseReference,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        if (bookmark.ayahText != null &&
                            bookmark.ayahText!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            bookmark.ayahText!,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'IBMPlexSansArabic',
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.chevron_right,
                        size: 24,
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      Text(
                        formatRelativeDate(bookmark.createdAt),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
