// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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

@ProviderFor(databaseService)
const databaseServiceProvider = DatabaseServiceProvider._();

final class DatabaseServiceProvider
    extends
        $FunctionalProvider<DatabaseService, DatabaseService, DatabaseService>
    with $Provider<DatabaseService> {
  const DatabaseServiceProvider._()
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
  String debugGetCreateSourceHash() => _$databaseServiceHash();

  @$internal
  @override
  $ProviderElement<DatabaseService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DatabaseService create(Ref ref) {
    return databaseService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DatabaseService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DatabaseService>(value),
    );
  }
}

String _$databaseServiceHash() => r'323927c4138725be4427216964fece6d70043b46';

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

String _$pageDataHash() => r'07f5ba651c22a869e1aed06957dd48d6eda9a3b9';

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

String _$surahListHash() => r'34e7a323a4b57d7319eb30ae63696ca059f73eb5';

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

String _$juzListHash() => r'7a13b0b3bab83527732a93f6f0e8fe45f0698fca';

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

String _$pagePreviewHash() => r'c565a25b480e011bf067281ca5785eb84383a9f3';

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

String _$pageFontFamilyHash() => r'15d7834df90b4dd3d7c52c440a95fbe86b9a4f3e';

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

String _$selectionTabIndexHash() => r'1c04c273ee33cbe2d5543511691a69512c93d9f1';

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
