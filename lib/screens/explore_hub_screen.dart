import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../widgets/shared/app_header.dart';
import '../models/ontology_models.dart';
import 'topic_detail_screen.dart';

class ExploreHubScreen extends ConsumerStatefulWidget {
  const ExploreHubScreen({super.key});

  @override
  ConsumerState<ExploreHubScreen> createState() => _ExploreHubScreenState();
}

class _ExploreHubScreenState extends ConsumerState<ExploreHubScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Always use ontology hierarchy (more structured for visualization)
    final rootTopicsAsync = ref.watch(
      rootTopicsByHierarchyProvider(false), // false = ontology hierarchy
    );
    final searchResultsAsync = _searchQuery.trim().isEmpty
        ? rootTopicsAsync
        : ref.watch(searchTopicsProvider(_searchQuery));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: 'استكشاف المواضيع', showBackButton: true),
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: '...ابحث عن موضوع',
                  suffixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            // Topics List
            Expanded(
              child: searchResultsAsync.when(
                data: (topics) {
                  // Filter out topics without Arabic names
                  final topicsWithArabic = topics
                      .where((t) => t.arabicName.isNotEmpty)
                      .toList();

                  // WHY: Deduplicate by Arabic name to prevent duplicate entries
                  // Multiple topics can have same Arabic name but different IDs
                  final uniqueTopics = <String, Topic>{};
                  for (final topic in topicsWithArabic) {
                    uniqueTopics.putIfAbsent(topic.arabicName, () => topic);
                  }

                  final deduplicatedTopics = uniqueTopics.values.toList();

                  if (deduplicatedTopics.isEmpty) {
                    return const Center(child: Text('لا توجد نتائج'));
                  }

                  // WHY: Filter topics by checking if they have verses (async check per item)
                  return FutureBuilder<List<Topic>>(
                    future: _filterTopicsWithVerses(ref, deduplicatedTopics),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final topicsWithVerses = snapshot.data!;

                      if (topicsWithVerses.isEmpty) {
                        return const Center(child: Text('لا توجد نتائج'));
                      }

                      // If searching, show flat list
                      if (_searchQuery.trim().isNotEmpty) {
                        return ListView.builder(
                          itemCount: topicsWithVerses.length,
                          itemBuilder: (context, index) {
                            final topic = topicsWithVerses[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 4.0,
                              ),
                              title: Text(
                                topic.arabicName,
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                              ),
                              leading: const Icon(Icons.chevron_left),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => TopicDetailScreen(
                                      topicId: topic.topicId,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }

                      // Show flat list
                      return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: topicsWithVerses.length,
                        itemBuilder: (context, index) {
                          final topic = topicsWithVerses[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
                            ),
                            title: Text(
                              topic.arabicName,
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.right,
                            ),
                            leading: const Icon(Icons.chevron_left),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TopicDetailScreen(topicId: topic.topicId),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) {
                  if (kDebugMode) {
                    debugPrint('ExploreHubScreen error: $error\n$stack');
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'حدث خطأ',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            error.toString(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Filters topics to only include those with verses.
  /// WHY: Topics without verses should not be displayed.
  Future<List<Topic>> _filterTopicsWithVerses(
    WidgetRef ref,
    List<Topic> topics,
  ) async {
    final topicsWithVerses = <Topic>[];
    for (final topic in topics) {
      try {
        final verses = await ref.read(
          versesForTopicProvider(topic.topicId).future,
        );
        if (verses.isNotEmpty) {
          topicsWithVerses.add(topic);
        }
      } catch (e) {
        // Skip topics that error (likely don't exist)
        // No logging needed for expected errors
      }
    }
    return topicsWithVerses;
  }
}
