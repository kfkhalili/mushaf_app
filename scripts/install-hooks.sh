#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
HOOKS_SRC="$REPO_ROOT/scripts/git-hooks"
HOOKS_DST="$REPO_ROOT/.git/hooks"

if [[ ! -d "$HOOKS_DST" ]]; then
  echo "[install-hooks] .git/hooks not found. Are you inside a git repo?" >&2
  exit 1
fi

echo "[install-hooks] Installing git hooks..."
install_hook() {
  local name="$1"
  cp "$HOOKS_SRC/$name" "$HOOKS_DST/$name"
  chmod +x "$HOOKS_DST/$name"
  echo " - $name"
}

install_hook pre-commit
install_hook pre-push

echo "[install-hooks] Done."


