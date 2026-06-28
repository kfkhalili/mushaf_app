# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`mushaf_app` is a Flutter Quran (Mushaf) reader supporting iOS, Android, web, macOS, Windows, and Linux. It renders the Quran page-by-page (604 pages) with authentic typography, plus search, bookmarks, reading-progress stats, audio recitation, tafsir, a topic/ontology explorer, and a memorization mode. All Quran data ships as bundled read-only SQLite databases; no backend.

Fixed configuration constants: multiple bundled DBs, 604 page-specific Uthmani fonts, 3 themes (light/dark/sepia), portrait-only orientation, RTL by default. Total page count is layout-specific — read at runtime from each layout's `info` table via `getTotalPages()` (Uthmani 604, Indopak 849, Indopak 9-line 1890); `totalPages = 604` is only a fallback.

## Commands

```bash
flutter pub get                                              # install deps
dart run build_runner build --delete-conflicting-outputs    # regenerate providers.g.dart (REQUIRED after editing providers.dart)

flutter analyze                                              # static analysis (must be clean)
dart format .                                                # format (pre-commit runs --set-exit-if-changed)

flutter test                                                 # all unit + widget tests
flutter test test/services/database_service_test.dart       # single file
flutter test --plain-name "loads page layout"               # single test by name
flutter test test/golden/                                    # golden / visual-regression tests
flutter test test/golden/ --update-goldens                  # regenerate goldens after an INTENTIONAL UI change
flutter test integration_test/                              # E2E (runs on a device/simulator)
flutter test --coverage && ./scripts/check-coverage.sh      # coverage vs .coverage_threshold.json (70/70/65)

bash scripts/install-hooks.sh                                # install pre-commit / pre-push hooks
```

Tests run sequentially (`dart_test.yaml` sets `concurrency: 1`) because they share on-disk SQLite databases — do not parallelize. Golden tests are tagged `golden` and excluded from the default CI test run.

## Code generation

`lib/providers.dart` is the single source for Riverpod codegen; `lib/providers.g.dart` is generated and **must be regenerated** after any change to provider declarations:

```bash
dart run build_runner build --delete-conflicting-outputs
```

A stale `.g.dart` breaks the build. CI runs `build_runner` before analyzing/testing, so it won't be caught locally unless you regenerate.

## Architecture

**Single-file core (intentional, for codegen + discoverability).** Top-level state and config live in flat files, not directories:
- `lib/main.dart` — app entry point; portrait-only orientation lock; wraps the tree in `Directionality(TextDirection.rtl)`; loads saved theme.
- `lib/constants.dart` — ALL constants: `DbConstants` (table/column names), DB filenames, `MushafLayout` enum, font family names, `totalPages = 604`, `initialWordCount = 15` (memorization), the Basmallah glyph (`basmallah = '﷽'`), responsive sizing, and styling multipliers/bounds/padding. Never hardcode a table/column name or magic number — add or reuse a constant here.
- `lib/models.dart` — immutable data models (`Word`, `LineInfo`, `PageLayout`, `PageData`, …). All `@immutable` with value equality.
- `lib/providers.dart` — every Riverpod provider in the app (centralized; do NOT create a `lib/providers/` directory).
- `lib/themes.dart` — `buildLightTheme` / `buildDarkTheme` / `buildSepiaTheme`.

**Layers:** `screens/` (full-page navigation targets: `splash_screen.dart`, `mushaf_screen.dart`, `selection_screen.dart`, …) → `widgets/` (reusable UI, e.g. `mushaf_page_widget.dart`, `line_widget.dart`, `mushaf_navigation.dart`, `mushaf_bottom_menu.dart`; `widgets/shared/` for cross-screen scaffolding like `base_screen.dart`, `app_header.dart`, `async_value_builder.dart`) → `providers.dart` → `services/` (`database_service.dart`, `font_service.dart`, data access only) → bundled SQLite. `utils/` holds cross-cutting helpers (validation, parsing, caching, mixins). Isolate all database and font operations in the service layer.

**Data flow.** Services are obtained through `keepAlive` async provider notifiers (e.g. `databaseServiceProvider`); page/ayah data flows through auto-disposing `@riverpod` providers (e.g. `pageDataProvider(pageNumber)`). Consume async service providers with `await ref.watch(xProvider.future)`. `DatabaseServiceNotifier` rebuilds and reopens databases when `mushafLayoutSettingProvider` changes, closing the previous service on dispose.

**Databases.** Many read-only SQLite files in `assets/db/` (layout, script, metadata, tafsir, topics, recitation — see `pubspec.yaml` assets and `constants.dart` for the authoritative list; e.g. `uthmani-15-lines.db`, `qpc-v2.db`, `quran-metadata-*.sqlite`). At startup each is copied from assets into the app documents dir (skip if the destination already exists), then opened read-only via `sqflite`:

```dart
final dbFile = File(destinationPath);
if (await dbFile.exists()) return; // skip if already copied
final ByteData data = await rootBundle.load('assets/db/$assetFileName');
await dbFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
```

Four render layouts (`MushafLayout.uthmani15Lines`, `indopak13Lines`, `digitalKhatt15Lines`, `indopak9Lines`) each map to a layout DB (+ a script DB for word text); `indopak9Lines` reuses the Digital Khatt script DB and font. User-generated data (bookmarks, reading progress, memorization) lives in a separate writable `app_data.db` via `AppDataService`.

**Service initialization.** Services mix in `InitializationMixin` (from `utils/initialization_mixin.dart`) for thread-safe lazy init — never use ad-hoc init flags. Implement `doInit()` (copy/open DBs, warm static caches like Juz/Hizb once) and call `markInitialized()`; **every public method starts with `await ensureInitialized()`**.

```dart
class DatabaseService with InitializationMixin {
  @override
  Future<void> doInit() async {
    // copy + open DBs, warm caches
    markInitialized();
  }
}
```

A public `init({MushafLayout layout})` should short-circuit when already initialized for the same layout, delegate to `switchLayout()` when initialized for a different layout, else set the layout and `await ensureInitialized()`. Use `orderBy` on queries for deterministic ordering. On non-critical errors return safe defaults (`''`, `0`); throw custom exceptions from `lib/exceptions/database_exceptions.dart` for critical failures.

**Fonts.** Uthmani rendering uses **604 page-specific fonts** loaded lazily at runtime by `font_service.dart` and cached by `'${layout.name}_$pageNumber'` — they are NOT declared in `pubspec.yaml`. Indopak uses one declared font (`IndopakFont` / `indopakFontFamily`) for all pages. There is **no fallback font** for Quran text; a failed page-font load must surface an error, not silently fall back. Surah names and the Basmallah render as glyphs from the predeclared `SurahNames` (`surahNameFontFamily`) / `QuranCommon` (`quranCommonFontFamily`) fonts (declared in `pubspec.yaml`).

```dart
// uthmani15Lines: family 'Page$N', asset 'assets/fonts/qpc-v2-page-by-page-fonts/p$N.ttf'
final cacheKey = '${layout.name}_$pageNumber';
final cached = _loadedFonts[cacheKey];
if (cached != null) return cached;
final loader = FontLoader(pageFontFamily)..addFont(rootBundle.load(fontAssetPath));
await loader.load();
_loadedFonts[cacheKey] = pageFontFamily;
```

Surah names render by passing the Arabic name as text with `fontFamily: surahNameFontFamily` (the glyph is font-selected). Basmallah renders `basmallah` with `fontFamily: quranCommonFontFamily`.

When registering assets in `pubspec.yaml`, directory entries must end in `/` to bundle every file inside (e.g. the page-fonts directory `assets/fonts/qpc-v2-page-by-page-fonts/`).

## Dart & Flutter conventions

- Target Dart SDK `^3.9.2`. Key deps: `flutter_riverpod ^3.0.3`, `sqflite ^2.4.2`, `path_provider ^2.1.5`, `shared_preferences ^2.5.3`, `just_audio` (recitation), `flutter_html` (tafsir rendering), plus `build_runner`/`riverpod_generator`/`riverpod_lint` for codegen. Consult `pubspec.yaml` for current versions.
- **Null safety:** nullable types (`Database? _db`), explicit null checks before dereferencing, null-aware operators (`?.`, `??`). Use `late final` for non-nullable fields initialized in `initState`.
- **Immutable data classes:** annotate `@immutable`, use `const` constructors and `final` fields. Get value equality from **`Equatable`** — `extends Equatable` and list every field in `props`; this is the single source of truth for `==`/`hashCode`, so a field can never silently drop out of equality (hand-rolling `==`/`hashCode` previously shipped four such bugs). `Equatable` deep-compares collection fields, so no manual `listEquals`. Add a `copyWith()` for state updates rather than mutating.

  ```dart
  @immutable
  class Word extends Equatable {
    final String text;
    final int surahNumber;
    final int ayahNumber;
    const Word({required this.text, required this.surahNumber, required this.ayahNumber});

    @override
    List<Object?> get props => [text, surahNumber, ayahNumber];
  }
  ```

  An **entity** keyed by a primary key may intentionally list only its id in `props` (e.g. `Topic` → `[topicId]`); say so in a comment. For richer needs (generated `copyWith`/JSON), `freezed` is the next step, but `Equatable` is the default.
- **`const` constructors wherever possible.** Use `const` and collection literals (`<String>[]`, `<String, int>{}`) over constructor calls.
- **Color opacity:** use `withValues(alpha: …)`, never the deprecated `withOpacity()` — better precision, no deprecation warnings.
  ```dart
  color: Colors.black.withValues(alpha: 0.3)
  ```
- **Parsing:** use `parseInt()` from `utils/parsing_helpers.dart` for all dynamic→int conversions — never `int.parse()` (throws) and never local `_parseInt` methods.
- **Async:** `Future<…>` with `async`/`await`. Use `Future.microtask` in `initState` to schedule provider/state updates (avoid mutating providers during build). Wrap async ops in try/catch, log via `debugPrint` under `kDebugMode`, return a safe default. Throw exceptions only for unrecoverable failures.
- Prefix all private members with `_`. Order members: static fields → instance fields (public then private) → constructors → public methods → private methods → overrides at bottom.
- Order imports: Dart/Flutter SDK → `package:` → relative. Per file: imports → file-local constants → data classes → state → widgets.
- Use string interpolation over concatenation; named parameters for readability. Document public APIs with `///` (including thrown exceptions); use `//` for notes, prefixed `WHY:` for rationale. Add WHY comments that explain intent, not what the code does.

## Riverpod state management

- Riverpod **3.0+ with code generation**; declare all providers in `lib/providers.dart` with the `part 'providers.g.dart';` directive. Never hand-write provider boilerplate.
- `@Riverpod(keepAlive: true)` for long-lived providers (services, global state). Lowercase `@riverpod` (auto-dispose) for page-specific data providers.
- **Synchronous notifier:** class extends the generated `_$` base, synchronous `build()` returns the initial value, mutators assign to `state`.
- **Async service notifier:** `build()` returns `Future<Service>` and inits inside. Close any previous service before creating a new one, and register cleanup:

  ```dart
  @Riverpod(keepAlive: true)
  class DatabaseServiceNotifier extends _$DatabaseServiceNotifier {
    @override
    Future<DatabaseService> build() async {
      final previous = _service;
      if (previous != null) await previous.close();      // layout-change rebuild
      ref.onDispose(() async {
        final toClose = _service;
        _service = null;
        await toClose?.close();
      });
      // ...
    }
  }
  ```

  Consume with `await ref.watch(databaseServiceProvider.future)`.
- **Functional state updates:** set `state` to a new immutable value; never mutate it.
- For complex legacy state (e.g. memorization mode in `mushaf_screen.dart`), use `StateNotifierProvider` imported from `package:flutter_riverpod/legacy.dart`.
- `ref.watch` for reactive reads/rebuilds; `ref.read` for one-time imperative reads; `ref.listen` for side-effect callbacks without rebuild.

## Widgets & UI

**Hierarchy:** Screens (`lib/screens/`) are navigation targets; Widgets (`lib/widgets/`) are reusable components; Shared Widgets (`lib/widgets/shared/`) are generic cross-screen components.

**Widget base class — pick the lightest that fits:**
- `StatelessWidget` when all data arrives via props and no provider access is needed (props-down/events-up; lighter and clearer).
- `ConsumerWidget` when provider access (`ref.watch`/`read`/`listen`) is needed but no local state.
- `StatefulWidget` for state without providers; `ConsumerStatefulWidget` only when you need BOTH state AND provider access.

Use `super.key` in constructors; pass only immutable data to widgets; prefer composition over inheritance (extract pure builder functions). Check `context.mounted` before async navigation (e.g. before `Navigator.pop(context)`).

**RTL.** The app is RTL by default. **Every screen MUST wrap its `SafeArea`/root in `Directionality(textDirection: TextDirection.rtl)`** so top-level widgets like `AppHeader` inherit RTL correctly. Use `Align`/`Padding` for positioning rather than hardcoded left/right so layout flips correctly.

**Responsive sizing.** Compute font sizes from screen width relative to `referenceScreenWidth`, clamped between `minAyahFontSize` and `maxAyahFontSize` (constants in `constants.dart`). Never hardcode dimensions.

```dart
final scaleFactor = screenWidth / referenceScreenWidth;
final fontSize = (baseFontSize * scaleFactor).clamp(minAyahFontSize, maxAyahFontSize);
```

**AsyncValue.** Handle all three states explicitly when consuming async providers; use `.whenData()` when only the data case matters.

```dart
return asyncValue.when(
  data: (data) => BuildWidget(data),
  loading: () => const CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(error),
);
```

**Themes.** Three themes (light/dark/sepia) defined as `ThemeData` in `lib/themes.dart`. Light: `Colors.teal` / `Brightness.light` / white background. Dark: `Colors.teal` / `Brightness.dark` / `Color(0xFF121212)`. Sepia: `Colors.brown` / `Brightness.light` / `Color(0xFFF1E8D9)` (warm parchment). Selection runs through `ThemeNotifier` and the `AppThemeMode { system, light, dark, sepia }` enum, persisted to `SharedPreferences` under `'theme_mode'` (`themeMode.name`); load at startup defaulting to `system`. Map sepia and light → `ThemeMode.light`, dark → `ThemeMode.dark`, system → `ThemeMode.system`; since `ThemeMode` can't express sepia, handle it specially in the `MaterialApp` builder:

```dart
builder: (context, child) =>
    currentThemeMode == AppThemeMode.sepia ? Theme(data: sepiaTheme, child: child!) : child!,
```

Each theme sets its status bar via `appBarTheme.systemOverlayStyle` (`SystemUiOverlayStyle.dark`/`.light`) and `foregroundColor`. Use theme colors (`Theme.of(context).scaffoldBackgroundColor`, `iconTheme.color`) and `textTheme` styles rather than hardcoded colors/inline styles, unless hardcoding is intentional. **To add a theme:** define `ThemeData` in `themes.dart`, add the `AppThemeMode` value, update theme application in `main.dart`, and handle special cases in the builder.

**Custom-font text overflow.** Complex-metric fonts (e.g. `quran-common`) can trigger false overflow stripes. Use this strict hierarchy — outer `Container` (fixed size + decoration ONLY, no `alignment`/`padding`) → `Center` → inner `SizedBox` (smaller fixed size = explicit padding) → `FittedBox(fit: BoxFit.scaleDown)` → `Text` with a large base `fontSize`. Do NOT set `TextStyle.height` for these fonts.

```dart
Container(
  width: 100, height: 100,
  decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
  child: Center(
    child: SizedBox(
      width: 90, height: 90,
      child: FittedBox(fit: BoxFit.scaleDown, child: Text("١-١٢٣", style: TextStyle(fontSize: 48))),
    ),
  ),
)
```

## Functional programming

Prefer functional style where it adds clarity: pure functions (same input → same output, no I/O or global mutation), immutable data + `copyWith()`, function composition over imperative code, expressions over statements. Use higher-order collection methods (`where`/`map`/`reduce`/`fold`) over explicit loops; combine with async via `Future.wait(items.map(...))` and async generators (`async*`/`yield`) for streams. Prefer widget composition with pure builders, `AsyncValue.when` for conditional rendering, sealed classes for pattern matching, and records for simple data. Consider a `Result<T>` (`sealed class` with `Success<T>`/`Failure<T>`) for error handling instead of throwing. Apply lazy collections and memoization for expensive pure work. Do NOT force FP on performance-critical paths, complex state machines, legacy integration, or trivial one-offs where it adds complexity.

## Security & data validation

**Defense in depth — validate data even from trusted sources (the database, internal services).** A single layer is never enough for critical operations.

- **Nullable casts + null checks** always — never `as String`/`as int` without a preceding null check.
- **Validate parsed data** with the centralized `validate*` helpers in `utils/validation_helpers.dart` (`validateSearchQuery`, `validateSurahNumber`, `validateAyahNumber`, `validateSurahAyah`, `validatePageNumber`, `validateAudioUrl`, `validateFilePath`, `validateDatabaseFileName`) before use — parsing success ≠ valid range. Validate at service boundaries; never write inline validation when a helper exists. (`validateSearchQuery` caps input at 500 chars, strips `< > " '`, trims, and returns an empty string if nothing valid remains.)
- **Safe defaults:** skip invalid rows (`continue`) or return a safe default (`return 1;`) rather than crash. Never fail silently — every error path returns a default. Surah numbers are 1–114, ayah numbers > 0; check `result.isNotEmpty` and column non-null before casting.

```dart
final String? verseText = verseData['text'] as String?;
if (verseText == null) continue;

final int surahNumber = parseInt(parts[0]);          // not int.parse
try { validateSurahNumber(surahNumber); } catch (_) { return 1; }
```

- **SQL is always parameterized.** Never interpolate/concatenate queries — use `?` placeholders with `whereArgs` (convert args to strings, since stored values are text), including `LIKE` patterns (`whereArgs: ['%$name%']`). Use `DbConstants` for all table/column names.

  ```dart
  await db.query(DbConstants.pagesTable,
    where: '${DbConstants.pageNumberCol} = ?',
    whereArgs: [pageNumber.toString()]);
  ```

- **Paths & file names:** validate file paths against the documents dir with `validateFilePath(path, baseDir.path)` to block path traversal; whitelist names with `validateDatabaseFileName(name, allowedDbNames)` before any file op.
- **URLs:** validate with `validateAudioUrl()` before any network request (reject non-`http(s)`/malformed URIs, prefer HTTPS), especially URLs sourced from the DB.
- **Multiple validation layers** for critical ops (e.g. `validatePageNumber(p)` then cross-check `p <= getTotalPages()`). Handle all exceptions with try/catch returning a safe default.
- **Never leak sensitive info** (DB paths, stack traces, internal error details) in error messages, logs, or UI. Show generic user-facing messages (e.g. Arabic `'حدث خطأ. يرجى المحاولة مرة أخرى'`), never `error.toString()`. Consider encrypting sensitive user data (progress, bookmarks) via `flutter_secure_storage` rather than plaintext `SharedPreferences`.
- Run the security checklist before committing: inputs validated via helpers; SQL parameterized; paths/names validated and whitelisted; URLs validated; no sensitive leakage; debug logging gated by `kDebugMode`; casts nullable with null checks; exceptions handled with safe defaults; critical ops multi-layered.

## Logging

- **Never use `print()`** — the analyzer flags it. Use `debugPrint()` (imported from `package:flutter/foundation.dart`), which is stripped/throttled in release builds.
- Guard logging with `if (kDebugMode)` when it has side effects, adds debug context, or computes expensive data — this keeps detailed errors out of production.

```dart
if (kDebugMode) { debugPrint('Error in operation: $e'); }
```

## Layout-debugging notes

When a layout change introduces a persistent error (overflow, mispositioning) that resists fixes, stop trial-and-error and isolate the root cause:
1. Revert the file to a known-good baseline: `git checkout HEAD^ -- path/to/widget.dart`.
2. Re-introduce the smallest possible change (e.g. add a `String? newLabel` rendered with the original `TextStyle`/layout) to isolate the trigger.
3. If still unclear, wrap the widget in a `LayoutBuilder` and inspect the `BoxConstraints` it receives — `Positioned`/`Flex`/`Row`/`Column` parents often pass down unexpected (infinite or screen-wide) constraints.
4. Only after identifying the root cause, apply a targeted fix.

## Testing & pre-commit

- **Never bypass hooks or tests.** `git commit --no-verify` (and `-n`), `--no-gpg-sign`, and any test-skip flag are **forbidden — no exceptions** (not for quick fixes, cosmetic changes, "I know it works", or "pre-existing" failures). Pre-commit runs format + analyze + tests.
- When any test fails, stop and investigate; fix the **root cause**, re-run, and only commit once all tests pass. If you can't fix it immediately, do not commit — document it and address it separately.
- When the hook fails, read the error, fix the cause, and re-run the commit (the hook re-runs automatically); never work around it.
- **Golden tests:** first determine whether a failure is an intentional UI change. If intentional, update with `flutter test test/golden/ --update-goldens`, review the regenerated goldens, and commit them together with the code change. If unintentional, fix the regression and re-run.

Workflow: make changes → `git add` → optionally `flutter test` → `git commit` (hook runs format/analyze/tests).

## Commit conventions

Follow **Conventional Commits**: `<type>[optional scope]: <description>` with optional body/footer.
- Required types: `feat:` (MINOR), `fix:` (PATCH). Also `build:`, `chore:`, `ci:`, `docs:`, `style:`, `refactor:`, `perf:`, `test:`.
- Breaking changes: a `BREAKING CHANGE:` footer or `!` after type/scope (e.g. `feat!:`, `fix(api)!:`).
- Present tense, lowercase type/scope, no trailing period; descriptive. Body only for complex changes; scope (optional) names the affected area.
- **Only commit when the user explicitly instructs it.** Never commit automatically; execute each explicit instruction exactly once; after completing changes, report and wait.

## Documentation conventions

- Before adding or updating any date in a doc (security audits, architecture reviews, feature specs, changelogs), **verify the real current date first** (e.g. via web search or a date tool) — never assume.
- `docs/active/` tracks current work (memorization spec, coverage status, testing guide, roadmap); `docs/archived/` holds completed architecture reviews, security audits, and feature specs. `docs/concept/` contains the long-form product concept. The CI test workflow ignores `docs/**` paths.
