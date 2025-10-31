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
                // Left: Chevron icon (subtle navigation indicator)
                Icon(
                  Icons.chevron_left,
                  size: 24,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                ),
                // Center: Right-aligned content (primary)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    textDirection: TextDirection.rtl,
                    children: [
                      // Page number with bookmark icon inline
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        textDirection: TextDirection.rtl,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'الصفحة ${convertToEasternArabicNumerals(bookmark.pageNumber.toString())}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.bookmark,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Surah name
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
                              textAlign: TextAlign.right,
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
                      const SizedBox(height: 4),
                      // Meta info: Date • Juz
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        textDirection: TextDirection.rtl,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formatRelativeDate(bookmark.createdAt),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.6),
                            ),
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                          ),
                          pageDataAsync.when(
                            data: (pageData) {
                              final juzGlyph =
                                  'juz${pageData.juzNumber.toString().padLeft(3, '0')}';
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                textDirection: TextDirection.rtl,
                                children: [
                                  Text(
                                    ' • ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withValues(alpha: 0.6),
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  Text(
                                    juzGlyph,
                                    style: TextStyle(
                                      fontFamily: quranCommonFontFamily,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: theme.textTheme.bodySmall?.color
                                          ?.withValues(alpha: 0.6),
                                    ),
                                    textDirection: TextDirection.rtl,
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

