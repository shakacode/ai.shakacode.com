#!/bin/bash
set -euo pipefail

# Run on the destination Mac as the agents user.

EXPECTED_USER="${EXPECTED_USER:-agents}"
TARGET_ROOT="${TARGET_ROOT:-$HOME/.openclaw}"
SOURCE_ROOT_REGEX="${SOURCE_ROOT_REGEX:-/root/\\.openclaw|/home/ubuntu/\\.openclaw}"

if [[ "$(id -un)" != "$EXPECTED_USER" ]]; then
  echo "Run this script as '$EXPECTED_USER'." >&2
  exit 1
fi

if ! command -v rg >/dev/null 2>&1; then
  echo "ripgrep (rg) is required. Install it first, for example with: brew install ripgrep" >&2
  exit 1
fi

echo "=== Verifying required files ==="
required_paths=(
  "$TARGET_ROOT/openclaw.json"
  "$TARGET_ROOT/.env.1password"
  "$TARGET_ROOT/credentials/whatsapp"
  "$TARGET_ROOT/identity"
  "$TARGET_ROOT/cron/jobs.json"
)

for path in "${required_paths[@]}"; do
  if [[ -e "$path" ]]; then
    echo "OK  $path"
  else
    echo "MISSING  $path" >&2
    exit 1
  fi
done

echo "=== Checking for stale Linux path references ==="
if rg -n --hidden --glob '!.git/**' --glob '!browser/**' --glob '!*.bak' "$SOURCE_ROOT_REGEX" "$TARGET_ROOT"; then
  echo "Stale Linux paths remain in the migrated state." >&2
  exit 1
fi

if command -v openclaw >/dev/null 2>&1; then
  echo "=== openclaw status ==="
  openclaw status

  echo "=== openclaw gateway status ==="
  openclaw gateway status
else
  echo "openclaw is not installed in PATH." >&2
  exit 1
fi

echo
echo "=== Manual probes still required ==="
echo "1. Send a Slack message to the migrated agent."
echo "2. Send a WhatsApp message to the migrated agent."
echo "3. If BlueBubbles/iMessage is configured on this Mac, send an iMessage too."
echo "4. Confirm the agent replies on every configured channel."
