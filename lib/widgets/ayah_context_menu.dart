import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../screens/topic_detail_screen.dart';

/// Context menu widget that appears after long-press on an ayah
class AyahContextMenu extends ConsumerWidget {
  final int surahNumber;
  final int ayahNumber;
  final Offset tapPosition;
  final VoidCallback onDismiss;

  const AyahContextMenu({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
    required this.tapPosition,
    required this.onDismiss,
  });

  Future<void> _handleBookmark(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(bookmarksProvider.notifier)
          .toggleAyahBookmark(surahNumber, ayahNumber);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الآية'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      onDismiss();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حفظ العلامة المرجعية: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _handleRemoveBookmark(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      await ref
          .read(bookmarksProvider.notifier)
          .removeBookmark(surahNumber, ayahNumber);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف العلامة المرجعية'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      onDismiss();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حذف العلامة المرجعية: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isBookmarkedAsync = ref.watch(
      isAyahBookmarkedProvider(surahNumber, ayahNumber),
    );

    // Watch topics for this ayah
    final topicsAsync = ref.watch(
      topicsForAyahProvider(surahNumber, ayahNumber),
    );

    return Stack(
      children: [
        // Dismissible overlay - tap outside to close
        GestureDetector(
          onTap: onDismiss,
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        // Context menu positioned near tap location
        Positioned(
          top: tapPosition.dy,
          right: tapPosition.dx,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            color: theme.cardColor,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bookmark section
                    isBookmarkedAsync.when(
                      data: (isBookmarked) => InkWell(
                        onTap: () {
                          // Prevent overlay dismissal by stopping event propagation
                          if (isBookmarked) {
                            _handleRemoveBookmark(context, ref);
                          } else {
                            _handleBookmark(context, ref);
                          }
                        },
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            textDirection: TextDirection.rtl,
                            children: [
                              Icon(
                                isBookmarked
                                    ? Icons.bookmark_remove
                                    : Icons.bookmark,
                                size: 20,
                                color: isBookmarked
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isBookmarked
                                    ? 'إزالة العلامة المرجعية'
                                    : 'أضف إشارة مرجعية',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isBookmarked
                                      ? theme.colorScheme.error
                                      : theme.textTheme.bodyLarge?.color,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                          ),
                        ),
                      ),
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      error: (_, _) => const SizedBox.shrink(),
                    ),

                    // Related Topics Section
                    topicsAsync.when(
                      data: (topics) {
                        // Filter out topics without Arabic names
                        final topicsWithArabic = topics
                            .where((t) => t.arabicName.isNotEmpty)
                            .toList();

                        if (topicsWithArabic.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16.0,
                                16.0,
                                16.0,
                                8.0,
                              ),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'المواضيع ذات الصلة',
                                  style: theme.textTheme.titleSmall,
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16.0,
                                0,
                                16.0,
                                16.0,
                              ),
                              child: Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                alignment: WrapAlignment.end,
                                children: topicsWithArabic.map((topic) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop(); // Close menu
                                      if (context.mounted) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TopicDetailScreen(
                                                  topicId: topic.topicId,
                                                ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Chip(
                                      label: Text(
                                        topic.arabicName,
                                        textDirection: TextDirection.rtl,
                                      ),
                                      onDeleted: null,
                                      deleteIcon: null,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      error: (error, stack) {
                        if (kDebugMode) {
                          debugPrint(
                            'AyahContextMenu topics error: $error\n$stack',
                          );
                        }
                        // Show error in UI instead of hiding it
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'خطأ في تحميل المواضيع',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
