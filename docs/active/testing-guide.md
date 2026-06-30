# Testing Guide for Technical Debt Refactoring

## Overview

This comprehensive guide outlines the testing controls and strategy to ensure **zero functionality breaks** and **zero UI changes** during technical debt refactoring.

---

## Implementation Status

### ✅ Fully Implemented

- **Golden Tests** (`test/golden/golden_test.dart`) - Visual regression testing
- **Integration Tests** (`integration_test/`) - E2E user journeys
  - `critical_user_journeys_test.dart` - Core navigation flows
  - `smoke_journeys_test.dart` - Basic smoke tests
  - `user_journeys_test.dart` - Additional user journeys
- **Unit Tests** (`test/`)
  - **Services**: `database_service_test.dart`, `bookmarks_service_test.dart`
  - **Providers**: `page_provider_test.dart`, `provider_contract_tests.dart`
- **Performance Benchmarks** (`test/performance/performance_benchmarks_test.dart`)
- **CI/CD Pipeline** (`.github/workflows/test.yml`) - Automated testing on PRs
- **Pre-commit Hooks** (`scripts/test-pre-commit.sh`)
- **Coverage Tracking** (`.coverage_threshold.json`, `scripts/check-coverage.sh`)
- **Test Harness** (`test/support/`)

### 📋 Planned/Partially Implemented

- **Additional Integration Journeys**:
  - [ ] Bookmark journey (creation, navigation, deletion)
  - [ ] Theme switching journey (with state persistence)
  - [ ] Layout switching journey (preserves reading position)
- **Test Fixtures** - Mock data helpers for consistent testing
- **Automated Regression Testing** - Daily/weekly snapshot comparison (future enhancement)

---

## Testing Pyramid

```
                    /\
                   /  \
                  /  E2E \          ← Integration Tests (User Journeys)
                 /--------\
                /          \
               /  Widget    \       ← Widget Tests (Component Behavior)
              /--------------\
             /                \
            /   Unit Tests    \      ← Unit Tests (Services/Providers)
           /------------------\
          /                    \
         /   Static Analysis   \    ← Code Quality Checks
        /------------------------\
```

---

## 1. Visual Regression Testing (Golden Tests)

**Purpose**: Catch ANY UI changes, even subtle ones (fonts, spacing, colors, layout shifts).

**Location**: `test/golden/golden_test.dart`

### Status: ✅ Implemented

### How It Works

1. **Baseline Creation**: First run captures golden images of all critical screens
2. **Regression Detection**: Subsequent runs compare current UI against golden images
3. **Strict Mode**: Any pixel difference triggers a failure

### Running Golden Tests

```bash
# Run golden tests (strict mode - will fail on any difference)
flutter test test/golden/

# Update golden files (when UI intentionally changes)
flutter test test/golden/ --update-goldens
```

### What's Tested

- ✅ Selection Screen (all tabs: Surah, Juz, Pages)
- ✅ Settings Screen (all themes: Light, Dark, Sepia)
- ✅ All theme variations

### CI/CD Integration

Golden tests run automatically on every PR in strict mode via separate job. Any UI change must be explicitly approved by updating golden files.

---

## 2. Integration Tests (E2E User Journeys)

**Purpose**: Verify complete user flows work end-to-end.

**Location**: `integration_test/`

### Status: ✅ Implemented (Core Journeys)

### Implemented Journeys

**File**: `integration_test/critical_user_journeys_test.dart`

1. ✅ **Reading Journey**
   - Launch → Selection → Surah Selection → Mushaf Screen
   - Page navigation (swipe)
   - Back navigation

2. ✅ **Juz Selection Journey**
   - Launch → Juz Tab → Select Juz → Mushaf Screen

3. ✅ **Page Selection Journey**
   - Launch → Pages Tab → Select Page → Mushaf Screen

4. ✅ **Settings Journey**
   - Launch → Settings → Back to Selection

5. ✅ **Search Journey**
   - Launch → Search → Back to Selection

6. ✅ **Theme Switching**
   - Settings → Theme Change → Verify no crashes

7. ✅ **State Preservation**
   - Navigate forward/back → Verify state preserved

### Planned Journeys

**Status**: 📋 Planned (Not yet implemented)

- [ ] **Bookmark Journey**
  - Open Mushaf → Long-press ayah → Bookmark → Navigate to Bookmarks → Tap bookmark → Navigate to page → Swipe to delete

- [ ] **Theme Switching Journey** (Extended)
  - Open Settings → Switch to Dark → Navigate away/back → Verify persistence → Switch to Sepia → Verify change

- [ ] **Layout Switching Journey**
  - Navigate to page 302 → Switch Uthmani → Indopak → Verify page position maintained → Switch back

### Running Integration Tests

```bash
# Run all integration tests
flutter test integration_test/

# Run specific journey
flutter test integration_test/critical_user_journeys_test.dart
```

---

## 3. Unit Tests

**Purpose**: Verify service and provider contracts remain stable.

### Status: ✅ Implemented

### Service Layer Tests

**Location**: `test/services/`

**Coverage**:
- ✅ `database_service_test.dart` - Database operations contracts
- ✅ `bookmarks_service_test.dart` - Bookmark CRUD operations

**What's Tested**:
- Service initialization
- Data retrieval contracts
- Error handling
- Edge cases
- All pages (1-604)
- All surahs (1-114)
- All juzs (1-30)

### Provider Tests

**Location**: `test/providers/`

**Coverage**:
- ✅ `page_provider_test.dart` - Page state management
- ✅ `provider_contract_tests.dart` - All provider contracts

**What's Tested**:
- Provider initialization
- State updates
- State transitions
- Provider interactions
- Layout switching
- Search functionality
- History management

### Running Unit Tests

```bash
# Run all unit tests
flutter test test/

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/services/database_service_test.dart
```

---

## 4. Performance Benchmarks

**Location**: `test/performance/performance_benchmarks_test.dart`

**Purpose**: Ensure refactoring doesn't degrade performance.

### Status: ✅ Implemented

### Benchmarks Tracked

1. **Database Operations**
   - `getPageLayout` - Should complete < 500ms
   - `getAllSurahs` - Should complete < 1000ms
   - `getAllJuzInfo` - Should complete < 2000ms
   - `getPageForAyah` - Should complete < 1000ms
   - Database initialization - Should complete < 5000ms

### Running Benchmarks

```bash
flutter test test/performance/performance_benchmarks_test.dart
```

---

## 5. Code Coverage Tracking

**Purpose**: Ensure test coverage doesn't decrease during refactoring.

### Status: ✅ Implemented

**Configuration**: `.coverage_threshold.json`

**Thresholds**:
- Lines: 70%
- Functions: 70%
- Branches: 65%
- Statements: 70%

### Checking Coverage

```bash
# Generate coverage report
flutter test --coverage

# Check thresholds
./scripts/check-coverage.sh

# View HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Coverage Targets by Area

1. **Service Layer** (Target: 80%+)
   - Database operations
   - Bookmark operations
   - Search operations

2. **Provider Layer** (Target: 75%+)
   - State management
   - Provider interactions

3. **Critical User Journeys** (Target: 100%)
   - All integration test journeys must pass

### CI/CD Integration

Coverage is automatically checked on every PR. Coverage below thresholds will fail the build.

---

## 6. Static Analysis

**Purpose**: Catch code quality issues and enforce patterns.

**Location**: `analysis_options.yaml`

### Status: ✅ Implemented

### Running Analysis

```bash
# Run analysis
flutter analyze

# Fix auto-fixable issues
dart fix --apply
```

### CI/CD Integration

Analysis runs automatically on every PR. Any analysis errors will fail the build.

---

## 7. Pre-commit Hooks

**Location**: `scripts/test-pre-commit.sh`

**Purpose**: Prevent committing code that breaks tests.

### Status: ✅ Implemented

### Setup

```bash
# Make script executable
chmod +x scripts/test-pre-commit.sh

# Link to git hook
ln -sf ../../scripts/test-pre-commit.sh .git/hooks/pre-commit
```

### What It Checks

1. ✅ Static analysis (`flutter analyze`)
2. ✅ Unit and widget tests (`flutter test`)
3. ✅ Golden tests (strict mode)
4. ✅ Code coverage thresholds

---

## 8. CI/CD Pipeline

**Location**: `.github/workflows/test.yml`

### Status: ✅ Implemented

### Pipeline Jobs

1. **Test Job** (`test`)
   - Install dependencies
   - Generate code
   - Run analysis
   - Run unit/widget tests with coverage
   - Run golden tests
   - Run integration tests
   - Upload coverage to Codecov
   - Check coverage thresholds

2. **Golden Check Job** (`golden-check`)
   - Run golden tests in strict mode
   - Fail on any UI changes

3. **Integration Test Job** (`integration-test`)
   - Run E2E user journeys
   - Upload test results

### Triggered On

- Every push to `main` or `develop`
- Every pull request to `main` or `develop`

---

## Workflow for Technical Debt Refactoring

### Step-by-Step Process

1. **Before Starting**
   ```bash
   # Ensure all tests pass
   flutter test
   flutter test integration_test/
   flutter test test/golden/

   # Ensure golden files are up to date
   flutter test test/golden/ --update-goldens
   ```

2. **Make Refactoring Changes**
   - Focus on one technical debt item at a time
   - Make minimal, focused changes
   - Don't change behavior or UI

3. **Run Tests After Each Change**
   ```bash
   # Quick check
   flutter test test/

   # Full check
   flutter test
   flutter test integration_test/
   flutter test test/golden/
   flutter analyze
   ```

4. **Commit Changes**
   ```bash
   # Pre-commit hook will run tests automatically
   git commit -m "refactor: migrate theme provider to code-gen"
   ```

5. **Push to PR**
   - CI/CD will run full test suite
   - Review golden diffs if any
   - Fix any failures before merging

---

## Golden Test Workflow

### When UI Should NOT Change (99% of refactoring)

1. Run golden tests: `flutter test test/golden/`
2. ✅ If tests pass: No UI changes detected
3. ❌ If tests fail: Review golden diffs to see what changed

### When UI DOES Change Intentionally

1. Make UI changes
2. Run golden tests with update flag: `flutter test test/golden/ --update-goldens`
3. Review updated golden files in git diff
4. Commit both code changes and updated golden files together

```bash
# 1. Make UI changes
# 2. Run tests to see diffs
flutter test test/golden/

# 3. Review generated diff images (in test/golden/failures/)
# 4. If changes are correct:
flutter test --update-goldens

# 5. Commit updated golden files with clear message
git commit -m "feat: update golden files for new header design"
```

---

## Handling Test Failures

### Golden Test Failures

**Scenario**: Golden test fails after refactoring

**Possible Causes**:
1. UI actually changed (unintentional)
2. Font rendering difference (OS-dependent)
3. Timestamp or dynamic content

**Solution**:
1. Review golden diff images
2. If UI change is unintentional → Fix the bug
3. If difference is expected → Update golden files

### Integration Test Failures

**Scenario**: User journey test fails

**Possible Causes**:
1. Navigation broke
2. State management issue
3. Provider contract changed

**Solution**:
1. Review test output for specific failure
2. Check if provider contract changed
3. Verify navigation logic

### Unit Test Failures

**Scenario**: Service or provider test fails

**Possible Causes**:
1. Contract changed
2. Implementation bug
3. Test needs updating (if contract intentionally changed)

**Solution**:
1. Review test failure details
2. If contract changed intentionally → Update test
3. If bug introduced → Fix implementation

---

## Test Harness

**Location**: `test/support/` (import the barrel `test/support/harness.dart`).

The harness is the single source for the test environment. It replaced the
~25-line sqflite/`path_provider` setup block that had been copy-pasted (and had
drifted) across 18 service/provider test files, and the inline
`ProviderScope(child: MaterialApp(...))` scaffold hand-rolled in every widget
test.

### Available helpers

- `useDatabaseTestEnv({prefs})` — call once at the top of `main()` in any
  database-backed test. Installs the sqflite FFI factory, mocks `path_provider`
  to a fresh temp directory **per file** (no shared on-disk state), and seeds a
  clean `SharedPreferences` before each test.
- `pumpScreen(tester, screen, {overrides, prefs})` — mounts `screen` inside
  `ProviderScope > MaterialApp > Directionality(rtl)`. Mounts only (no trailing
  pump), so a test can assert on the loading frame before advancing.
- `pumpUntilFound(tester, finder, {timeout, step})` — pumps until `finder`
  matches, else fails. Use instead of `if (finder.evaluate().isNotEmpty)` guards,
  which silently pass when data never loads.
- `settle(tester, {duration, step})` — pumps a fixed budget. Use instead of
  hand-rolled `for (i…) pump()` loops where there is no concrete thing to await
  (e.g. before a golden capture). `pumpAndSettle()` never settles in this app
  (the PageView controller and async providers keep scheduling frames).
- `FakeDatabaseStore` / `ThrowingDatabaseStore` — test adapters for the
  `DatabaseStore` seam (see below).

### Example usage

```dart
import '../support/harness.dart';

void main() {
  useDatabaseTestEnv();

  testWidgets('shows the surah list', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(body: const SurahListView()),
      overrides: [surahListProvider.overrideWith((ref) => Future.value(surahs))],
    );
    await settle(tester);
    expect(find.byType(SurahListView), findsOneWidget);
  });
}
```

### The `DatabaseStore` seam

`DatabaseStore` (in `lib/services/database_store.dart`) is the interface every
read-only service opens its databases through; `BundledDatabaseStore` is the
production adapter. Inject a `FakeDatabaseStore`/`ThrowingDatabaseStore` in tests
to open fixtures or simulate failures. `AppDataService` accepts a
`databasePath`; pass `inMemoryDatabasePath` for an isolated, parallel-safe
database with no shared `app_data.db`.

---

## Testing Checklist for Refactoring

### Before Starting

- [x] Ensure all existing tests pass
- [x] Capture current golden files
- [x] Document current test coverage
- [ ] Identify affected areas

### During Refactoring

- [ ] Run tests after each change
- [ ] Update tests if behavior intentionally changes
- [ ] Regenerate golden files if UI intentionally changes
- [ ] Verify integration tests still pass

### After Refactoring

- [ ] All tests pass
- [ ] Golden files unchanged (or updated with reason)
- [ ] Coverage maintained or improved
- [ ] Integration tests verify user journeys
- [ ] Manual smoke test on device

---

## Best Practices

### 1. Run Tests Frequently

```bash
# After each significant change
flutter test

# Before committing
./scripts/test-pre-commit.sh

# Before pushing PR
flutter test
flutter test integration_test/
flutter test test/golden/
```

### 2. Keep Golden Files in Version Control

- ✅ Commit golden files with code changes
- ✅ Review golden diffs in PRs
- ❌ Don't update golden files unless UI intentionally changes

### 3. Maintain Test Coverage

- ✅ Add tests for new code
- ✅ Update tests when contracts change intentionally
- ✅ Keep coverage above thresholds

### 4. Document Intentional Changes

When updating golden files or tests:
```dart
// TODO: Updated golden test after refactoring theme provider
// UI behavior unchanged, but internal implementation improved
```

---

## Troubleshooting

### Golden Tests Fail Locally But Pass in CI

**Cause**: OS-dependent rendering differences

**Solution**:
1. Run tests on same OS as CI (Linux)
2. Or update golden files and review diffs carefully

### Coverage Decreased After Refactoring

**Cause**: Refactoring removed tested code without removing tests

**Solution**:
1. Review coverage report to identify uncovered areas
2. Add tests for new code paths
3. Or update coverage thresholds if appropriate

### Performance Benchmarks Fail

**Cause**: Refactoring introduced performance regression

**Solution**:
1. Profile the specific operation
2. Identify bottleneck
3. Optimize or revert change

---

## Success Metrics

✅ **Zero functionality breaks**: All integration tests pass
✅ **Zero UI changes**: All golden tests match baseline
✅ **Coverage maintained**: Test coverage ≥ 70%
✅ **Fast feedback**: Tests run in < 5 minutes locally
✅ **CI integration**: All tests run on every PR

---

## Quick Start Commands

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Update golden files (after intentional UI changes)
flutter test --update-goldens

# Run only golden tests
flutter test test/golden/

# Run only integration tests
flutter test integration_test/

# View coverage report
genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html
```

---

## Summary

These testing controls provide multiple layers of protection:

1. **Visual Regression** → Catches UI changes
2. **Integration Tests** → Catches broken user journeys
3. **Unit Tests** → Catches broken contracts
4. **Performance Tests** → Catches performance regressions
5. **Coverage Tracking** → Ensures test quality
6. **Static Analysis** → Ensures code quality
7. **CI/CD** → Automated checks on every PR
8. **Pre-commit Hooks** → Prevents committing broken code

Together, these controls ensure **zero functionality breaks** and **zero UI changes** during technical debt refactoring.

---

## Key Learnings from Implementation

These mechanics are now owned by the harness (`test/support/`) — tests no longer
hand-roll them. The learnings are kept here as background on *why* the harness
does what it does.

### 1. Provider Mocking (Riverpod 3.0)

Riverpod 3's `Override` type is `part` of the framework's internals and not
publicly nameable, so a typed `List<Override>` parameter will not compile.
`pumpScreen` takes `overrides` as `dynamic` (defaulting to `const <Never>[]`);
callers pass a normal list literal of `provider.overrideWith(...)` results,
whose runtime type is `List<Override>` and so assigns cleanly. This keeps the
single `// ignore: avoid_annotating_with_dynamic` in one place instead of an
`// ignore: argument_type_not_assignable` on every test.

### 2. Platform Channel Mocking

`path_provider`'s `getApplicationDocumentsDirectory` is mocked once, inside
`useDatabaseTestEnv()`, pointing at a fresh temp directory **per test file** so
no writable state leaks between files. Tests just call `useDatabaseTestEnv()`.

### 3. sqflite Testing

`useDatabaseTestEnv()` performs `sqfliteFfiInit()` and sets
`databaseFactory = databaseFactoryFfi` for non-device tests. `sqflite_common_ffi`
remains a dev dependency. For the writable user-data database, pass
`AppDataService(databasePath: inMemoryDatabasePath)` to avoid disk entirely.

### 4. Settling async UI (golden + widget tests)

`pumpAndSettle()` never settles in this app — the PageView controller and async
providers keep scheduling frames. Use `pumpUntilFound(tester, finder)` when
there is a concrete thing to await (and to fail when it never appears), or
`settle(tester)` for a fixed budget before a golden capture. Both replaced the
48 hand-rolled `for (i…) pump()` loops.

