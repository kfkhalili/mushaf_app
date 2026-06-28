import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../services/recitation_range.dart';
import '../utils/helpers.dart';
import '../utils/post_frame_mixin.dart';
import '../models.dart';
import '../widgets/shared/app_header.dart';

/// Screen for configuring audio playback (Qari, start ayah, end ayah)
class AudioConfigScreen extends ConsumerStatefulWidget {
  final int? initialSurahNumber;
  final int? initialStartAyah;
  final int? initialEndAyah;

  const AudioConfigScreen({
    super.key,
    this.initialSurahNumber,
    this.initialStartAyah,
    this.initialEndAyah,
  });

  @override
  ConsumerState<AudioConfigScreen> createState() => _AudioConfigScreenState();
}

class _AudioConfigScreenState extends ConsumerState<AudioConfigScreen> {
  int? _selectedSurah;
  int? _selectedStartAyah;
  int? _selectedEndAyah;
  String? _selectedStartSurahName; // For display
  String? _selectedEndSurahName; // For display

  // Quick buttons selection: 'page', 'surah', 'juz'
  String? _endVerseOption;

  @override
  void initState() {
    super.initState();
    _selectedSurah = widget.initialSurahNumber;
    _selectedStartAyah = widget.initialStartAyah ?? 1;
    _selectedEndAyah = widget.initialEndAyah;
    // Juz is the default, so preselect it
    _endVerseOption = 'juz';
  }

  void _initializeFromCurrentPage(WidgetRef ref) async {
    // Get current page info for defaults if not already set
    if (_selectedSurah == null) {
      final currentPage = ref.read(currentPageProvider);
      final pageDataAsync = ref.read(pageDataProvider(currentPage));

      pageDataAsync.whenData((pageData) async {
        if (pageData.pageSurahNumber > 0 && mounted) {
          setState(() {
            _selectedSurah = pageData.pageSurahNumber;
          });

          // Get surah name
          final dbService = await ref.read(databaseServiceProvider.future);
          final surahName = await dbService.getSurahName(
            pageData.pageSurahNumber,
          );
          if (mounted) {
            setState(() {
              _selectedStartSurahName = surahName;
              _selectedEndSurahName = surahName;
            });
          }

          // Try to get first ayah on current page
          try {
            final firstAyah = await dbService.getFirstAyahOnPage(currentPage);
            if (mounted && firstAyah['surah'] == _selectedSurah) {
              setState(() {
                _selectedStartAyah = firstAyah['ayah'] ?? 1;
              });
              // Set default end to juz end
              await _setDefaultEndToJuz();
              // Ensure juz option is selected
              if (mounted) {
                setState(() {
                  _endVerseOption = 'juz';
                });
              }
            }
          } catch (e) {
            // Ignore errors
          }
        }
      });
    }
  }

  Future<void> _loadSurahNames() async {
    if (_selectedSurah == null) return;

    try {
      final dbService = await ref.read(databaseServiceProvider.future);
      final surahName = await dbService.getSurahName(_selectedSurah!);
      if (mounted) {
        setState(() {
          _selectedStartSurahName = surahName;
          if (_selectedEndAyah == null ||
              _selectedEndAyah == _selectedStartAyah) {
            _selectedEndSurahName = surahName;
          }
        });
      }
    } catch (e) {
      // Ignore errors
    }
  }

  /// Sets the default end ayah to the end of the juz containing the start ayah.
  Future<void> _setDefaultEndToJuz() async {
    await _resolveAndApplyEnd(RecitationEndOption.juz);
  }

  Future<void> _handleEndVerseOption(String option) async {
    setState(() {
      _endVerseOption = option;
    });
    final endOption = switch (option) {
      'page' => RecitationEndOption.page,
      'surah' => RecitationEndOption.surah,
      _ => RecitationEndOption.juz,
    };
    await _resolveAndApplyEnd(endOption);
  }

  /// Resolves the recitation end ayah for [option] via [RecitationRange] and
  /// applies it to the selection, fetching the end surah's display name when it
  /// differs from the start surah.
  Future<void> _resolveAndApplyEnd(RecitationEndOption option) async {
    if (_selectedSurah == null || _selectedStartAyah == null) return;

    try {
      final recitationRange = await ref.read(recitationRangeProvider.future);
      final end = await recitationRange.resolveEndAyah(
        start: (surah: _selectedSurah!, ayah: _selectedStartAyah!),
        option: option,
        currentPage: ref.read(currentPageProvider),
      );
      if (end == null || !mounted) return;

      setState(() {
        _selectedEndAyah = end.ayah;
      });

      // Update the displayed end surah name only when it differs from the start.
      if (end.surah != _selectedSurah) {
        final dbService = await ref.read(databaseServiceProvider.future);
        final name = await dbService.getSurahName(end.surah);
        if (mounted) {
          setState(() {
            _selectedEndSurahName = name;
          });
        }
      } else if (mounted) {
        setState(() {
          _selectedEndSurahName = _selectedStartSurahName;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error resolving recitation end ($option): $e');
      }
    }
  }

  Future<void> _handleStartPlayback() async {
    if (_selectedSurah == null || _selectedStartAyah == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى اختيار السورة وبداية الآية'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    int? pageNumber;

    // Get the page number first (before starting playback)
    try {
      final dbService = await ref.read(databaseServiceProvider.future);
      pageNumber = await dbService.getPageForAyah(
        _selectedSurah!,
        _selectedStartAyah!,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting page for ayah: $e');
      }
    }

    // Start playback in background (don't await - it has delays)
    // This allows us to pop immediately
    if (_selectedEndAyah != null && _selectedEndAyah! > _selectedStartAyah!) {
      // Play range of ayahs
      ref
          .read(audioStateProvider.notifier)
          .playAyahRange(
            _selectedSurah!,
            _selectedStartAyah!,
            _selectedEndAyah!,
          )
          .catchError((e) {
            if (kDebugMode) {
              debugPrint('Error starting playback: $e');
            }
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('فشل بدء التشغيل: $e'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          });
    } else {
      // Play single ayah
      ref
          .read(audioStateProvider.notifier)
          .playAyah(_selectedSurah!, _selectedStartAyah!)
          .catchError((e) {
            if (kDebugMode) {
              debugPrint('Error starting playback: $e');
            }
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('فشل بدء التشغيل: $e'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          });
    }

    // Pop immediately - don't wait for playback
    if (!mounted) return;

    // Check if we need to navigate to a different page
    final currentPage = ref.read(currentPageProvider);
    final needsNavigation = pageNumber != null && pageNumber != currentPage;

    Navigator.of(context).pop();

    // If we need to navigate to a different page, do it AFTER pop
    if (needsNavigation) {
      // Use a microtask to ensure pop completes, then update page
      Future.microtask(() {
        ref.read(currentPageProvider.notifier).setPage(pageNumber!);
      });
    }
  }

  Future<void> _showAyahSelector({required bool isStart}) async {
    // Get all surahs and their segments
    try {
      final dbService = await ref.read(databaseServiceProvider.future);
      final surahs = await dbService.getAllSurahs();

      if (!mounted) return;

      final currentSurah = isStart ? _selectedSurah : _selectedSurah;
      final currentAyah = isStart ? _selectedStartAyah : _selectedEndAyah;

      // Map to store surah number -> selected ayah
      Map<int, int?>? selectedAyahResult;

      final result = await showModalBottomSheet<Map<int, int?>>(
        context: context,
        isScrollControlled: true,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          isStart ? 'اختر بداية الآية' : 'اختر نهاية الآية',
                          style: Theme.of(context).textTheme.titleLarge,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the back button
                    ],
                  ),
                ),
                const Divider(height: 1),
                // List of surahs with their ayahs
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: surahs.length,
                    itemBuilder: (context, surahIndex) {
                      final surah = surahs[surahIndex];
                      return _SurahAyahSection(
                        surah: surah,
                        currentSurah: currentSurah,
                        currentAyah: currentAyah,
                        onAyahSelected: (surahNum, ayahNum) {
                          selectedAyahResult = {surahNum: ayahNum};
                          Navigator.pop(context, selectedAyahResult);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      if (result != null && mounted && result.isNotEmpty) {
        final selectedSurah = result.keys.first;
        final selectedAyah = result[selectedSurah];

        if (selectedAyah != null) {
          setState(() {
            if (isStart) {
              _selectedSurah = selectedSurah;
              _selectedStartAyah = selectedAyah;
              // Load surah name
              _loadSurahNames();
              // Set default end to juz end
              _setDefaultEndToJuz();
            } else {
              _selectedEndAyah = selectedAyah;
              // Clear end verse option when manually selecting
              _endVerseOption = null;
              // Load surah name if different
              if (selectedSurah != _selectedSurah) {
                dbService.getSurahName(selectedSurah).then((name) {
                  if (mounted) {
                    setState(() {
                      _selectedEndSurahName = name;
                    });
                  }
                });
              }
            }
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error showing ayah selector: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surahListAsync = ref.watch(surahListProvider);

    // Initialize from current page if needed
    // WHY: Use PostFrameMixin to reduce code duplication
    PostFrameMixin.runAfterFrame(this, () {
      _initializeFromCurrentPage(ref);
      _loadSurahNames();
      // Set default end to juz end if surah and start ayah are already set
      if (_selectedSurah != null &&
          _selectedStartAyah != null &&
          _selectedEndAyah == null) {
        _setDefaultEndToJuz();
      }
    });

    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            children: [
              AppHeader(title: 'إعدادات التشغيل', showBackButton: true),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.rtl,
                    children: [
                      // Reciter Selection
                      Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          title: const Text(
                            'عبد الله علي جابر',
                            textDirection: TextDirection.rtl,
                          ),
                          onTap: () {
                            // TODO: Show reciter selection if we have multiple reciters
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Adjust End Verse Section
                      Text(
                        'ضبط نهاية الآية حتى نهاية',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 8),
                      // Segmented Control for Juz/Surah/Page (Juz first as default)
                      Row(
                        children: [
                          Expanded(
                            child: _buildEndVerseOptionButton(
                              context,
                              'الجزء',
                              'juz',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildEndVerseOptionButton(
                              context,
                              'السورة',
                              'surah',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildEndVerseOptionButton(
                              context,
                              'الصفحة',
                              'page',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Playing Verses Section
                      Text(
                        'نطاق التشغيل',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 8),
                      // From/To Container
                      Card(
                        child: Column(
                          children: [
                            // From
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              title: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  const Text(
                                    'من',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'IBMPlexSansArabic',
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                  const SizedBox(width: 24),
                                  Flexible(
                                    child: Text(
                                      _selectedSurah != null &&
                                              _selectedStartSurahName != null
                                          ? '$_selectedSurah. $_selectedStartSurahName - آية ${convertToEasternArabicNumerals(_selectedStartAyah?.toString() ?? '1')}'
                                          : 'اختر السورة والآية',
                                      style: theme.textTheme.bodyMedium,
                                      textDirection: TextDirection.rtl,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => _showAyahSelector(isStart: true),
                            ),
                            const Divider(height: 1),
                            // To
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              title: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  const Text(
                                    'إلى',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'IBMPlexSansArabic',
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                  const SizedBox(width: 24),
                                  Flexible(
                                    child: Text(
                                      _selectedEndAyah != null
                                          ? (_selectedSurah != null &&
                                                    (_selectedEndSurahName !=
                                                            null ||
                                                        _selectedStartSurahName !=
                                                            null)
                                                ? '$_selectedSurah. ${_selectedEndSurahName ?? _selectedStartSurahName} - آية ${convertToEasternArabicNumerals(_selectedEndAyah.toString())}'
                                                : 'آية ${convertToEasternArabicNumerals(_selectedEndAyah.toString())}')
                                          : 'اختر نهاية الآية',
                                      style: theme.textTheme.bodyMedium,
                                      textDirection: TextDirection.rtl,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => _showAyahSelector(isStart: false),
                            ),
                          ],
                        ),
                      ),

                      // Hidden Surah Selection (for initialization)
                      if (_selectedSurah == null) ...[
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              textDirection: TextDirection.rtl,
                              children: [
                                Text(
                                  'السورة',
                                  style: theme.textTheme.titleMedium,
                                  textDirection: TextDirection.rtl,
                                ),
                                const SizedBox(height: 8),
                                surahListAsync.when(
                                  data: (surahs) {
                                    return DropdownButtonFormField<int>(
                                      initialValue: _selectedSurah,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: 'اختر السورة',
                                      ),
                                      items: surahs.map((surah) {
                                        return DropdownMenuItem<int>(
                                          value: surah.surahNumber,
                                          child: Text(
                                            '${surah.nameArabic} (${convertToEasternArabicNumerals(surah.surahNumber.toString())})',
                                            textDirection: TextDirection.rtl,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedSurah = value;
                                          _selectedStartAyah = 1;
                                          _selectedEndAyah = null;
                                          _endVerseOption = null;
                                        });
                                        _loadSurahNames();
                                        // Set default end to juz end
                                        _setDefaultEndToJuz();
                                      },
                                    );
                                  },
                                  loading: () => const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  error: (error, stack) => Text(
                                    'خطأ في تحميل السور',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.error,
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleStartPlayback,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'بدء التشغيل',
                style: TextStyle(fontSize: 18, fontFamily: 'IBMPlexSansArabic'),
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEndVerseOptionButton(
    BuildContext context,
    String label,
    String option,
  ) {
    final theme = Theme.of(context);
    final isSelected = _endVerseOption == option;

    return Material(
      color: isSelected
          ? theme.colorScheme.primary
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => _handleEndVerseOption(option),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.textTheme.bodyLarge?.color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget that displays a surah with all its ayahs grouped together
class _SurahAyahSection extends ConsumerStatefulWidget {
  final SurahInfo surah;
  final int? currentSurah;
  final int? currentAyah;
  final Function(int surahNumber, int ayahNumber) onAyahSelected;

  const _SurahAyahSection({
    required this.surah,
    required this.currentSurah,
    required this.currentAyah,
    required this.onAyahSelected,
  });

  @override
  ConsumerState<_SurahAyahSection> createState() => _SurahAyahSectionState();
}

class _SurahAyahSectionState extends ConsumerState<_SurahAyahSection> {
  List<AyahSegment>? _segments;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSegments();
  }

  Future<void> _loadSegments() async {
    try {
      final dbService = await ref.read(databaseServiceProvider.future);
      final segments = await dbService.getSurahSegments(
        widget.surah.surahNumber,
      );
      if (mounted) {
        setState(() {
          _segments = segments;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrentSurah = widget.currentSurah == widget.surah.surahNumber;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Surah header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: theme.colorScheme.surfaceContainerHighest,
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Text(
                widget.surah.nameArabic.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
        // Ayah list
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_segments != null && _segments!.isNotEmpty)
          ..._segments!.map((segment) {
            final isSelected =
                isCurrentSurah && widget.currentAyah == segment.ayahNumber;
            return ListTile(
              title: Text(
                '${widget.surah.nameArabic}، آية ${convertToEasternArabicNumerals(segment.ayahNumber.toString())}',
                textDirection: TextDirection.rtl,
              ),
              selected: isSelected,
              selectedTileColor: theme.colorScheme.primaryContainer,
              trailing: isSelected
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onTap: () {
                widget.onAyahSelected(
                  widget.surah.surahNumber,
                  segment.ayahNumber,
                );
              },
            );
          }),
      ],
    );
  }
}
