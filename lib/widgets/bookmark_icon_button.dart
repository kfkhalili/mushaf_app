import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../constants.dart';

class BookmarkIconButton extends ConsumerStatefulWidget {
  final int pageNumber;

  const BookmarkIconButton({super.key, required this.pageNumber});

  @override
  ConsumerState<BookmarkIconButton> createState() => _BookmarkIconButtonState();
}

class _BookmarkIconButtonState extends ConsumerState<BookmarkIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    // Capture the context-dependent properties *before* the async gap.
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final isMounted = mounted;

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    try {
      // Get first ayah on page for ayah-based bookmarking
      final dbService = await ref.read(databaseServiceProvider.future);
      final firstAyah = await dbService.getFirstAyahOnPage(widget.pageNumber);
      final surahNumber = firstAyah['surah']!;
      final ayahNumber = firstAyah['ayah']!;

      await ref
          .read(bookmarksProvider.notifier)
          .toggleAyahBookmark(surahNumber, ayahNumber);
    } catch (e) {
      // Handle error silently or show snackbar
      if (isMounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(
              'فشل حفظ العلامة المرجعية: $e',
              style: TextStyle(color: theme.colorScheme.onError),
            ),
            backgroundColor: theme.colorScheme.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncIsBookmarked = ref.watch(
      isPageBookmarkedProvider(widget.pageNumber),
    );
    final theme = Theme.of(context);
    final Color iconColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade400
        : Colors.grey.shade600;

    return asyncIsBookmarked.when(
      data: (isBookmarked) {
        final Color activeColor = theme.colorScheme.primary;
        final Icon icon = Icon(
          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          size: kAppHeaderIconSize,
          color: isBookmarked ? activeColor : iconColor,
        );

        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: IconButton(
                tooltip: isBookmarked ? 'إزالة العلامة المرجعية' : 'حفظ الصفحة',
                icon: icon,
                onPressed: _handleTap,
                color: isBookmarked ? activeColor : iconColor,
              ),
            );
          },
        );
      },
      loading: () => IconButton(
        icon: Icon(
          Icons.bookmark_border,
          size: kAppHeaderIconSize,
          color: iconColor,
        ),
        onPressed: null,
      ),
      error: (_, _) => IconButton(
        icon: Icon(
          Icons.bookmark_border,
          size: kAppHeaderIconSize,
          color: iconColor,
        ),
        onPressed: _handleTap,
      ),
    );
  }
}
