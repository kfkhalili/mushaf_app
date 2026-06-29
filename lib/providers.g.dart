// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

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
  SharedPreferencesProvider._()
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

@ProviderFor(MemorizationIconFlash)
final memorizationIconFlashProvider = MemorizationIconFlashProvider._();

final class MemorizationIconFlashProvider
    extends $NotifierProvider<MemorizationIconFlash, int> {
  MemorizationIconFlashProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memorizationIconFlashProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memorizationIconFlashHash();

  @$internal
  @override
  MemorizationIconFlash create() => MemorizationIconFlash();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$memorizationIconFlashHash() =>
    r'261594977c16e8eac13d2b38596ff22613275dd0';

abstract class _$MemorizationIconFlash extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(appDataService)
final appDataServiceProvider = AppDataServiceProvider._();

final class AppDataServiceProvider
    extends $FunctionalProvider<AppDataService, AppDataService, AppDataService>
    with $Provider<AppDataService> {
  AppDataServiceProvider._()
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
final currentPageProvider = CurrentPageProvider._();

final class CurrentPageProvider extends $NotifierProvider<CurrentPage, int> {
  CurrentPageProvider._()
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

String _$currentPageHash() => r'24e6c34cafe3c631741e2249179112e464c19cdd';

abstract class _$CurrentPage extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(DatabaseServiceNotifier)
final databaseServiceProvider = DatabaseServiceNotifierProvider._();

final class DatabaseServiceNotifierProvider
    extends $AsyncNotifierProvider<DatabaseServiceNotifier, DatabaseService> {
  DatabaseServiceNotifierProvider._()
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
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DatabaseService>, DatabaseService>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DatabaseService>, DatabaseService>,
              AsyncValue<DatabaseService>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(fontService)
final fontServiceProvider = FontServiceProvider._();

final class FontServiceProvider
    extends $FunctionalProvider<FontService, FontService, FontService>
    with $Provider<FontService> {
  FontServiceProvider._()
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
final pageDataProvider = PageDataFamily._();

final class PageDataProvider
    extends
        $FunctionalProvider<AsyncValue<PageData>, PageData, FutureOr<PageData>>
    with $FutureModifier<PageData>, $FutureProvider<PageData> {
  PageDataProvider._({
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
  PageDataFamily._()
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
final surahListProvider = SurahListProvider._();

final class SurahListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SurahInfo>>,
          List<SurahInfo>,
          FutureOr<List<SurahInfo>>
        >
    with $FutureModifier<List<SurahInfo>>, $FutureProvider<List<SurahInfo>> {
  SurahListProvider._()
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
final juzListProvider = JuzListProvider._();

final class JuzListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<JuzInfo>>,
          List<JuzInfo>,
          FutureOr<List<JuzInfo>>
        >
    with $FutureModifier<List<JuzInfo>>, $FutureProvider<List<JuzInfo>> {
  JuzListProvider._()
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

@ProviderFor(totalPages)
final totalPagesProvider = TotalPagesProvider._();

final class TotalPagesProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  TotalPagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalPagesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalPagesHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return totalPages(ref);
  }
}

String _$totalPagesHash() => r'bcef078e4b884a0b80697856c948bef2bbbde496';

@ProviderFor(layoutInfo)
final layoutInfoProvider = LayoutInfoProvider._();

final class LayoutInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<LayoutInfo>,
          LayoutInfo,
          FutureOr<LayoutInfo>
        >
    with $FutureModifier<LayoutInfo>, $FutureProvider<LayoutInfo> {
  LayoutInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'layoutInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$layoutInfoHash();

  @$internal
  @override
  $FutureProviderElement<LayoutInfo> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<LayoutInfo> create(Ref ref) {
    return layoutInfo(ref);
  }
}

String _$layoutInfoHash() => r'38d5ff4d9b5bd8f97e36bd1c34e75d329b302b61';

@ProviderFor(allLayoutsInfo)
final allLayoutsInfoProvider = AllLayoutsInfoProvider._();

final class AllLayoutsInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<MushafLayout, LayoutInfo>>,
          Map<MushafLayout, LayoutInfo>,
          FutureOr<Map<MushafLayout, LayoutInfo>>
        >
    with
        $FutureModifier<Map<MushafLayout, LayoutInfo>>,
        $FutureProvider<Map<MushafLayout, LayoutInfo>> {
  AllLayoutsInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allLayoutsInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allLayoutsInfoHash();

  @$internal
  @override
  $FutureProviderElement<Map<MushafLayout, LayoutInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<MushafLayout, LayoutInfo>> create(Ref ref) {
    return allLayoutsInfo(ref);
  }
}

String _$allLayoutsInfoHash() => r'328b77292e0ab322e32929db7d8ab8df8170fe4c';

@ProviderFor(pagePreview)
final pagePreviewProvider = PagePreviewFamily._();

final class PagePreviewProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  PagePreviewProvider._({
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
  PagePreviewFamily._()
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
final pageFontFamilyProvider = PageFontFamilyFamily._();

final class PageFontFamilyProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  PageFontFamilyProvider._({
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
  PageFontFamilyFamily._()
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

@ProviderFor(commonFont)
final commonFontProvider = CommonFontProvider._();

final class CommonFontProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  CommonFontProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commonFontProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commonFontHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return commonFont(ref);
  }
}

String _$commonFontHash() => r'714b4ac7aed5414952951aab64739d03dd7c80a4';

@ProviderFor(pagePreviewWithFont)
final pagePreviewWithFontProvider = PagePreviewWithFontFamily._();

final class PagePreviewWithFontProvider
    extends
        $FunctionalProvider<
          AsyncValue<(String, String)>,
          (String, String),
          FutureOr<(String, String)>
        >
    with $FutureModifier<(String, String)>, $FutureProvider<(String, String)> {
  PagePreviewWithFontProvider._({
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
  PagePreviewWithFontFamily._()
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
final selectionTabIndexProvider = SelectionTabIndexProvider._();

final class SelectionTabIndexProvider
    extends $NotifierProvider<SelectionTabIndex, int> {
  SelectionTabIndexProvider._()
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
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(MushafLayoutSetting)
final mushafLayoutSettingProvider = MushafLayoutSettingProvider._();

final class MushafLayoutSettingProvider
    extends $NotifierProvider<MushafLayoutSetting, MushafLayout> {
  MushafLayoutSettingProvider._()
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
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MushafLayout, MushafLayout>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MushafLayout, MushafLayout>,
              MushafLayout,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(FontSizeSetting)
final fontSizeSettingProvider = FontSizeSettingProvider._();

final class FontSizeSettingProvider
    extends $NotifierProvider<FontSizeSetting, double> {
  FontSizeSettingProvider._()
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
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<double, double>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double, double>,
              double,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(recitationRange)
final recitationRangeProvider = RecitationRangeProvider._();

final class RecitationRangeProvider
    extends
        $FunctionalProvider<
          AsyncValue<RecitationRange>,
          RecitationRange,
          FutureOr<RecitationRange>
        >
    with $FutureModifier<RecitationRange>, $FutureProvider<RecitationRange> {
  RecitationRangeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recitationRangeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recitationRangeHash();

  @$internal
  @override
  $FutureProviderElement<RecitationRange> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RecitationRange> create(Ref ref) {
    return recitationRange(ref);
  }
}

String _$recitationRangeHash() => r'351aa8858987f15c3e21d9e0f07074d8650f9a95';

@ProviderFor(searchService)
final searchServiceProvider = SearchServiceProvider._();

final class SearchServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<SearchService>,
          SearchService,
          FutureOr<SearchService>
        >
    with $FutureModifier<SearchService>, $FutureProvider<SearchService> {
  SearchServiceProvider._()
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
final searchQueryProvider = SearchQueryProvider._();

final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  SearchQueryProvider._()
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
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(searchOutcome)
final searchOutcomeProvider = SearchOutcomeFamily._();

final class SearchOutcomeProvider
    extends
        $FunctionalProvider<
          AsyncValue<SearchOutcome>,
          SearchOutcome,
          FutureOr<SearchOutcome>
        >
    with $FutureModifier<SearchOutcome>, $FutureProvider<SearchOutcome> {
  SearchOutcomeProvider._({
    required SearchOutcomeFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchOutcomeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchOutcomeHash();

  @override
  String toString() {
    return r'searchOutcomeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SearchOutcome> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SearchOutcome> create(Ref ref) {
    final argument = this.argument as String;
    return searchOutcome(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchOutcomeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchOutcomeHash() => r'd095e0d8e0d13c1bf35e7e89cc50ca390e7de88d';

final class SearchOutcomeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SearchOutcome>, String> {
  SearchOutcomeFamily._()
    : super(
        retry: null,
        name: r'searchOutcomeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchOutcomeProvider call(String query) =>
      SearchOutcomeProvider._(argument: query, from: this);

  @override
  String toString() => r'searchOutcomeProvider';
}

@ProviderFor(searchResults)
final searchResultsProvider = SearchResultsFamily._();

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
  SearchResultsProvider._({
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

String _$searchResultsHash() => r'de1b6c19d81138c3ffb466f03a54c2641a744329';

final class SearchResultsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<SearchResult>>, String> {
  SearchResultsFamily._()
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

@ProviderFor(searchTruncated)
final searchTruncatedProvider = SearchTruncatedFamily._();

final class SearchTruncatedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  SearchTruncatedProvider._({
    required SearchTruncatedFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchTruncatedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchTruncatedHash();

  @override
  String toString() {
    return r'searchTruncatedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return searchTruncated(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchTruncatedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchTruncatedHash() => r'3c373c3653a6101bd8ced6ed1653c415838f7992';

final class SearchTruncatedFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  SearchTruncatedFamily._()
    : super(
        retry: null,
        name: r'searchTruncatedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SearchTruncatedProvider call(String query) =>
      SearchTruncatedProvider._(argument: query, from: this);

  @override
  String toString() => r'searchTruncatedProvider';
}

@ProviderFor(SearchHistory)
final searchHistoryProvider = SearchHistoryProvider._();

final class SearchHistoryProvider
    extends $NotifierProvider<SearchHistory, List<String>> {
  SearchHistoryProvider._()
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
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(bookmarksService)
final bookmarksServiceProvider = BookmarksServiceProvider._();

final class BookmarksServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<BookmarksService>,
          BookmarksService,
          FutureOr<BookmarksService>
        >
    with $FutureModifier<BookmarksService>, $FutureProvider<BookmarksService> {
  BookmarksServiceProvider._()
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
final isAyahBookmarkedProvider = IsAyahBookmarkedFamily._();

final class IsAyahBookmarkedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  IsAyahBookmarkedProvider._({
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
  IsAyahBookmarkedFamily._()
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
final bookmarksProvider = BookmarksNotifierProvider._();

final class BookmarksNotifierProvider
    extends $AsyncNotifierProvider<BookmarksNotifier, List<Bookmark>> {
  BookmarksNotifierProvider._()
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
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Bookmark>>, List<Bookmark>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Bookmark>>, List<Bookmark>>,
              AsyncValue<List<Bookmark>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(pageDataWithBookmarks)
final pageDataWithBookmarksProvider = PageDataWithBookmarksFamily._();

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
  PageDataWithBookmarksProvider._({
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
  PageDataWithBookmarksFamily._()
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
final bookmarkPageNumberProvider = BookmarkPageNumberFamily._();

final class BookmarkPageNumberProvider
    extends $FunctionalProvider<AsyncValue<int?>, int?, FutureOr<int?>>
    with $FutureModifier<int?>, $FutureProvider<int?> {
  BookmarkPageNumberProvider._({
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
  BookmarkPageNumberFamily._()
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
final readingProgressServiceProvider = ReadingProgressServiceProvider._();

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
  ReadingProgressServiceProvider._()
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
    r'cbb770ea3b372dddb792cad1472b25de37f2c52d';

@ProviderFor(readingStatistics)
final readingStatisticsProvider = ReadingStatisticsProvider._();

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
  ReadingStatisticsProvider._()
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
final pagesReadTodayProvider = PagesReadTodayProvider._();

final class PagesReadTodayProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  PagesReadTodayProvider._()
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
final currentStreakProvider = CurrentStreakProvider._();

final class CurrentStreakProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  CurrentStreakProvider._()
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
final primaryColorProvider = PrimaryColorNotifierProvider._();

final class PrimaryColorNotifierProvider
    extends $NotifierProvider<PrimaryColorNotifier, int> {
  PrimaryColorNotifierProvider._()
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
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ThemeNotifier)
final themeProvider = ThemeNotifierProvider._();

final class ThemeNotifierProvider
    extends $NotifierProvider<ThemeNotifier, AppThemeMode> {
  ThemeNotifierProvider._()
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

String _$themeNotifierHash() => r'e80ee15dcb13e0a3da3594cdb11b233d957feab2';

abstract class _$ThemeNotifier extends $Notifier<AppThemeMode> {
  AppThemeMode build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppThemeMode, AppThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppThemeMode, AppThemeMode>,
              AppThemeMode,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(MemorizationSessionNotifier)
final memorizationSessionProvider = MemorizationSessionNotifierProvider._();

final class MemorizationSessionNotifierProvider
    extends
        $NotifierProvider<
          MemorizationSessionNotifier,
          MemorizationSessionState?
        > {
  MemorizationSessionNotifierProvider._()
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
    r'7c69dd070ebbe321fa1d84985ae85402c54d9547';

abstract class _$MemorizationSessionNotifier
    extends $Notifier<MemorizationSessionState?> {
  MemorizationSessionState? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
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
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(OntologyServiceNotifier)
final ontologyServiceProvider = OntologyServiceNotifierProvider._();

final class OntologyServiceNotifierProvider
    extends $AsyncNotifierProvider<OntologyServiceNotifier, OntologyService> {
  OntologyServiceNotifierProvider._()
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
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<OntologyService>, OntologyService>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<OntologyService>, OntologyService>,
              AsyncValue<OntologyService>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(TafsirServiceNotifier)
final tafsirServiceProvider = TafsirServiceNotifierProvider._();

final class TafsirServiceNotifierProvider
    extends $AsyncNotifierProvider<TafsirServiceNotifier, TafsirService> {
  TafsirServiceNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tafsirServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tafsirServiceNotifierHash();

  @$internal
  @override
  TafsirServiceNotifier create() => TafsirServiceNotifier();
}

String _$tafsirServiceNotifierHash() =>
    r'facdc970411618aeae936022d2f76ab1cdff80d7';

abstract class _$TafsirServiceNotifier extends $AsyncNotifier<TafsirService> {
  FutureOr<TafsirService> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TafsirService>, TafsirService>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TafsirService>, TafsirService>,
              AsyncValue<TafsirService>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(topicById)
final topicByIdProvider = TopicByIdFamily._();

final class TopicByIdProvider
    extends $FunctionalProvider<AsyncValue<Topic>, Topic, FutureOr<Topic>>
    with $FutureModifier<Topic>, $FutureProvider<Topic> {
  TopicByIdProvider._({
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
  TopicByIdFamily._()
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

@ProviderFor(ayahText)
final ayahTextProvider = AyahTextFamily._();

final class AyahTextProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  AyahTextProvider._({
    required AyahTextFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'ayahTextProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ayahTextHash();

  @override
  String toString() {
    return r'ayahTextProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as (int, int);
    return ayahText(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is AyahTextProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ayahTextHash() => r'bd72f6bf15e4ebfd0319a8d80158a8890b48f01d';

final class AyahTextFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, (int, int)> {
  AyahTextFamily._()
    : super(
        retry: null,
        name: r'ayahTextProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AyahTextProvider call(int surahNumber, int ayahNumber) =>
      AyahTextProvider._(argument: (surahNumber, ayahNumber), from: this);

  @override
  String toString() => r'ayahTextProvider';
}

@ProviderFor(ayahWords)
final ayahWordsProvider = AyahWordsFamily._();

final class AyahWordsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Word>>,
          List<Word>,
          FutureOr<List<Word>>
        >
    with $FutureModifier<List<Word>>, $FutureProvider<List<Word>> {
  AyahWordsProvider._({
    required AyahWordsFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'ayahWordsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ayahWordsHash();

  @override
  String toString() {
    return r'ayahWordsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Word>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Word>> create(Ref ref) {
    final argument = this.argument as (int, int);
    return ayahWords(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is AyahWordsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ayahWordsHash() => r'2b4a49a370e34adfc69097f4abf032d9a41fc420';

final class AyahWordsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Word>>, (int, int)> {
  AyahWordsFamily._()
    : super(
        retry: null,
        name: r'ayahWordsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AyahWordsProvider call(int surahNumber, int ayahNumber) =>
      AyahWordsProvider._(argument: (surahNumber, ayahNumber), from: this);

  @override
  String toString() => r'ayahWordsProvider';
}

@ProviderFor(ayahDisplayData)
final ayahDisplayDataProvider = AyahDisplayDataFamily._();

final class AyahDisplayDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<({String fontFamily, int pageNumber, List<Word> words})>,
          ({String fontFamily, int pageNumber, List<Word> words}),
          FutureOr<({String fontFamily, int pageNumber, List<Word> words})>
        >
    with
        $FutureModifier<
          ({String fontFamily, int pageNumber, List<Word> words})
        >,
        $FutureProvider<
          ({String fontFamily, int pageNumber, List<Word> words})
        > {
  AyahDisplayDataProvider._({
    required AyahDisplayDataFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'ayahDisplayDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$ayahDisplayDataHash();

  @override
  String toString() {
    return r'ayahDisplayDataProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<
    ({String fontFamily, int pageNumber, List<Word> words})
  >
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<({String fontFamily, int pageNumber, List<Word> words})> create(
    Ref ref,
  ) {
    final argument = this.argument as (int, int);
    return ayahDisplayData(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is AyahDisplayDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$ayahDisplayDataHash() => r'368870179a7a70bc616229bc3de1ed6647dee87d';

final class AyahDisplayDataFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<({String fontFamily, int pageNumber, List<Word> words})>,
          (int, int)
        > {
  AyahDisplayDataFamily._()
    : super(
        retry: null,
        name: r'ayahDisplayDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AyahDisplayDataProvider call(int surahNumber, int ayahNumber) =>
      AyahDisplayDataProvider._(
        argument: (surahNumber, ayahNumber),
        from: this,
      );

  @override
  String toString() => r'ayahDisplayDataProvider';
}

@ProviderFor(surahName)
final surahNameProvider = SurahNameFamily._();

final class SurahNameProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  SurahNameProvider._({
    required SurahNameFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'surahNameProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$surahNameHash();

  @override
  String toString() {
    return r'surahNameProvider'
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
    return surahName(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SurahNameProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$surahNameHash() => r'67a16e9ed606746bb0d964a27086bb6afe1f4662';

final class SurahNameFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, int> {
  SurahNameFamily._()
    : super(
        retry: null,
        name: r'surahNameProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SurahNameProvider call(int surahNumber) =>
      SurahNameProvider._(argument: surahNumber, from: this);

  @override
  String toString() => r'surahNameProvider';
}

@ProviderFor(tafsir)
final tafsirProvider = TafsirFamily._();

final class TafsirProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  TafsirProvider._({
    required TafsirFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'tafsirProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tafsirHash();

  @override
  String toString() {
    return r'tafsirProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as (int, int);
    return tafsir(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is TafsirProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tafsirHash() => r'9beaadd54a4db02a7de684a0f9f243a2242b268f';

final class TafsirFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, (int, int)> {
  TafsirFamily._()
    : super(
        retry: null,
        name: r'tafsirProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TafsirProvider call(int surahNumber, int ayahNumber) =>
      TafsirProvider._(argument: (surahNumber, ayahNumber), from: this);

  @override
  String toString() => r'tafsirProvider';
}

@ProviderFor(previousAyah)
final previousAyahProvider = PreviousAyahFamily._();

final class PreviousAyahProvider
    extends
        $FunctionalProvider<
          AsyncValue<({int ayahNumber, int surahNumber})?>,
          ({int ayahNumber, int surahNumber})?,
          FutureOr<({int ayahNumber, int surahNumber})?>
        >
    with
        $FutureModifier<({int ayahNumber, int surahNumber})?>,
        $FutureProvider<({int ayahNumber, int surahNumber})?> {
  PreviousAyahProvider._({
    required PreviousAyahFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'previousAyahProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$previousAyahHash();

  @override
  String toString() {
    return r'previousAyahProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<({int ayahNumber, int surahNumber})?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<({int ayahNumber, int surahNumber})?> create(Ref ref) {
    final argument = this.argument as (int, int);
    return previousAyah(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is PreviousAyahProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$previousAyahHash() => r'4050ce2ed5d8a45b4ccbd9a8bda979cdfc728cd2';

final class PreviousAyahFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<({int ayahNumber, int surahNumber})?>,
          (int, int)
        > {
  PreviousAyahFamily._()
    : super(
        retry: null,
        name: r'previousAyahProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PreviousAyahProvider call(int surahNumber, int ayahNumber) =>
      PreviousAyahProvider._(argument: (surahNumber, ayahNumber), from: this);

  @override
  String toString() => r'previousAyahProvider';
}

@ProviderFor(nextAyah)
final nextAyahProvider = NextAyahFamily._();

final class NextAyahProvider
    extends
        $FunctionalProvider<
          AsyncValue<({int ayahNumber, int surahNumber})?>,
          ({int ayahNumber, int surahNumber})?,
          FutureOr<({int ayahNumber, int surahNumber})?>
        >
    with
        $FutureModifier<({int ayahNumber, int surahNumber})?>,
        $FutureProvider<({int ayahNumber, int surahNumber})?> {
  NextAyahProvider._({
    required NextAyahFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'nextAyahProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nextAyahHash();

  @override
  String toString() {
    return r'nextAyahProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<({int ayahNumber, int surahNumber})?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<({int ayahNumber, int surahNumber})?> create(Ref ref) {
    final argument = this.argument as (int, int);
    return nextAyah(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is NextAyahProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nextAyahHash() => r'33ebb9be6bfe90a3ab4080ca84965944e0c14a2f';

final class NextAyahFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<({int ayahNumber, int surahNumber})?>,
          (int, int)
        > {
  NextAyahFamily._()
    : super(
        retry: null,
        name: r'nextAyahProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  NextAyahProvider call(int surahNumber, int ayahNumber) =>
      NextAyahProvider._(argument: (surahNumber, ayahNumber), from: this);

  @override
  String toString() => r'nextAyahProvider';
}

@ProviderFor(topicsForAyah)
final topicsForAyahProvider = TopicsForAyahFamily._();

final class TopicsForAyahProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Topic>>,
          List<Topic>,
          FutureOr<List<Topic>>
        >
    with $FutureModifier<List<Topic>>, $FutureProvider<List<Topic>> {
  TopicsForAyahProvider._({
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
  TopicsForAyahFamily._()
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
final versesForTopicProvider = VersesForTopicFamily._();

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
  VersesForTopicProvider._({
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
  VersesForTopicFamily._()
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
final relatedTopicsProvider = RelatedTopicsFamily._();

final class RelatedTopicsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Topic>>,
          List<Topic>,
          FutureOr<List<Topic>>
        >
    with $FutureModifier<List<Topic>>, $FutureProvider<List<Topic>> {
  RelatedTopicsProvider._({
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
  RelatedTopicsFamily._()
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
final rootTopicsProvider = RootTopicsProvider._();

final class RootTopicsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Topic>>,
          List<Topic>,
          FutureOr<List<Topic>>
        >
    with $FutureModifier<List<Topic>>, $FutureProvider<List<Topic>> {
  RootTopicsProvider._()
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
final rootTopicsByHierarchyProvider = RootTopicsByHierarchyFamily._();

final class RootTopicsByHierarchyProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Topic>>,
          List<Topic>,
          FutureOr<List<Topic>>
        >
    with $FutureModifier<List<Topic>>, $FutureProvider<List<Topic>> {
  RootTopicsByHierarchyProvider._({
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
  RootTopicsByHierarchyFamily._()
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
final childTopicsProvider = ChildTopicsFamily._();

final class ChildTopicsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Topic>>,
          List<Topic>,
          FutureOr<List<Topic>>
        >
    with $FutureModifier<List<Topic>>, $FutureProvider<List<Topic>> {
  ChildTopicsProvider._({
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
  ChildTopicsFamily._()
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
final searchTopicsProvider = SearchTopicsFamily._();

final class SearchTopicsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Topic>>,
          List<Topic>,
          FutureOr<List<Topic>>
        >
    with $FutureModifier<List<Topic>>, $FutureProvider<List<Topic>> {
  SearchTopicsProvider._({
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
  SearchTopicsFamily._()
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
final audioServiceProvider = AudioServiceProvider._();

final class AudioServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<AudioService>,
          AudioService,
          FutureOr<AudioService>
        >
    with $FutureModifier<AudioService>, $FutureProvider<AudioService> {
  AudioServiceProvider._()
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
final audioStateProvider = AudioStateNotifierProvider._();

final class AudioStateNotifierProvider
    extends $NotifierProvider<AudioStateNotifier, AudioState> {
  AudioStateNotifierProvider._()
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
    r'd73016b757a098cca635302b2e01c548e11e44ad';

abstract class _$AudioStateNotifier extends $Notifier<AudioState> {
  AudioState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AudioState, AudioState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AudioState, AudioState>,
              AudioState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
