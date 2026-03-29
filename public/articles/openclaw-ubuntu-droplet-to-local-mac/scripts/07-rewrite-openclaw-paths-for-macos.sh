#!/bin/bash
set -euo pipefail

# Run on the destination Mac as the agents user after copying state from Linux.

EXPECTED_USER="${EXPECTED_USER:-agents}"
SOURCE_ROOT="${SOURCE_ROOT:-/root/.openclaw}"
TARGET_ROOT="${TARGET_ROOT:-$HOME/.openclaw}"
STAMP="$(date +%Y%m%d-%H%M%S)"

if [[ "$(id -un)" != "$EXPECTED_USER" ]]; then
  echo "Run this script as '$EXPECTED_USER'." >&2
  exit 1
fi

if [[ ! -d "$TARGET_ROOT" ]]; then
  echo "Target root not found: $TARGET_ROOT" >&2
  exit 1
fi

if ! command -v rg >/dev/null 2>&1; then
  echo "ripgrep (rg) is required. Install it first, for example with: brew install ripgrep" >&2
  exit 1
fi

declare -a candidate_files=(
  "$TARGET_ROOT/openclaw.json"
  "$TARGET_ROOT/agents/main/sessions/sessions.json"
  "$TARGET_ROOT/exec-approvals.json"
  "$TARGET_ROOT/cron/jobs.json"
)

while IFS= read -r -d '' file; do
  candidate_files+=("$file")
done < <(find "$TARGET_ROOT/agents/main/sessions" -type f -name '*.jsonl' -print0 2>/dev/null || true)

export SOURCE_ROOT TARGET_ROOT

rewrite_file() {
  local file="$1"

  [[ -f "$file" ]] || return 0

  if ! grep -q "$SOURCE_ROOT" "$file"; then
    return 0
  fi

  cp "$file" "$file.pre-macos-path-fix.$STAMP.bak"
  perl -pi -e 's|\Q$ENV{SOURCE_ROOT}\E|$ENV{TARGET_ROOT}|g' "$file"
  echo "Rewrote $file"
}

echo "=== Rewriting Linux paths inside migrated OpenClaw state ==="
for file in "${candidate_files[@]}"; do
  rewrite_file "$file"
done

if command -v openclaw >/dev/null 2>&1; then
  echo "=== Running openclaw doctor --fix ==="
  openclaw doctor --fix || true
fi

echo "=== Searching for remaining references to $SOURCE_ROOT ==="
if rg -n --hidden --glob '!.git/**' --glob '!browser/**' --glob '!*.bak' "$SOURCE_ROOT" "$TARGET_ROOT"; then
  echo "Some references remain. Review the files above before starting the gateway." >&2
  exit 1
else
  echo "No remaining references found."
fi

echo
echo "=== DONE ==="
echo "Backups use the suffix: .pre-macos-path-fix.$STAMP.bak"
