import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../models.dart';
import '../widgets/shared/app_header.dart';
import '../screens/mushaf_screen.dart';
import '../utils/helpers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Focus on search field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      ref.read(searchQueryProvider.notifier).setQuery(query);
      ref.read(searchHistoryProvider.notifier).addToHistory(query);
    }
  }

  void _navigateToPage(int pageNumber) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MushafScreen(initialPage: pageNumber),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentQuery = ref.watch(searchQueryProvider);
    final searchHistory = ref.watch(searchHistoryProvider);

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              AppHeader(
                title: 'البحث',
                onSearchPressed: null, // No search in search screen
                showBackButton: true,
              ),
              Expanded(
                child: Column(
                  children: [
                    // Search Input
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: 'ابحث في القرآن الكريم...',
                          hintStyle: TextStyle(
                            color: theme.hintColor,
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: theme.iconTheme.color,
                          ),
                          suffixIcon: currentQuery.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    ref
                                        .read(searchQueryProvider.notifier)
                                        .clearQuery();
                                  },
                                  icon: Icon(
                                    Icons.clear,
                                    color: theme.iconTheme.color,
                                  ),
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: theme.cardColor,
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        onSubmitted: _performSearch,
                        onChanged: (value) {
                          // Update query as user types for real-time search
                          if (value.trim().isNotEmpty) {
                            ref
                                .read(searchQueryProvider.notifier)
                                .setQuery(value);
                          } else {
                            ref.read(searchQueryProvider.notifier).clearQuery();
                          }
                        },
                      ),
                    ),
                    // Search Results or History
                    Expanded(
                      child: currentQuery.isEmpty
                          ? _buildSearchHistory(searchHistory, theme)
                          : _buildSearchResults(currentQuery, theme),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHistory(List<String> history, ThemeData theme) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: theme.iconTheme.color?.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'ابدأ بالبحث في القرآن الكريم',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابحث عن كلمة أو آية أو اسم سورة',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.4),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'البحث السابق',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  ref.read(searchHistoryProvider.notifier).clearHistory();
                },
                child: Text(
                  'مسح الكل',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final query = history[index];
              return ListTile(
                leading: Icon(
                  Icons.history,
                  color: theme.iconTheme.color?.withOpacity(0.6),
                  size: 20,
                ),
                title: Text(query, style: theme.textTheme.bodyLarge),
                trailing: IconButton(
                  onPressed: () {
                    ref
                        .read(searchHistoryProvider.notifier)
                        .removeFromHistory(query);
                  },
                  icon: Icon(
                    Icons.close,
                    color: theme.iconTheme.color?.withOpacity(0.6),
                    size: 18,
                  ),
                ),
                onTap: () {
                  _searchController.text = query;
                  _performSearch(query);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(String query, ThemeData theme) {
    final searchResultsAsync = ref.watch(searchResultsProvider(query));

    return searchResultsAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: theme.iconTheme.color?.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'لم يتم العثور على نتائج',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'جرب البحث بكلمات مختلفة',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Text(
                '${convertToEasternArabicNumerals(results.length.toString())} نتيجة',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final result = results[index];
                  return SearchResultItem(
                    result: result,
                    query: query,
                    onTap: () => _navigateToPage(result.pageNumber),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text('جاري البحث...', style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ أثناء البحث',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'يرجى المحاولة مرة أخرى',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyLarge?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchResultItem extends StatelessWidget {
  final SearchResult result;
  final String query;
  final VoidCallback onTap;

  const SearchResultItem({
    super.key,
    required this.result,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          result.context,
          style: TextStyle(
            fontSize: 16,
            color: theme.textTheme.bodyLarge?.color,
            height: 1.5, // Add line height for better spacing
          ),
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.book,
                  size: 16,
                  color: theme.iconTheme.color?.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '${result.surahName} - الآية ${convertToEasternArabicNumerals(result.ayahNumber.toString())}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.pageview,
                  size: 16,
                  color: theme.iconTheme.color?.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  'الصفحة ${convertToEasternArabicNumerals(result.pageNumber.toString())}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: theme.iconTheme.color?.withOpacity(0.6),
        ),
        onTap: onTap,
      ),
    );
  }
}
