// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sharedPreferences)
const sharedPreferencesProvider = SharedPreferencesProvider._();

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<SharedPreferences>,
          SharedPreferences,
          FutureOr<SharedPreferences>
        >
    with
        $FutureModifier<SharedPreferences>,
        $FutureProvider<SharedPreferences> {
  const SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SharedPreferences> create(Ref ref) {
    return sharedPreferences(ref);
  }
}

String _$sharedPreferencesHash() => r'50d46e3f8d9f32715d0f3efabdce724e4b2593b4';

@ProviderFor(CurrentPage)
const currentPageProvider = CurrentPageProvider._();

final class CurrentPageProvider extends $NotifierProvider<CurrentPage, int> {
  const CurrentPageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentPageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentPageHash();

  @$internal
  @override
  CurrentPage create() => CurrentPage();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$currentPageHash() => r'76d9bacfeae048ee36d304f550c4df9593672cfb';

abstract class _$CurrentPage extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(DatabaseServiceNotifier)
const databaseServiceProvider = DatabaseServiceNotifierProvider._();

final class DatabaseServiceNotifierProvider
    extends $AsyncNotifierProvider<DatabaseServiceNotifier, DatabaseService> {
  const DatabaseServiceNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseServiceNotifierHash();

  @$internal
  @override
  DatabaseServiceNotifier create() => DatabaseServiceNotifier();
}

String _$databaseServiceNotifierHash() =>
    r'b9e65e1c82f97af7523daf27cfdf3ec9165d0bf2';

abstract class _$DatabaseServiceNotifier
    extends $AsyncNotifier<DatabaseService> {
  FutureOr<DatabaseService> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<DatabaseService>, DatabaseService>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DatabaseService>, DatabaseService>,
              AsyncValue<DatabaseService>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(fontService)
const fontServiceProvider = FontServiceProvider._();

final class FontServiceProvider
    extends $FunctionalProvider<FontService, FontService, FontService>
    with $Provider<FontService> {
  const FontServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fontServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fontServiceHash();

  @$internal
  @override
  $ProviderElement<FontService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FontService create(Ref ref) {
    return fontService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FontService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FontService>(value),
    );
  }
}

String _$fontServiceHash() => r'c234dae6c98abe9581202b1937ebf8e4d07480b2';

@ProviderFor(pageData)
const pageDataProvider = PageDataFamily._();

final class PageDataProvider
    extends
        $FunctionalProvider<AsyncValue<PageData>, PageData, FutureOr<PageData>>
    with $FutureModifier<PageData>, $FutureProvider<PageData> {
  const PageDataProvider._({
    required PageDataFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'pageDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pageDataHash();

  @override
  String toString() {
    return r'pageDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PageData> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PageData> create(Ref ref) {
    final argument = this.argument as int;
    return pageData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PageDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pageDataHash() => r'3cbfb785df106228b99ac4fff7fa50ba22b3cf0f';

final class PageDataFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PageData>, int> {
  const PageDataFamily._()
    : super(
        retry: null,
        name: r'pageDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PageDataProvider call(int pageNumber) =>
      PageDataProvider._(argument: pageNumber, from: this);

  @override
  String toString() => r'pageDataProvider';
}

@ProviderFor(surahList)
const surahListProvider = SurahListProvider._();

final class SurahListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SurahInfo>>,
          List<SurahInfo>,
          FutureOr<List<SurahInfo>>
        >
    with $FutureModifier<List<SurahInfo>>, $FutureProvider<List<SurahInfo>> {
  const SurahListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'surahListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$surahListHash();

  @$internal
  @override
  $FutureProviderElement<List<SurahInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SurahInfo>> create(Ref ref) {
    return surahList(ref);
  }
}

String _$surahListHash() => r'772efb4d154cf1a63d0b740a9277fb8da360b7cc';

@ProviderFor(juzList)
const juzListProvider = JuzListProvider._();

final class JuzListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<JuzInfo>>,
          List<JuzInfo>,
          FutureOr<List<JuzInfo>>
        >
    with $FutureModifier<List<JuzInfo>>, $FutureProvider<List<JuzInfo>> {
  const JuzListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'juzListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$juzListHash();

  @$internal
  @override
  $FutureProviderElement<List<JuzInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<JuzInfo>> create(Ref ref) {
    return juzList(ref);
  }
}

String _$juzListHash() => r'22515260ff8ac16d6e63f46fd1e8067debe78fdc';

@ProviderFor(pagePreview)
const pagePreviewProvider = PagePreviewFamily._();

final class PagePreviewProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  const PagePreviewProvider._({
    required PagePreviewFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'pagePreviewProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pagePreviewHash();

  @override
  String toString() {
    return r'pagePreviewProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as int;
    return pagePreview(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PagePreviewProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pagePreviewHash() => r'855711048ca7bd04f2bf594db7547ad226945408';

final class PagePreviewFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, int> {
  const PagePreviewFamily._()
    : super(
        retry: null,
        name: r'pagePreviewProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PagePreviewProvider call(int pageNumber) =>
      PagePreviewProvider._(argument: pageNumber, from: this);

  @override
  String toString() => r'pagePreviewProvider';
}

@ProviderFor(pageFontFamily)
const pageFontFamilyProvider = PageFontFamilyFamily._();

final class PageFontFamilyProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  const PageFontFamilyProvider._({
    required PageFontFamilyFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'pageFontFamilyProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pageFontFamilyHash();

  @override
  String toString() {
    return r'pageFontFamilyProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as int;
    return pageFontFamily(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PageFontFamilyProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pageFontFamilyHash() => r'f562dda973a4542f6996503eabca7e96d3e76f16';

final class PageFontFamilyFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, int> {
  const PageFontFamilyFamily._()
    : super(
        retry: null,
        name: r'pageFontFamilyProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PageFontFamilyProvider call(int pageNumber) =>
      PageFontFamilyProvider._(argument: pageNumber, from: this);

  @override
  String toString() => r'pageFontFamilyProvider';
}

@ProviderFor(SelectionTabIndex)
const selectionTabIndexProvider = SelectionTabIndexProvider._();

final class SelectionTabIndexProvider
    extends $NotifierProvider<SelectionTabIndex, int> {
  const SelectionTabIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectionTabIndexProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectionTabIndexHash();

  @$internal
  @override
  SelectionTabIndex create() => SelectionTabIndex();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$selectionTabIndexHash() => r'7cfefe9a7077eb938eaa001a77d19ca39bacdc27';

abstract class _$SelectionTabIndex extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(MushafLayoutSetting)
const mushafLayoutSettingProvider = MushafLayoutSettingProvider._();

final class MushafLayoutSettingProvider
    extends $NotifierProvider<MushafLayoutSetting, MushafLayout> {
  const MushafLayoutSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mushafLayoutSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mushafLayoutSettingHash();

  @$internal
  @override
  MushafLayoutSetting create() => MushafLayoutSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MushafLayout value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MushafLayout>(value),
    );
  }
}

String _$mushafLayoutSettingHash() =>
    r'1dab6478f90439f86f7f1f720db9302a7e972a30';

abstract class _$MushafLayoutSetting extends $Notifier<MushafLayout> {
  MushafLayout build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<MushafLayout, MushafLayout>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MushafLayout, MushafLayout>,
              MushafLayout,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(FontSizeSetting)
const fontSizeSettingProvider = FontSizeSettingProvider._();

final class FontSizeSettingProvider
    extends $NotifierProvider<FontSizeSetting, double> {
  const FontSizeSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fontSizeSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fontSizeSettingHash();

  @$internal
  @override
  FontSizeSetting create() => FontSizeSetting();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }
}

String _$fontSizeSettingHash() => r'0c79919f437bc31a01258da08789868d27a46a00';

abstract class _$FontSizeSetting extends $Notifier<double> {
  double build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(searchService)
const searchServiceProvider = SearchServiceProvider._();

final class SearchServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<SearchService>,
          SearchService,
          FutureOr<SearchService>
        >
    with $FutureModifier<SearchService>, $FutureProvider<SearchService> {
  const SearchServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchServiceHash();

  @$internal
  @override
  $FutureProviderElement<SearchService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SearchService> create(Ref ref) {
    return searchService(ref);
  }
}

String _$searchServiceHash() => r'0d5b88bfba67f5e1f3f5b9a92d362f8ed7b8e69b';

@ProviderFor(SearchQuery)
const searchQueryProvider = SearchQueryProvider._();

final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  const SearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryHash();

  @$internal
  @override
  SearchQuery create() => SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryHash() => r'571879970eb0165e4d4b70b1d76bcf86eb2146be';

abstract class _$SearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(searchResults)
const searchResultsProvider = SearchResultsFamily._();

final class SearchResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SearchResult>>,
          List<SearchResult>,
          FutureOr<List<SearchResult>>
        >
    with
        $FutureModifier<List<SearchResult>>,
        $FutureProvider<List<SearchResult>> {
  const SearchResultsProvider._({
    required SearchResultsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchResultsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchResultsHash();

  @override
  String toString() {
    return r'searchResultsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<SearchResult>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SearchResult>> create(Ref ref) {
    final argument = this.argument as String;
    return searchResults(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchResultsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchResultsHash() => r'd06301fb48730166d9c74332618adbfe4c4ca58c';

final class SearchResultsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SearchResult>>, String> {
  const SearchResultsFamily._()
    : super(
        retry: null,
        name: r'searchResultsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchResultsProvider call(String query) =>
      SearchResultsProvider._(argument: query, from: this);

  @override
  String toString() => r'searchResultsProvider';
}

@ProviderFor(SearchHistory)
const searchHistoryProvider = SearchHistoryProvider._();

final class SearchHistoryProvider
    extends $NotifierProvider<SearchHistory, List<String>> {
  const SearchHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchHistoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchHistoryHash();

  @$internal
  @override
  SearchHistory create() => SearchHistory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$searchHistoryHash() => r'c7980f60480a959d302188e674c25bcc87df4695';

abstract class _$SearchHistory extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(bookmarksService)
const bookmarksServiceProvider = BookmarksServiceProvider._();

final class BookmarksServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<BookmarksService>,
          BookmarksService,
          FutureOr<BookmarksService>
        >
    with $FutureModifier<BookmarksService>, $FutureProvider<BookmarksService> {
  const BookmarksServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookmarksServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookmarksServiceHash();

  @$internal
  @override
  $FutureProviderElement<BookmarksService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<BookmarksService> create(Ref ref) {
    return bookmarksService(ref);
  }
}

String _$bookmarksServiceHash() => r'1e6d08f9953d7b36773c13e272e6eb94dde9c323';

@ProviderFor(isAyahBookmarked)
const isAyahBookmarkedProvider = IsAyahBookmarkedFamily._();

final class IsAyahBookmarkedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  const IsAyahBookmarkedProvider._({
    required IsAyahBookmarkedFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'isAyahBookmarkedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isAyahBookmarkedHash();

  @override
  String toString() {
    return r'isAyahBookmarkedProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as (int, int);
    return isAyahBookmarked(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is IsAyahBookmarkedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isAyahBookmarkedHash() => r'62957e968a9a625e4fcc37ecfaf6e954f2d0ee70';

final class IsAyahBookmarkedFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, (int, int)> {
  const IsAyahBookmarkedFamily._()
    : super(
        retry: null,
        name: r'isAyahBookmarkedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IsAyahBookmarkedProvider call(int surahNumber, int ayahNumber) =>
      IsAyahBookmarkedProvider._(
        argument: (surahNumber, ayahNumber),
        from: this,
      );

  @override
  String toString() => r'isAyahBookmarkedProvider';
}

@ProviderFor(BookmarksNotifier)
const bookmarksProvider = BookmarksNotifierProvider._();

final class BookmarksNotifierProvider
    extends $AsyncNotifierProvider<BookmarksNotifier, List<Bookmark>> {
  const BookmarksNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookmarksProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookmarksNotifierHash();

  @$internal
  @override
  BookmarksNotifier create() => BookmarksNotifier();
}

String _$bookmarksNotifierHash() => r'13f8187c9180ebebb4a86d94aeedfed3ccc05391';

abstract class _$BookmarksNotifier extends $AsyncNotifier<List<Bookmark>> {
  FutureOr<List<Bookmark>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Bookmark>>, List<Bookmark>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Bookmark>>, List<Bookmark>>,
              AsyncValue<List<Bookmark>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(bookmarkPageNumber)
const bookmarkPageNumberProvider = BookmarkPageNumberFamily._();

final class BookmarkPageNumberProvider
    extends $FunctionalProvider<AsyncValue<int?>, int?, FutureOr<int?>>
    with $FutureModifier<int?>, $FutureProvider<int?> {
  const BookmarkPageNumberProvider._({
    required BookmarkPageNumberFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'bookmarkPageNumberProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$bookmarkPageNumberHash();

  @override
  String toString() {
    return r'bookmarkPageNumberProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int?> create(Ref ref) {
    final argument = this.argument as (int, int);
    return bookmarkPageNumber(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is BookmarkPageNumberProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$bookmarkPageNumberHash() =>
    r'382e781e5848dfa6599003410bc911d02f277265';

final class BookmarkPageNumberFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int?>, (int, int)> {
  const BookmarkPageNumberFamily._()
    : super(
        retry: null,
        name: r'bookmarkPageNumberProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BookmarkPageNumberProvider call(int surahNumber, int ayahNumber) =>
      BookmarkPageNumberProvider._(
        argument: (surahNumber, ayahNumber),
        from: this,
      );

  @override
  String toString() => r'bookmarkPageNumberProvider';
}

@ProviderFor(readingProgressService)
const readingProgressServiceProvider = ReadingProgressServiceProvider._();

final class ReadingProgressServiceProvider
    extends
        $FunctionalProvider<
          ReadingProgressService,
          ReadingProgressService,
          ReadingProgressService
        >
    with $Provider<ReadingProgressService> {
  const ReadingProgressServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingProgressServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingProgressServiceHash();

  @$internal
  @override
  $ProviderElement<ReadingProgressService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadingProgressService create(Ref ref) {
    return readingProgressService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadingProgressService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadingProgressService>(value),
    );
  }
}

String _$readingProgressServiceHash() =>
    r'7b7b2083be80eb43cfc22161bc9989d90dcae967';

@ProviderFor(readingStatistics)
const readingStatisticsProvider = ReadingStatisticsProvider._();

final class ReadingStatisticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReadingStatistics>,
          ReadingStatistics,
          FutureOr<ReadingStatistics>
        >
    with
        $FutureModifier<ReadingStatistics>,
        $FutureProvider<ReadingStatistics> {
  const ReadingStatisticsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readingStatisticsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readingStatisticsHash();

  @$internal
  @override
  $FutureProviderElement<ReadingStatistics> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReadingStatistics> create(Ref ref) {
    return readingStatistics(ref);
  }
}

String _$readingStatisticsHash() => r'4e9c3f612ab9e704415d02b8bc41403348133e43';

@ProviderFor(pagesReadToday)
const pagesReadTodayProvider = PagesReadTodayProvider._();

final class PagesReadTodayProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  const PagesReadTodayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pagesReadTodayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pagesReadTodayHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return pagesReadToday(ref);
  }
}

String _$pagesReadTodayHash() => r'6bc60598952979c57cb177c89d91885b7b8d6f23';

@ProviderFor(currentStreak)
const currentStreakProvider = CurrentStreakProvider._();

final class CurrentStreakProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  const CurrentStreakProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentStreakProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentStreakHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return currentStreak(ref);
  }
}

String _$currentStreakHash() => r'255b02ef08a067f91b1334c30fb7b4acb1964538';
