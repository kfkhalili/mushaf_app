# Testing Controls for Technical Debt Refactoring

## Quick Start

This repository has comprehensive testing controls to ensure **zero functionality breaks** and **zero UI changes** during technical debt refactoring.

### Run All Tests

```bash
# Run all tests (unit, widget, integration)
flutter test
flutter test integration_test/

# Run golden tests (visual regression)
flutter test test/golden/

# Run with coverage
flutter test --coverage

# Run analysis
flutter analyze
```

### Pre-commit Checks

Tests run automatically before each commit via git hooks. To manually run:

```bash
./scripts/test-pre-commit.sh
```

### CI/CD

Tests run automatically on every push and PR via GitHub Actions.

---

## Testing Layers

### 1. Visual Regression Tests (Golden Tests)

**Purpose**: Catch ANY UI changes (fonts, spacing, colors, layout)

**Location**: `test/golden/golden_test.dart`

**How to Run**:
```bash
# Verify against golden files (strict mode)
flutter test test/golden/

# Update golden files (when UI intentionally changes)
flutter test test/golden/ --update-goldens
```

**What's Tested**:
- ✅ Selection Screen (all tabs)
- ✅ Settings Screen (all themes)
- ✅ All theme variations

### 2. Integration Tests (E2E User Journeys)

**Purpose**: Verify complete user flows work end-to-end

**Location**: `integration_test/critical_user_journeys_test.dart`

**How to Run**:
```bash
flutter test integration_test/
```

**Critical Journeys**:
- ✅ Reading journey (Surah → Mushaf → Navigation)
- ✅ Juz selection journey
- ✅ Settings navigation
- ✅ Search navigation
- ✅ Theme switching
- ✅ State preservation

### 3. Unit Tests

**Purpose**: Verify service and provider contracts remain stable

**Locations**:
- `test/services/` - Service layer tests
- `test/providers/` - Provider tests

**How to Run**:
```bash
flutter test test/
```

**Coverage**:
- ✅ Database service contracts
- ✅ Bookmarks service contracts
- ✅ Provider state management
- ✅ Provider interactions

### 4. Performance Benchmarks

**Purpose**: Ensure refactoring doesn't degrade performance

**Location**: `test/performance/performance_benchmarks_test.dart`

**How to Run**:
```bash
flutter test test/performance/
```

### 5. Code Coverage

**Purpose**: Ensure test coverage doesn't decrease

**Thresholds**:
- Lines: 70%
- Functions: 70%
- Branches: 65%

**How to Check**:
```bash
# Generate coverage
flutter test --coverage

# Check thresholds
./scripts/check-coverage.sh

# View HTML report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Workflow for Technical Debt Refactoring

### Before Starting

```bash
# 1. Ensure all tests pass
flutter test
flutter test integration_test/
flutter test test/golden/

# 2. Ensure golden files are up to date
flutter test test/golden/ --update-goldens
```

### During Refactoring

1. **Make small, focused changes**
2. **Run tests after each change**:
   ```bash
   flutter test test/
   flutter analyze
   ```

### Before Committing

```bash
# Pre-commit hook runs automatically, or manually:
./scripts/test-pre-commit.sh
```

### Before Pushing PR

```bash
# Full test suite
flutter test
flutter test integration_test/
flutter test test/golden/
flutter analyze
```

---

## Handling Test Failures

### Golden Test Fails

**If UI didn't intentionally change**:
1. Review golden diff images
2. Find the UI bug
3. Fix the bug

**If UI intentionally changed**:
```bash
flutter test test/golden/ --update-goldens
git add test/golden/
```

### Integration Test Fails

1. Review test output for specific failure
2. Check if navigation broke
3. Verify provider state management
4. Fix the bug

### Unit Test Fails

1. Review test failure details
2. If contract changed intentionally → Update test
3. If bug introduced → Fix implementation

---

## CI/CD Pipeline

### Automated Checks

Every push and PR automatically runs:

1. ✅ Static analysis (`flutter analyze`)
2. ✅ Unit and widget tests with coverage
3. ✅ Golden tests (strict mode)
4. ✅ Integration tests (E2E journeys)
5. ✅ Coverage threshold checks

### View CI/CD Status

- GitHub Actions: `.github/workflows/test.yml`
- View runs: GitHub → Actions tab

---

## Test Helpers

### Helper Functions

**Location**: `test/helpers/test_helpers.dart`

**Available Helpers**:
- `pumpApp()` - Pump widget with ProviderScope
- `createTestContainer()` - Create test ProviderContainer
- `waitForProvider()` - Wait for async provider updates
- `verifyGolden()` - Verify golden test matches

### Example Usage

```dart
import 'package:mushaf_app/test/helpers/test_helpers.dart';

testWidgets('Example test', (tester) async {
  await pumpApp(tester, home: const SelectionScreen());
  // Test assertions...
});
```

---

## Coverage Reports

### Generate Report

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### View Coverage

- Lines: Percentage of lines executed
- Functions: Percentage of functions executed
- Branches: Percentage of branches executed

### Coverage Thresholds

If coverage drops below thresholds:
1. Review uncovered code
2. Add tests for uncovered areas
3. Or adjust thresholds in `.coverage_threshold.json`

---

## Best Practices

### 1. Run Tests Frequently

- After each significant change
- Before committing
- Before pushing PR

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
- Run tests on same OS as CI (Linux)
- Or update golden files and review diffs carefully

### Coverage Decreased After Refactoring

**Cause**: Refactoring removed tested code

**Solution**:
1. Review coverage report
2. Add tests for new code paths
3. Or update coverage thresholds if appropriate

### Performance Benchmarks Fail

**Cause**: Performance regression

**Solution**:
1. Profile the specific operation
2. Identify bottleneck
3. Optimize or revert change

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

For detailed information, see:
- **Main Guide**: [`docs/testing-guide.md`](docs/testing-guide.md) - Comprehensive testing guide
- **Status**: [`docs/testing-implementation-status.md`](docs/testing-implementation-status.md) - Implementation status and future enhancements

