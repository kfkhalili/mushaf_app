import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart'; // WHY: Add this import to find your new providers
import '../utils/helpers.dart';
import '../utils/responsive.dart';
import '../utils/selectors.dart';
import 'mushaf_line.dart';
import '../constants.dart'; // Import constants
import '../providers/memorization_provider.dart';
import 'ayah_context_menu.dart';

class MushafPage extends ConsumerStatefulWidget {
  final int pageNumber;

  const MushafPage({super.key, required this.pageNumber});

  @override
  ConsumerState<MushafPage> createState() => _MushafPageState();
}

class _MushafPageState extends ConsumerState<MushafPage> {
  OverlayEntry? _overlayEntry;
  Offset? _tapPosition;
  String? _selectedAyahKey; // Track selected ayah for highlighting

  void _handleAyahLongPress(int surahNumber, int ayahNumber, Offset position) {
    // Dismiss previous overlay if exists
    _dismissOverlay();

    final selectedKey = generateAyahKey(surahNumber, ayahNumber);
    setState(() {
      _tapPosition = position;
      _selectedAyahKey = selectedKey;
    });

    // Create overlay entry for context menu
    _overlayEntry = OverlayEntry(
      builder: (context) => AyahContextMenu(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        tapPosition: _tapPosition ?? Offset.zero,
        onDismiss: _dismissOverlay,
      ),
    );

    // Insert overlay
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _dismissOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    setState(() {
      _tapPosition = null;
      _selectedAyahKey = null; // Clear highlight when dismissing
    });
  }

  @override
  void dispose() {
    // It's not necessary to call _dismissOverlay() here, as the overlay is tied
    // to the widget's lifecycle and will be removed when the widget is disposed.
    // Calling it here causes an error because it tries to call setState on a disposed widget.
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncPageData = ref.watch(pageDataProvider(widget.pageNumber));
    final asyncBookmarks = ref.watch(bookmarksProvider);
    final session = ref.watch(memorizationSessionProvider);
    final bool isMemorizing =
        session != null && session.pageNumber == widget.pageNumber;

    // Legacy memorization removed

    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;

    final metrics = ResponsiveMetrics.of(context);
    final footerTextStyle = TextStyle(
      fontSize: metrics.footerFontSize(16),
      color: textColor,
    );

    return asyncPageData.when(
      data: (pageData) {
        return asyncBookmarks.when(
          data: (bookmarks) {
            // Determine which ayahs on this page are bookmarked
            final pageAyahs = <String>{};
            for (final line in pageData.layout.lines) {
              for (final word in line.words) {
                if (word.ayahNumber > 0) {
                  pageAyahs.add(
                    generateAyahKey(word.surahNumber, word.ayahNumber),
                  );
                }
              }
            }

            final allBookmarkedKeys = bookmarks
                .map((b) => generateAyahKey(b.surahNumber, b.ayahNumber))
                .toSet();
            final bookmarkedAyahKeysOnPage = pageAyahs.intersection(
              allBookmarkedKeys,
            );

            final visibility = computeMemorizationVisibility(
              pageData.layout,
              isMemorizing ? session : null,
            );

            final pageNum = convertToEasternArabicNumerals(
              widget.pageNumber.toString(),
            );

            return Scaffold(
              body: GestureDetector(
                onTap: _dismissOverlay, // Dismiss overlay on tap outside
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Padding(
                      padding: metrics.pagePadding(top: 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: pageData.layout.lines.map((line) {
                          return MushafLine(
                            line: line,
                            pageFontFamily: pageData.pageFontFamily,
                            isMemorizationMode: isMemorizing,
                            wordsToShow: visibility.visibleWords,
                            ayahOpacities: visibility.ayahOpacity,
                            onAyahLongPress: _handleAyahLongPress,
                            selectedAyahKey:
                                _selectedAyahKey, // Pass selected ayah for highlighting
                            bookmarkedAyahKeys: bookmarkedAyahKeysOnPage,
                          );
                        }).toList(),
                      ),
                    ),
                    Align(
                      alignment: (widget.pageNumber % 2 != 0)
                          ? Alignment.bottomRight
                          : Alignment.bottomLeft,
                      child: Padding(
                        padding: metrics.footerPadding(),
                        child: Text(pageNum, style: footerTextStyle),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (err, stack) => Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(pageHorizontalPadding),
                child: Text(
                  'فشل تحميل الإشارات المرجعية.\n\nخطأ: $err',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(pageHorizontalPadding),
            child: Text(
              'فشل تحميل الصفحة ${convertToEasternArabicNumerals(widget.pageNumber.toString())}.\n\nخطأ: $err',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ),
      ),
    );
  }
}
