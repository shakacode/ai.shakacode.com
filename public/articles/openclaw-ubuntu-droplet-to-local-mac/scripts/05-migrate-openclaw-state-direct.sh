#!/bin/bash
set -euo pipefail

# Run on the destination Mac as the agents user.

EXPECTED_USER="${EXPECTED_USER:-agents}"
SOURCE_HOST="${SOURCE_HOST:-ubuntu-openclaw.example.com}"
SOURCE_USER="${SOURCE_USER:-root}"
SOURCE_DIR="${SOURCE_DIR:-/root/.openclaw/}"
DEST_DIR="${DEST_DIR:-$HOME/.openclaw}"

TRANSFER_GOGCLI="${TRANSFER_GOGCLI:-0}"
GOGCLI_SOURCE_DIR="${GOGCLI_SOURCE_DIR:-/root/.config/gogcli/}"
GOGCLI_DEST_DIR="${GOGCLI_DEST_DIR:-$HOME/.config/gogcli}"

if [[ "$(id -un)" != "$EXPECTED_USER" ]]; then
  echo "Run this script as '$EXPECTED_USER'." >&2
  exit 1
fi

mkdir -p "$HOME/.config"

echo "=== Copying OpenClaw state from ${SOURCE_USER}@${SOURCE_HOST} ==="
if command -v rsync >/dev/null 2>&1; then
  mkdir -p "$DEST_DIR"
  rsync -avz --progress "${SOURCE_USER}@${SOURCE_HOST}:${SOURCE_DIR}" "$DEST_DIR/"
else
  mkdir -p "$DEST_DIR"
  scp -r "${SOURCE_USER}@${SOURCE_HOST}:${SOURCE_DIR%/}/." "$DEST_DIR"
fi

chmod 700 "$DEST_DIR" 2>/dev/null || true
find "$DEST_DIR" -type d -exec chmod 700 {} \; 2>/dev/null || true
find "$DEST_DIR" -type f -exec chmod 600 {} \; 2>/dev/null || true

if [[ "$TRANSFER_GOGCLI" == "1" ]]; then
  echo "=== Copying gogcli config ==="
  if command -v rsync >/dev/null 2>&1; then
    mkdir -p "$GOGCLI_DEST_DIR"
    rsync -avz --progress "${SOURCE_USER}@${SOURCE_HOST}:${GOGCLI_SOURCE_DIR}" "$GOGCLI_DEST_DIR/"
  else
    mkdir -p "$GOGCLI_DEST_DIR"
    scp -r "${SOURCE_USER}@${SOURCE_HOST}:${GOGCLI_SOURCE_DIR%/}/." "$GOGCLI_DEST_DIR"
  fi

  chmod 700 "$GOGCLI_DEST_DIR" 2>/dev/null || true
  find "$GOGCLI_DEST_DIR" -type d -exec chmod 700 {} \; 2>/dev/null || true
  find "$GOGCLI_DEST_DIR" -type f -exec chmod 600 {} \; 2>/dev/null || true
fi

echo
echo "=== DONE ==="
echo "Transferred:"
echo "  $DEST_DIR"
if [[ "$TRANSFER_GOGCLI" == "1" ]]; then
  echo "  $GOGCLI_DEST_DIR"
fi
