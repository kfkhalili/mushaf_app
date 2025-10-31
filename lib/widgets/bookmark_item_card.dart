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
    try {
      final pageNumberProvider = bookmarkPageNumberProvider(
        bookmark.surahNumber,
        bookmark.ayahNumber,
      );
      final pageNumberAsync = ref.read(pageNumberProvider);
      pageNumberAsync.when(
        data: (pageNumber) {
          if (pageNumber != null) {
            navigateToMushafPage(context, pageNumber);
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('لا يمكن العثور على الصفحة'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        loading: () {},
        error: (error, stack) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('لا يمكن العثور على الصفحة: $error'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('لا يمكن العثور على الصفحة: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    await ref
        .read(bookmarksProvider.notifier)
        .removeBookmark(bookmark.surahNumber, bookmark.ayahNumber);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
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
    final surahNumEastern = convertToEasternArabicNumerals(verseRefParts[0]);
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
