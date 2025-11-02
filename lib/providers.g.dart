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

@ProviderFor(appDataService)
const appDataServiceProvider = AppDataServiceProvider._();

final class AppDataServiceProvider
    extends $FunctionalProvider<AppDataService, AppDataService, AppDataService>
    with $Provider<AppDataService> {
  const AppDataServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDataServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDataServiceHash();

  @$internal
  @override
  $ProviderElement<AppDataService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDataService create(Ref ref) {
    return appDataService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDataService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDataService>(value),
    );
  }
}

String _$appDataServiceHash() => r'5ed485b1e634417af75265c61fc7154093588d38';

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

String _$currentPageHash() => r'63033d1ee10caf58175182a9ebcbb345cb93e275';

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
    r'718c2d39e7a766bbdb0febc9bd808395641b8754';

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

@ProviderFor(pagePreviewWithFont)
const pagePreviewWithFontProvider = PagePreviewWithFontFamily._();

final class PagePreviewWithFontProvider
    extends
        $FunctionalProvider<
          AsyncValue<(String, String)>,
          (String, String),
          FutureOr<(String, String)>
        >
    with $FutureModifier<(String, String)>, $FutureProvider<(String, String)> {
  const PagePreviewWithFontProvider._({
    required PagePreviewWithFontFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'pagePreviewWithFontProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pagePreviewWithFontHash();

  @override
  String toString() {
    return r'pagePreviewWithFontProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<(String, String)> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<(String, String)> create(Ref ref) {
    final argument = this.argument as int;
    return pagePreviewWithFont(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PagePreviewWithFontProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pagePreviewWithFontHash() =>
    r'e32af8b86cd0f568131169d1456b208d2a6c56e7';

final class PagePreviewWithFontFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<(String, String)>, int> {
  const PagePreviewWithFontFamily._()
    : super(
        retry: null,
        name: r'pagePreviewWithFontProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PagePreviewWithFontProvider call(int pageNumber) =>
      PagePreviewWithFontProvider._(argument: pageNumber, from: this);

  @override
  String toString() => r'pagePreviewWithFontProvider';
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
    r'eea8f96fae8abbefbd64312a9c8c17bcff26beeb';

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

String _$searchHistoryHash() => r'31190bc895c9f5dbb4c7466d9fd3f0a07e73057c';

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

String _$bookmarksServiceHash() => r'd98c721dc9efa6326cc9242716e708b58ab3c297';

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

String _$bookmarksNotifierHash() => r'bbb92117e4464d2e8a49e9cf9308d36bb7511dd7';

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

@ProviderFor(pageDataWithBookmarks)
const pageDataWithBookmarksProvider = PageDataWithBookmarksFamily._();

final class PageDataWithBookmarksProvider
    extends
        $FunctionalProvider<
          AsyncValue<(PageData, List<Bookmark>)>,
          (PageData, List<Bookmark>),
          FutureOr<(PageData, List<Bookmark>)>
        >
    with
        $FutureModifier<(PageData, List<Bookmark>)>,
        $FutureProvider<(PageData, List<Bookmark>)> {
  const PageDataWithBookmarksProvider._({
    required PageDataWithBookmarksFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'pageDataWithBookmarksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pageDataWithBookmarksHash();

  @override
  String toString() {
    return r'pageDataWithBookmarksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<(PageData, List<Bookmark>)> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<(PageData, List<Bookmark>)> create(Ref ref) {
    final argument = this.argument as int;
    return pageDataWithBookmarks(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PageDataWithBookmarksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pageDataWithBookmarksHash() =>
    r'b85f3f2925541048c81a62e81ada20f0ad1becfc';

final class PageDataWithBookmarksFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<(PageData, List<Bookmark>)>, int> {
  const PageDataWithBookmarksFamily._()
    : super(
        retry: null,
        name: r'pageDataWithBookmarksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PageDataWithBookmarksProvider call(int pageNumber) =>
      PageDataWithBookmarksProvider._(argument: pageNumber, from: this);

  @override
  String toString() => r'pageDataWithBookmarksProvider';
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
    r'9d0f18f6fe5bae0b8b3b66c80ff6426bd311274d';

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
          AsyncValue<ReadingProgressService>,
          ReadingProgressService,
          FutureOr<ReadingProgressService>
        >
    with
        $FutureModifier<ReadingProgressService>,
        $FutureProvider<ReadingProgressService> {
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
  $FutureProviderElement<ReadingProgressService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReadingProgressService> create(Ref ref) {
    return readingProgressService(ref);
  }
}

String _$readingProgressServiceHash() =>
    r'51ae74f95ad5d87850b1520db052aee85ac0673b';

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

String _$readingStatisticsHash() => r'11644989a0c8eac4fcd7ffd4eb809c1f43b0275d';

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

String _$pagesReadTodayHash() => r'2a0d28df25e63ccce6fb47565e121658c340eea5';

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

String _$currentStreakHash() => r'e92074e4a2350a1e4fcc5e444be86a364ff6a968';

@ProviderFor(PrimaryColorNotifier)
const primaryColorProvider = PrimaryColorNotifierProvider._();

final class PrimaryColorNotifierProvider
    extends $NotifierProvider<PrimaryColorNotifier, int> {
  const PrimaryColorNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'primaryColorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$primaryColorNotifierHash();

  @$internal
  @override
  PrimaryColorNotifier create() => PrimaryColorNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$primaryColorNotifierHash() =>
    r'c201df1693e236dbcc15eb2d5b6dd38f1b560c52';

abstract class _$PrimaryColorNotifier extends $Notifier<int> {
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

@ProviderFor(ThemeNotifier)
const themeProvider = ThemeNotifierProvider._();

final class ThemeNotifierProvider
    extends $NotifierProvider<ThemeNotifier, AppThemeMode> {
  const ThemeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeNotifierHash();

  @$internal
  @override
  ThemeNotifier create() => ThemeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppThemeMode>(value),
    );
  }
}

String _$themeNotifierHash() => r'c3ddcacc0b433b00388b565cf9ddd1a9b395bd5d';

abstract class _$ThemeNotifier extends $Notifier<AppThemeMode> {
  AppThemeMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AppThemeMode, AppThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppThemeMode, AppThemeMode>,
              AppThemeMode,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(MemorizationSessionNotifier)
const memorizationSessionProvider = MemorizationSessionNotifierProvider._();

final class MemorizationSessionNotifierProvider
    extends
        $NotifierProvider<
          MemorizationSessionNotifier,
          MemorizationSessionState?
        > {
  const MemorizationSessionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memorizationSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memorizationSessionNotifierHash();

  @$internal
  @override
  MemorizationSessionNotifier create() => MemorizationSessionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemorizationSessionState? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemorizationSessionState?>(value),
    );
  }
}

String _$memorizationSessionNotifierHash() =>
    r'e0123a73bff395aea168ab0dbabb443423052c25';

abstract class _$MemorizationSessionNotifier
    extends $Notifier<MemorizationSessionState?> {
  MemorizationSessionState? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<MemorizationSessionState?, MemorizationSessionState?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MemorizationSessionState?, MemorizationSessionState?>,
              MemorizationSessionState?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(OntologyServiceNotifier)
const ontologyServiceProvider = OntologyServiceNotifierProvider._();

final class OntologyServiceNotifierProvider
    extends $AsyncNotifierProvider<OntologyServiceNotifier, OntologyService> {
  const OntologyServiceNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ontologyServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ontologyServiceNotifierHash();

  @$internal
  @override
  OntologyServiceNotifier create() => OntologyServiceNotifier();
}

String _$ontologyServiceNotifierHash() =>
    r'c09d6d08fa480230d5fed6a87572a3d1fc1f9ec2';

abstract class _$OntologyServiceNotifier
    extends $AsyncNotifier<OntologyService> {
  FutureOr<OntologyService> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<OntologyService>, OntologyService>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<OntologyService>, OntologyService>,
              AsyncValue<OntologyService>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(topicById)
const topicByIdProvider = TopicByIdFamily._();

final class TopicByIdProvider
    extends $FunctionalProvider<AsyncValue<Topic>, Topic, FutureOr<Topic>>
    with $FutureModifier<Topic>, $FutureProvider<Topic> {
  const TopicByIdProvider._({
    required TopicByIdFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'topicByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$topicByIdHash();

  @override
  String toString() {
    return r'topicByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Topic> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Topic> create(Ref ref) {
    final argument = this.argument as int;
    return topicById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TopicByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$topicByIdHash() => r'e08abcd4f123413ff358e6409f955c67b4f72d39';

final class TopicByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Topic>, int> {
  const TopicByIdFamily._()
    : super(
        retry: null,
        name: r'topicByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TopicByIdProvider call(int topicId) =>
      TopicByIdProvider._(argument: topicId, from: this);

  @override
  String toString() => r'topicByIdProvider';
}

@ProviderFor(topicsForAyah)
const topicsForAyahProvider = TopicsForAyahFamily._();

final class TopicsForAyahProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Topic>>,
          List<Topic>,
          FutureOr<List<Topic>>
        >
    with $FutureModifier<List<Topic>>, $FutureProvider<List<Topic>> {
  const TopicsForAyahProvider._({
    required TopicsForAyahFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'topicsForAyahProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$topicsForAyahHash();

  @override
  String toString() {
    return r'topicsForAyahProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Topic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Topic>> create(Ref ref) {
    final argument = this.argument as (int, int);
    return topicsForAyah(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is TopicsForAyahProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$topicsForAyahHash() => r'4e569e1cbf758b733105b5ff5f67f703f52f7ecc';

final class TopicsForAyahFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Topic>>, (int, int)> {
  const TopicsForAyahFamily._()
    : super(
        retry: null,
        name: r'topicsForAyahProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TopicsForAyahProvider call(int surahNumber, int ayahNumber) =>
      TopicsForAyahProvider._(argument: (surahNumber, ayahNumber), from: this);

  @override
  String toString() => r'topicsForAyahProvider';
}

@ProviderFor(versesForTopic)
const versesForTopicProvider = VersesForTopicFamily._();

final class VersesForTopicProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VerseReference>>,
          List<VerseReference>,
          FutureOr<List<VerseReference>>
        >
    with
        $FutureModifier<List<VerseReference>>,
        $FutureProvider<List<VerseReference>> {
  const VersesForTopicProvider._({
    required VersesForTopicFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'versesForTopicProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$versesForTopicHash();

  @override
  String toString() {
    return r'versesForTopicProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<VerseReference>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<VerseReference>> create(Ref ref) {
    final argument = this.argument as int;
    return versesForTopic(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is VersesForTopicProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$versesForTopicHash() => r'148f93263c3b2064a4d539a4d3d02136d14cc827';

final class VersesForTopicFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<VerseReference>>, int> {
  const VersesForTopicFamily._()
    : super(
        retry: null,
        name: r'versesForTopicProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  VersesForTopicProvider call(int topicId) =>
      VersesForTopicProvider._(argument: topicId, from: this);

  @override
  String toString() => r'versesForTopicProvider';
}

@ProviderFor(relatedTopics)
const relatedTopicsProvider = RelatedTopicsFamily._();

final class RelatedTopicsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Topic>>,
          List<Topic>,
          FutureOr<List<Topic>>
        >
    with $FutureModifier<List<Topic>>, $FutureProvider<List<Topic>> {
  const RelatedTopicsProvider._({
    required RelatedTopicsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'relatedTopicsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$relatedTopicsHash();

  @override
  String toString() {
    return r'relatedTopicsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Topic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Topic>> create(Ref ref) {
    final argument = this.argument as int;
    return relatedTopics(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RelatedTopicsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$relatedTopicsHash() => r'05514a56bdf32924cdced8c76df6b1e088912613';

final class RelatedTopicsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Topic>>, int> {
  const RelatedTopicsFamily._()
    : super(
        retry: null,
        name: r'relatedTopicsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RelatedTopicsProvider call(int sourceTopicId) =>
      RelatedTopicsProvider._(argument: sourceTopicId, from: this);

  @override
  String toString() => r'relatedTopicsProvider';
}

@ProviderFor(rootTopics)
const rootTopicsProvider = RootTopicsProvider._();

final class RootTopicsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Topic>>,
          List<Topic>,
          FutureOr<List<Topic>>
        >
    with $FutureModifier<List<Topic>>, $FutureProvider<List<Topic>> {
  const RootTopicsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rootTopicsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rootTopicsHash();

  @$internal
  @override
  $FutureProviderElement<List<Topic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Topic>> create(Ref ref) {
    return rootTopics(ref);
  }
}

String _$rootTopicsHash() => r'a62d217d1c3232c0d7864f0c1e4a5ee232d81d41';

@ProviderFor(rootTopicsByHierarchy)
const rootTopicsByHierarchyProvider = RootTopicsByHierarchyFamily._();

final class RootTopicsByHierarchyProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Topic>>,
          List<Topic>,
          FutureOr<List<Topic>>
        >
    with $FutureModifier<List<Topic>>, $FutureProvider<List<Topic>> {
  const RootTopicsByHierarchyProvider._({
    required RootTopicsByHierarchyFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'rootTopicsByHierarchyProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rootTopicsByHierarchyHash();

  @override
  String toString() {
    return r'rootTopicsByHierarchyProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Topic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Topic>> create(Ref ref) {
    final argument = this.argument as bool;
    return rootTopicsByHierarchy(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RootTopicsByHierarchyProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rootTopicsByHierarchyHash() =>
    r'78b7c0f8302edb11793023ef5bd64153ee1b5fb8';

final class RootTopicsByHierarchyFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Topic>>, bool> {
  const RootTopicsByHierarchyFamily._()
    : super(
        retry: null,
        name: r'rootTopicsByHierarchyProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  RootTopicsByHierarchyProvider call(bool thematic) =>
      RootTopicsByHierarchyProvider._(argument: thematic, from: this);

  @override
  String toString() => r'rootTopicsByHierarchyProvider';
}

@ProviderFor(childTopics)
const childTopicsProvider = ChildTopicsFamily._();

final class ChildTopicsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Topic>>,
          List<Topic>,
          FutureOr<List<Topic>>
        >
    with $FutureModifier<List<Topic>>, $FutureProvider<List<Topic>> {
  const ChildTopicsProvider._({
    required ChildTopicsFamily super.from,
    required (int, bool) super.argument,
  }) : super(
         retry: null,
         name: r'childTopicsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$childTopicsHash();

  @override
  String toString() {
    return r'childTopicsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Topic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Topic>> create(Ref ref) {
    final argument = this.argument as (int, bool);
    return childTopics(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ChildTopicsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$childTopicsHash() => r'd18cd5f49baab9da4ae4aeba6205376518f72816';

final class ChildTopicsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Topic>>, (int, bool)> {
  const ChildTopicsFamily._()
    : super(
        retry: null,
        name: r'childTopicsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChildTopicsProvider call(int topicId, bool thematic) =>
      ChildTopicsProvider._(argument: (topicId, thematic), from: this);

  @override
  String toString() => r'childTopicsProvider';
}

@ProviderFor(searchTopics)
const searchTopicsProvider = SearchTopicsFamily._();

final class SearchTopicsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Topic>>,
          List<Topic>,
          FutureOr<List<Topic>>
        >
    with $FutureModifier<List<Topic>>, $FutureProvider<List<Topic>> {
  const SearchTopicsProvider._({
    required SearchTopicsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchTopicsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchTopicsHash();

  @override
  String toString() {
    return r'searchTopicsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Topic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Topic>> create(Ref ref) {
    final argument = this.argument as String;
    return searchTopics(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchTopicsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchTopicsHash() => r'c243dc4d6971e08e070920c4d9407eb4ebb79cfe';

final class SearchTopicsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Topic>>, String> {
  const SearchTopicsFamily._()
    : super(
        retry: null,
        name: r'searchTopicsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchTopicsProvider call(String query) =>
      SearchTopicsProvider._(argument: query, from: this);

  @override
  String toString() => r'searchTopicsProvider';
}

@ProviderFor(audioService)
const audioServiceProvider = AudioServiceProvider._();

final class AudioServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<AudioService>,
          AudioService,
          FutureOr<AudioService>
        >
    with $FutureModifier<AudioService>, $FutureProvider<AudioService> {
  const AudioServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioServiceHash();

  @$internal
  @override
  $FutureProviderElement<AudioService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AudioService> create(Ref ref) {
    return audioService(ref);
  }
}

String _$audioServiceHash() => r'f1e443368f920a7836226a184b56436971806473';

@ProviderFor(AudioStateNotifier)
const audioStateProvider = AudioStateNotifierProvider._();

final class AudioStateNotifierProvider
    extends $NotifierProvider<AudioStateNotifier, AudioState> {
  const AudioStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'audioStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$audioStateNotifierHash();

  @$internal
  @override
  AudioStateNotifier create() => AudioStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AudioState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AudioState>(value),
    );
  }
}

String _$audioStateNotifierHash() =>
    r'e8c3a5214b2064d861372a59de9fcb3dfc3f8f00';

abstract class _$AudioStateNotifier extends $Notifier<AudioState> {
  AudioState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AudioState, AudioState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AudioState, AudioState>,
              AudioState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
