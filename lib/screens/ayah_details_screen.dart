import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:async';
import 'dart:math' as math;
import '../providers.dart';
import '../screens/topic_detail_screen.dart';
import '../utils/helpers.dart';
import '../utils/navigation.dart';
import '../constants.dart';

/// Screen showing detailed information about a specific ayah
class AyahDetailsScreen extends ConsumerStatefulWidget {
  final int surahNumber;
  final int ayahNumber;

  const AyahDetailsScreen({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
  });

  @override
  ConsumerState<AyahDetailsScreen> createState() => _AyahDetailsScreenState();
}

class _AyahDetailsScreenState extends ConsumerState<AyahDetailsScreen> {
  late PageController _pageController;
  Timer? _navigationTimer;
  int? _pendingNavigationIndex;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChange(int pageIndex) {
    // pageIndex: 0 = previous, 1 = current, 2 = next
    if (pageIndex == 1) {
      // User swiped back to center - cancel any pending navigation
      _navigationTimer?.cancel();
      _pendingNavigationIndex = null;
      return;
    }

    // User swiped to edge (index 0 or 2) - wait a bit before navigating
    // This allows them to swipe back if they change their mind
    _navigationTimer?.cancel();
    _pendingNavigationIndex = pageIndex;
    _navigationTimer = Timer(const Duration(milliseconds: 400), () {
      // Only navigate if still on the same page and widget is mounted
      if (!mounted || _pendingNavigationIndex != pageIndex) return;

      if (pageIndex == 0) {
        // Navigate to previous
        final previousAyahAsync = ref.read(
          previousAyahProvider(widget.surahNumber, widget.ayahNumber),
        );
        previousAyahAsync.whenData((previousAyah) {
          if (previousAyah != null && mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    AyahDetailsScreen(
                      surahNumber: previousAyah.surahNumber,
                      ayahNumber: previousAyah.ayahNumber,
                    ),
                transitionDuration: Duration.zero, // No animation
                reverseTransitionDuration: Duration.zero, // No animation
              ),
            );
          }
        });
      } else if (pageIndex == 2) {
        // Navigate to next
        final nextAyahAsync = ref.read(
          nextAyahProvider(widget.surahNumber, widget.ayahNumber),
        );
        nextAyahAsync.whenData((nextAyah) {
          if (nextAyah != null && mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    AyahDetailsScreen(
                      surahNumber: nextAyah.surahNumber,
                      ayahNumber: nextAyah.ayahNumber,
                    ),
                transitionDuration: Duration.zero, // No animation
                reverseTransitionDuration: Duration.zero, // No animation
              ),
            );
          }
        });
      }
    });
  }

  /// Builds the ayah content for a specific surah and ayah
  Widget _buildAyahContent(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    int surahNum,
    int ayahNum,
  ) {
    // Get ayah display data (words, page number, font)
    final ayahDisplayAsync = ref.watch(
      ayahDisplayDataProvider(surahNum, ayahNum),
    );

    // Get tafsir for this ayah
    final tafsirAsync = ref.watch(tafsirProvider(surahNum, ayahNum));

    // Get topics for this ayah
    final topicsAsync = ref.watch(topicsForAyahProvider(surahNum, ayahNum));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: [
          // Ayah text section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ayahDisplayAsync.when(
                data: (displayData) {
                  final words = displayData.words;
                  final fontFamily = displayData.fontFamily;

                  if (words.isEmpty) {
                    return Text(
                      'لا يوجد نص للآية',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      textDirection: TextDirection.rtl,
                    );
                  }

                  // Calculate responsive font size like mushaf screen
                  final screenWidth = MediaQuery.of(context).size.width;
                  final screenHeight = MediaQuery.of(context).size.height;
                  final widthScale = screenWidth / referenceScreenWidth;
                  final heightScale = screenHeight / referenceScreenHeight;
                  final scaleFactor = math.min(widthScale, heightScale);

                  final userFontSize = ref.watch(fontSizeSettingProvider);
                  // WHY: Use larger font size for ayah details screen (1.5x multiplier)
                  final unclampedDynamicFontSize =
                      userFontSize * scaleFactor * 1.5;
                  final fontSize = unclampedDynamicFontSize.clamp(
                    minAyahFontSize,
                    maxAyahFontSize,
                  );

                  final layout = ref.watch(mushafLayoutSettingProvider);
                  final lineHeight =
                      layoutLineHeights[layout] ?? baseLineHeight;

                  final baseTextColor =
                      theme.textTheme.bodyLarge?.color ?? Colors.black;

                  // Display words as individual widgets in a Wrap, allowing wrapping to next line
                  // WHY: Wrap allows words to flow to next line when they don't fit, preventing overflow
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      alignment: WrapAlignment.start,
                      textDirection: TextDirection.rtl,
                      children: words.map((word) {
                        return Text(
                          word.text,
                          style: TextStyle(
                            fontFamily: fontFamily,
                            fontSize: fontSize,
                            height: lineHeight,
                            color: baseTextColor,
                          ),
                          textScaler: const TextScaler.linear(1.0),
                        );
                      }).toList(),
                    ),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, stack) {
                  if (kDebugMode) {
                    debugPrint('Error loading ayah display: $error\n$stack');
                  }
                  return Text(
                    'خطأ في تحميل نص الآية',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textDirection: TextDirection.rtl,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Tafsir Section
          tafsirAsync.when(
            data: (tafsirText) {
              if (tafsirText == null || tafsirText.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    'التفسير الميسر',
                    style: theme.textTheme.titleLarge,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Html(
                          data: tafsirText,
                          style: {
                            'body': Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                              fontSize: FontSize(16),
                              lineHeight: const LineHeight(1.8),
                              color:
                                  theme.textTheme.bodyLarge?.color ??
                                  Colors.black,
                            ),
                            'p': Style(
                              margin: Margins.only(bottom: 12),
                              padding: HtmlPaddings.zero,
                              textAlign: TextAlign.justify,
                            ),
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (error, stack) {
              if (kDebugMode) {
                debugPrint('Error loading tafsir: $error\n$stack');
              }
              return const SizedBox.shrink();
            },
          ),

          // Related Topics Section
          Text(
            'المواضيع ذات الصلة',
            style: theme.textTheme.titleLarge,
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 16),
          topicsAsync.when(
            data: (topics) {
              // Filter out topics without Arabic names
              final topicsWithArabic = topics
                  .where((t) => t.arabicName.isNotEmpty)
                  .toList();

              if (topicsWithArabic.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'لا توجد مواضيع مرتبطة بهذه الآية',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.start,
                textDirection: TextDirection.rtl,
                children: topicsWithArabic.map((topic) {
                  return InkWell(
                    onTap: () {
                      pushSlideFromRight(
                        context,
                        TopicDetailScreen(topicId: topic.topicId),
                      );
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
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (error, stack) {
              if (kDebugMode) {
                debugPrint('Error loading topics: $error\n$stack');
              }
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'خطأ في تحميل المواضيع',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get surah name
    final surahNameAsync = ref.watch(surahNameProvider(widget.surahNumber));

    // Get next/previous ayah for navigation
    final previousAyahAsync = ref.watch(
      previousAyahProvider(widget.surahNumber, widget.ayahNumber),
    );
    final nextAyahAsync = ref.watch(
      nextAyahProvider(widget.surahNumber, widget.ayahNumber),
    );

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar-like header for RTL
              Container(
                height: kToolbarHeight,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    // Back button on the right (first in RTL Row)
                    IconButton(
                      icon: Directionality(
                        textDirection: TextDirection.ltr,
                        child: const Icon(Icons.arrow_forward_ios),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    // Title
                    Expanded(
                      child: Text(
                        surahNameAsync.when(
                          data: (name) =>
                              '$name - آية ${convertToEasternArabicNumerals(widget.ayahNumber.toString())}',
                          loading: () =>
                              'آية ${convertToEasternArabicNumerals(widget.ayahNumber.toString())}',
                          error: (error, stack) =>
                              'آية ${convertToEasternArabicNumerals(widget.ayahNumber.toString())}',
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
              ),
              // PageView content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  reverse: true, // Reverse swipe direction for RTL
                  onPageChanged: (pageIndex) {
                    // Handle page change after swipe animation completes
                    _handlePageChange(pageIndex);
                  },
                  itemBuilder: (context, index) {
                    // index: 0 = previous (left), 1 = current (center), 2 = next (right)
                    if (index == 0) {
                      // Previous ayah preview (on the left)
                      return previousAyahAsync.when(
                        data: (previousAyah) {
                          if (previousAyah == null) {
                            return const SizedBox.shrink();
                          }
                          return _buildAyahContent(
                            context,
                            ref,
                            theme,
                            previousAyah.surahNumber,
                            previousAyah.ayahNumber,
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => const SizedBox.shrink(),
                      );
                    } else if (index == 1) {
                      // Current ayah (in the center)
                      return _buildAyahContent(
                        context,
                        ref,
                        theme,
                        widget.surahNumber,
                        widget.ayahNumber,
                      );
                    } else {
                      // Next ayah preview (on the right)
                      return nextAyahAsync.when(
                        data: (nextAyah) {
                          if (nextAyah == null) {
                            return const SizedBox.shrink();
                          }
                          return _buildAyahContent(
                            context,
                            ref,
                            theme,
                            nextAyah.surahNumber,
                            nextAyah.ayahNumber,
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => const SizedBox.shrink(),
                      );
                    }
                  },
                  itemCount: 3, // previous, current, next
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
