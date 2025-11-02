import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../screens/ayah_details_screen.dart';

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

  Future<void> _handleAyahDetails(BuildContext context, WidgetRef ref) async {
    onDismiss();
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AyahDetailsScreen(
            surahNumber: surahNumber,
            ayahNumber: ayahNumber,
          ),
        ),
      );
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

                    // Ayah Details Section
                    Divider(height: 1),
                    InkWell(
                      onTap: () {
                        _handleAyahDetails(context, ref);
                      },
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
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
                              Icons.info_outline,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'تفصيل الآية',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ),
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
