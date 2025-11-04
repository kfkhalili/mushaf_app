import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ontology_models.dart';
import '../providers.dart';
import '../widgets/shared/app_header.dart';
import 'mushaf_screen.dart';
import '../exceptions/database_exceptions.dart';

class TopicDetailScreen extends ConsumerStatefulWidget {
  final int topicId;

  const TopicDetailScreen({super.key, required this.topicId});

  @override
  ConsumerState<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends ConsumerState<TopicDetailScreen> {
  Map<int, List<VerseReference>>? _versesBySurah;

  /// Strips HTML tags from description text for iOS display.
  /// Removes all HTML tags including b, span, topic, etc.
  /// This is an iOS app, so we display plain text only.
  String _stripHtmlTags(String html) {
    // Remove HTML tags using regex
    return html
        .replaceAll(RegExp(r'<[^>]*>', multiLine: true), '')
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .trim();
  }

  Map<int, List<VerseReference>> _groupVersesBySurah(
    List<VerseReference> verses,
  ) {
    final Map<int, List<VerseReference>> grouped = {};
    for (final verse in verses) {
      grouped.putIfAbsent(verse.surahNumber, () => []).add(verse);
    }
    return grouped;
  }

  Future<void> _navigateToAyah(
    BuildContext context,
    WidgetRef ref,
    int surahNumber,
    int ayahNumber,
  ) async {
    try {
      // Get page number for this ayah
      final dbService = await ref.read(databaseServiceProvider.future);
      final pageNumber = await dbService.getPageForAyah(
        surahNumber,
        ayahNumber,
      );

      if (!context.mounted) return;

      // Push MushafScreen directly to maintain navigation stack
      // This allows back button to return to TopicDetailScreen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MushafScreen(initialPage: pageNumber),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ في العثور على الصفحة: ${_getUserFriendlyErrorMessage(e)}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topicAsync = ref.watch(topicByIdProvider(widget.topicId));
    final versesAsync = ref.watch(versesForTopicProvider(widget.topicId));
    final relatedTopicsAsync = ref.watch(relatedTopicsProvider(widget.topicId));

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              AppHeader(
                title: topicAsync.when(
                  data: (topic) => topic.arabicName,
                  loading: () => '',
                  error: (_, _) => '',
                ),
                showBackButton: true,
              ),
              Expanded(
                child: topicAsync.when(
                  data: (topic) {
                    // WHY: Only show topic if it has verses
                    return versesAsync.when(
                      data: (verses) {
                        // If no verses, don't show the topic
                        if (verses.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد آيات مرتبطة بهذا الموضوع',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                  textDirection: TextDirection.rtl,
                                ),
                              ],
                            ),
                          );
                        }

                        // Group verses by surah when data loads
                        if (_versesBySurah == null) {
                          setState(() {
                            _versesBySurah = _groupVersesBySurah(verses);
                          });
                        }

                        return ListView(
                          padding: const EdgeInsets.all(16.0),
                          children: [
                            // Description Section
                            if (topic.description != null) ...[
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'الوصف',
                                  style: Theme.of(context).textTheme.titleLarge,
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SelectableText(
                                _stripHtmlTags(topic.description!),
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Relationships Section (no heading as per user request)
                            relatedTopicsAsync.when(
                              data: (related) {
                                // Filter out topics without Arabic names
                                final relatedWithArabic = related
                                    .where((t) => t.arabicName.isNotEmpty)
                                    .toList();

                                if (relatedWithArabic.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                return Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  alignment: WrapAlignment.end,
                                  children: relatedWithArabic.map((
                                    relatedTopic,
                                  ) {
                                    return ActionChip(
                                      label: Text(
                                        relatedTopic.arabicName,
                                        textDirection: TextDirection.rtl,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pushReplacement(
                                          PageRouteBuilder(
                                            pageBuilder:
                                                (
                                                  context,
                                                  animation,
                                                  secondaryAnimation,
                                                ) => TopicDetailScreen(
                                                  topicId: relatedTopic.topicId,
                                                ),
                                            transitionsBuilder:
                                                (
                                                  context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child,
                                                ) {
                                                  // Slide in from right
                                                  const begin = Offset(
                                                    1.0,
                                                    0.0,
                                                  );
                                                  const end = Offset(0.0, 0.0);
                                                  const curve =
                                                      Curves.easeInOut;
                                                  final tween =
                                                      Tween(
                                                        begin: begin,
                                                        end: end,
                                                      ).chain(
                                                        CurveTween(
                                                          curve: curve,
                                                        ),
                                                      );
                                                  return SlideTransition(
                                                    position: animation.drive(
                                                      tween,
                                                    ),
                                                    child: child,
                                                  );
                                                },
                                            reverseTransitionDuration:
                                                const Duration(
                                                  milliseconds: 300,
                                                ),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                );
                              },
                              loading: () => const Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                              error: (_, _) => const SizedBox.shrink(),
                            ),
                            const SizedBox(height: 24),

                            // Verses Section
                            versesAsync.when(
                              data: (verses) {
                                // WHY: Only show verses section if there are verses
                                if (verses.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                final versesBySurah = _groupVersesBySurah(
                                  verses,
                                );
                                return Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        'الآيات ذات الصلة (${verses.length})',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge,
                                        textDirection: TextDirection.rtl,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...versesBySurah.entries.map((entry) {
                                      final surahNumber = entry.key;
                                      final ayahs = entry.value;
                                      return ExpansionTile(
                                        title: FutureBuilder<String>(
                                          future: ref
                                              .read(
                                                databaseServiceProvider.future,
                                              )
                                              .then(
                                                (db) => db.getSurahName(
                                                  surahNumber,
                                                ),
                                              ),
                                          builder: (context, snapshot) {
                                            final surahName =
                                                snapshot.data ?? '';
                                            return Text(
                                              'سورة $surahName (${ayahs.length} آيات)',
                                              textDirection: TextDirection.rtl,
                                            );
                                          },
                                        ),
                                        children: ayahs.map((verse) {
                                          return FutureBuilder<String>(
                                            future: ref
                                                .read(
                                                  databaseServiceProvider
                                                      .future,
                                                )
                                                .then(
                                                  (db) => db.getAyahText(
                                                    verse.surahNumber,
                                                    verse.ayahNumber,
                                                  ),
                                                ),
                                            builder: (context, snapshot) {
                                              return ListTile(
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16.0,
                                                      vertical: 4.0,
                                                    ),
                                                title: Text(
                                                  'آية: ${verse.ayahNumber}',
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  textAlign: TextAlign.right,
                                                ),
                                                subtitle: snapshot.hasData
                                                    ? Text(
                                                        snapshot.data!,
                                                        textDirection:
                                                            TextDirection.rtl,
                                                        textAlign:
                                                            TextAlign.right,
                                                      )
                                                    : const Padding(
                                                        padding: EdgeInsets.all(
                                                          8,
                                                        ),
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                trailing: const Icon(
                                                  Icons.chevron_right,
                                                ),
                                                onTap: () => _navigateToAyah(
                                                  context,
                                                  ref,
                                                  verse.surahNumber,
                                                  verse.ayahNumber,
                                                ),
                                              );
                                            },
                                          );
                                        }).toList(),
                                      );
                                    }),
                                  ],
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, _) => const SizedBox.shrink(),
                            ),
                          ],
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(
                        child: Text(
                          'خطأ: $error',
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('خطأ: $error')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns a user-friendly error message that doesn't leak sensitive information.
  /// WHY: Security - Never expose technical details like paths, stack traces, or internal errors.
  String _getUserFriendlyErrorMessage(Object error) {
    // Map technical errors to generic user-facing messages
    if (error is DatabaseConnectionException) {
      return 'لا يمكن الاتصال بقاعدة البيانات';
    } else if (error is DatabaseNotInitializedException) {
      return 'قاعدة البيانات غير جاهزة';
    } else if (error is DatabaseNotFoundException) {
      return 'البيانات المطلوبة غير موجودة';
    } else if (error is DatabaseOperationException) {
      return 'حدث خطأ أثناء معالجة البيانات';
    } else if (error is DatabaseConstraintException) {
      return 'خطأ في البيانات';
    } else {
      // Generic message for unknown errors
      // In debug mode, the full error is already logged
      return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى';
    }
  }
}
