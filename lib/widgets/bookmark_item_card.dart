import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models.dart';
import '../providers.dart';
import '../utils/helpers.dart';
import '../constants.dart';

class BookmarkItemCard extends ConsumerWidget {
  final Bookmark bookmark;

  const BookmarkItemCard({
    super.key,
    required this.bookmark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pageDataAsync = ref.watch(pageDataProvider(bookmark.pageNumber));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Dismissible(
        key: Key('bookmark-${bookmark.id}'),
        direction: DismissDirection.endToStart, // Swipe right to delete (RTL)
        background: Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: theme.colorScheme.error,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.only(left: 20),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 28,
          ),
        ),
        confirmDismiss: (direction) async {
          // Optional: show confirmation dialog here
          return true;
        },
        onDismissed: (direction) {
          ref.read(bookmarksProvider.notifier).removeBookmark(bookmark.pageNumber);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف العلامة المرجعية'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: InkWell(
          onTap: () {
            navigateToMushafPage(context, bookmark.pageNumber);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                // Right side: Page number and Surah name (primary content)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    textDirection: TextDirection.rtl,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        textDirection: TextDirection.rtl,
                        children: [
                          Text(
                            'الصفحة ${convertToEasternArabicNumerals(bookmark.pageNumber.toString())}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.book, size: 20),
                        ],
                      ),
                      const SizedBox(height: 4),
                      pageDataAsync.when(
                        data: (pageData) {
                          if (pageData.pageSurahNumber > 0) {
                            final surahNumPadded =
                                pageData.pageSurahNumber.toString().padLeft(3, '0');
                            final surahNameGlyph =
                                'surah$surahNumPadded surah-icon';
                            return Text(
                              surahNameGlyph,
                              style: TextStyle(
                                fontFamily: surahNameFontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                              textDirection: TextDirection.rtl,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        loading: () => const SizedBox(
                          width: 60,
                          height: 16,
                          child: LinearProgressIndicator(minHeight: 2),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                // Left side: Juz glyph and date (meta info)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  textDirection: TextDirection.rtl,
                  children: [
                    pageDataAsync.when(
                      data: (pageData) {
                        final juzGlyph =
                            'juz${pageData.juzNumber.toString().padLeft(3, '0')}';
                        return Text(
                          juzGlyph,
                          style: TextStyle(
                            fontFamily: quranCommonFontFamily,
                            fontSize: 14,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.6),
                          ),
                          textDirection: TextDirection.rtl,
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatRelativeDate(bookmark.createdAt),
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color
                            ?.withValues(alpha: 0.6),
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
                // Chevron icon
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

