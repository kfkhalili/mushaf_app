#!/bin/bash

# Coverage checker script
# Ensures code coverage meets the thresholds declared in .coverage_threshold.json.
#
# WHY this shape:
#  - Thresholds are READ from the JSON (the single source of truth), not
#    hardcoded — editing the JSON actually changes the gate.
#  - Coverage is computed directly from lcov.info with awk, so `lcov` is NOT
#    required. This removes the old fail-OPEN path where a machine without lcov
#    printed a warning and exited 0, passing the gate unconditionally.
#  - Every failure path exits non-zero (fail CLOSED): missing coverage file,
#    unreadable thresholds, or coverage below threshold.

set -euo pipefail

THRESHOLD_FILE=".coverage_threshold.json"
COVERAGE_FILE="coverage/lcov.info"

if [ ! -f "$COVERAGE_FILE" ]; then
  echo "❌ Coverage file not found ($COVERAGE_FILE). Run 'flutter test --coverage' first."
  exit 1
fi

if [ ! -f "$THRESHOLD_FILE" ]; then
  echo "❌ Threshold file not found ($THRESHOLD_FILE)."
  exit 1
fi

# Read a numeric threshold for $1 (lines/functions/branches) from the JSON.
# Prefers python3 for a real JSON parse; falls back to grep for the
# "key": <int> pair. Prints nothing on failure so the caller can fail closed.
read_threshold() {
  local key="$1"
  if command -v python3 &>/dev/null; then
    python3 -c "import json; print(json.load(open('$THRESHOLD_FILE'))['coverage_thresholds']['$key'])" 2>/dev/null && return 0
  fi
  grep -oE "\"$key\"[[:space:]]*:[[:space:]]*[0-9]+(\.[0-9]+)?" "$THRESHOLD_FILE" \
    | head -1 | grep -oE '[0-9]+(\.[0-9]+)?$'
}

LINES_THRESHOLD=$(read_threshold lines || true)
FUNCTIONS_THRESHOLD=$(read_threshold functions || true)
BRANCHES_THRESHOLD=$(read_threshold branches || true)

if [ -z "${LINES_THRESHOLD:-}" ] || [ -z "${FUNCTIONS_THRESHOLD:-}" ] || [ -z "${BRANCHES_THRESHOLD:-}" ]; then
  echo "❌ Could not read coverage thresholds from $THRESHOLD_FILE."
  exit 1
fi

# Sum LF/LH (lines), FNF/FNH (functions), BRF/BRH (branches) across every
# record in lcov.info and emit the three percentages. Branch data is often
# absent from Flutter lcov; when so, branches default to 100 (a metric that is
# not measured cannot fail the gate).
read COV_LINES COV_FUNCTIONS COV_BRANCHES < <(
  awk -F: '
    /^LF:/  { lf  += $2 } /^LH:/  { lh  += $2 }
    /^FNF:/ { fnf += $2 } /^FNH:/ { fnh += $2 }
    /^BRF:/ { brf += $2 } /^BRH:/ { brh += $2 }
    END {
      printf "%.2f %.2f %.2f\n",
        (lf  > 0 ? lh  / lf  * 100 : 0),
        (fnf > 0 ? fnh / fnf * 100 : 0),
        (brf > 0 ? brh / brf * 100 : 100)
    }' "$COVERAGE_FILE"
)

echo "📊 Coverage Summary (thresholds from $THRESHOLD_FILE):"
printf '   Lines:     %6s%%  (threshold: %s%%)\n' "$COV_LINES" "$LINES_THRESHOLD"
printf '   Functions: %6s%%  (threshold: %s%%)\n' "$COV_FUNCTIONS" "$FUNCTIONS_THRESHOLD"
printf '   Branches:  %6s%%  (threshold: %s%%)\n' "$COV_BRANCHES" "$BRANCHES_THRESHOLD"

FAILED=0
# below <cov> <threshold> -> true (exit 0) when cov < threshold.
below() { awk -v c="$1" -v t="$2" 'BEGIN { exit !(c + 0 < t + 0) }'; }

if below "$COV_LINES" "$LINES_THRESHOLD"; then
  echo "❌ Lines coverage ${COV_LINES}% is below threshold ${LINES_THRESHOLD}%"
  FAILED=1
fi
if below "$COV_FUNCTIONS" "$FUNCTIONS_THRESHOLD"; then
  echo "❌ Functions coverage ${COV_FUNCTIONS}% is below threshold ${FUNCTIONS_THRESHOLD}%"
  FAILED=1
fi
if below "$COV_BRANCHES" "$BRANCHES_THRESHOLD"; then
  echo "❌ Branches coverage ${COV_BRANCHES}% is below threshold ${BRANCHES_THRESHOLD}%"
  FAILED=1
fi

if [ "$FAILED" -eq 1 ]; then
  exit 1
fi

echo "✅ All coverage thresholds met!"
