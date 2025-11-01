# Installing Git Hooks

This project uses pre-commit hooks to ensure code quality before commits.

## Quick Setup

Run this command to install the pre-commit hook:

```bash
# Make the hook executable
chmod +x scripts/git-hooks/pre-commit

# Create symlink to git hooks directory
ln -sf ../../scripts/git-hooks/pre-commit .git/hooks/pre-commit
```

Or copy it directly:

```bash
cp scripts/git-hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

## What the Pre-commit Hook Does

The pre-commit hook runs these checks **before** you can commit:

1. **Formatting Check** - Ensures code is properly formatted
2. **Static Analysis** - Runs `flutter analyze`
3. **Code Generation** - Runs build_runner to ensure generated code is up-to-date
4. **Unit & Widget Tests** - Runs all tests (excluding golden tests)
5. **Golden Tests** - Verifies golden file matches

## Bypassing the Hook (Not Recommended)

If you need to bypass the hook for an emergency commit:

```bash
git commit --no-verify
```

⚠️ **Warning**: This skips all quality checks and may cause CI/CD failures.

## Manual Testing

To manually run the same checks locally:

```bash
# Run the pre-commit checks manually
./scripts/git-hooks/pre-commit

# Or use the test script
./scripts/test-pre-commit.sh
```

## Troubleshooting

### Hook not running?

1. Check if the hook is installed:
   ```bash
   ls -la .git/hooks/pre-commit
   ```

2. Check if it's executable:
   ```bash
   chmod +x .git/hooks/pre-commit
   ```

### Tests failing locally?

The pre-commit hook runs the **exact same checks** as CI/CD, so if it passes locally, CI should pass too.

### Golden tests failing?

If UI changes are intentional, update the golden files:

```bash
flutter test test/golden/ --update-goldens
git add test/golden/goldens/
git commit
```

## CI/CD Alignment

The pre-commit hook runs the **same checks** as CI/CD:
- ✅ Formatting (`dart format`)
- ✅ Static analysis (`flutter analyze`)
- ✅ Code generation (`build_runner`)
- ✅ Tests (`flutter test`)
- ✅ Golden tests (`flutter test test/golden/`)

This ensures **local passes = CI passes**.

