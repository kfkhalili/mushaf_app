#!/bin/bash

# Pre-commit test runner
# Ensures tests pass before allowing commit

set -e

echo "🧪 Running pre-commit tests..."

# Run analysis
echo "📊 Running static analysis..."
flutter analyze

# Run tests with coverage
echo "🧪 Running unit and widget tests..."
flutter test --coverage

# Check if golden files need updating
echo "🖼️  Checking golden tests..."
if ! flutter test test/golden/; then
  echo "❌ Golden test mismatch detected!"
  echo "Run 'flutter test test/golden/ --update-goldens' if UI changes are intentional"
  exit 1
fi

# Check coverage threshold
if [ -f coverage/lcov.info ]; then
  COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep -oP 'lines\.*: \K[0-9.]*' || echo "0")
  echo "📈 Code coverage: ${COVERAGE}%"

  # Threshold: 70%
  if (( $(echo "$COVERAGE < 70" | bc -l) )); then
    echo "⚠️  Coverage is below 70% threshold"
    echo "Current: ${COVERAGE}%"
    exit 1
  fi
fi

echo "✅ All pre-commit checks passed!"

