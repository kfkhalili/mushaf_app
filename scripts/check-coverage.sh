#!/bin/bash

# Coverage checker script
# Ensures code coverage meets thresholds

set -e

THRESHOLD_FILE=".coverage_threshold.json"
COVERAGE_FILE="coverage/lcov.info"

if [ ! -f "$COVERAGE_FILE" ]; then
  echo "❌ Coverage file not found. Run 'flutter test --coverage' first."
  exit 1
fi

# Read thresholds from JSON (requires jq or manual parsing)
LINES_THRESHOLD=70
FUNCTIONS_THRESHOLD=70
BRANCHES_THRESHOLD=65
STATEMENTS_THRESHOLD=70

# Extract coverage percentages
if command -v lcov &> /dev/null; then
  LINES_COV=$(lcov --summary "$COVERAGE_FILE" 2>&1 | grep -oP 'lines\.*: \K[0-9.]*' || echo "0")
  FUNCTIONS_COV=$(lcov --summary "$COVERAGE_FILE" 2>&1 | grep -oP 'functions\.*: \K[0-9.]*' || echo "0")
  BRANCHES_COV=$(lcov --summary "$COVERAGE_FILE" 2>&1 | grep -oP 'branches\.*: \K[0-9.]*' || echo "0")

  echo "📊 Coverage Summary:"
  echo "   Lines: ${LINES_COV}% (threshold: ${LINES_THRESHOLD}%)"
  echo "   Functions: ${FUNCTIONS_COV}% (threshold: ${FUNCTIONS_THRESHOLD}%)"
  echo "   Branches: ${BRANCHES_COV}% (threshold: ${BRANCHES_THRESHOLD}%)"

  # Check thresholds
  FAILED=0

  if (( $(echo "$LINES_COV < $LINES_THRESHOLD" | bc -l) )); then
    echo "❌ Lines coverage below threshold"
    FAILED=1
  fi

  if (( $(echo "$FUNCTIONS_COV < $FUNCTIONS_THRESHOLD" | bc -l) )); then
    echo "❌ Functions coverage below threshold"
    FAILED=1
  fi

  if (( $(echo "$BRANCHES_COV < $BRANCHES_THRESHOLD" | bc -l) )); then
    echo "❌ Branches coverage below threshold"
    FAILED=1
  fi

  if [ $FAILED -eq 1 ]; then
    exit 1
  fi

  echo "✅ All coverage thresholds met!"
else
  echo "⚠️  lcov not installed. Skipping detailed coverage check."
  echo "Install with: apt-get install lcov (Linux) or brew install lcov (macOS)"
fi

