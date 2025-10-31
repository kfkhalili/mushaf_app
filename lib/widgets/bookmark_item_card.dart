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
        direction: DismissDirection.endToStart, // Swipe right to delete (RTL)
        background: Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: theme.colorScheme.error,
            borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: Left-aligned content (primary)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.rtl,
                    children: [
                      // 1st line: Bookmark icon → page number
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        textDirection: TextDirection.rtl,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bookmark,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'الصفحة ${convertToEasternArabicNumerals(bookmark.pageNumber.toString())}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // 2nd line: Surah name glyph (large) → Juz name glyph
                      pageDataAsync.when(
                        data: (pageData) {
                          final surahNumPadded =
                              pageData.pageSurahNumber.toString().padLeft(3, '0');
                          final surahNameGlyph =
                              'surah$surahNumPadded surah-icon';
                          final juzGlyph =
                              'juz${pageData.juzNumber.toString().padLeft(3, '0')}';

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            textDirection: TextDirection.rtl,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (pageData.pageSurahNumber > 0)
                                Text(
                                  surahNameGlyph,
                                  style: TextStyle(
                                    fontFamily: surahNameFontFamily,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w400,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.left,
                                ),
                              if (pageData.pageSurahNumber > 0 && pageData.juzNumber > 0)
                                const SizedBox(width: 8),
                              if (pageData.juzNumber > 0)
                                Text(
                                  juzGlyph,
                                  style: TextStyle(
                                    fontFamily: quranCommonFontFamily,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w400,
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.left,
                                ),
                            ],
                          );
                        },
                        loading: () => const SizedBox(
                          width: 60,
                          height: 28,
                          child: LinearProgressIndicator(minHeight: 2),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 4),
                      // 3rd line: Date
                      Text(
                        formatRelativeDate(bookmark.createdAt),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.6),
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                // Right: Chevron icon (subtle navigation indicator)
                Icon(
                  Icons.chevron_right,
                  size: 24,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

