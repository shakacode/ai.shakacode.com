#!/bin/bash
set -euo pipefail

# Run on the main Mac before decommissioning the source machine.

SOURCE_HOST="${SOURCE_HOST:-ubuntu-openclaw.example.com}"
SOURCE_USER="${SOURCE_USER:-root}"
SOURCE_OPENCLAW_DIR="${SOURCE_OPENCLAW_DIR:-/root/.openclaw/}"
SOURCE_GOGCLI_DIR="${SOURCE_GOGCLI_DIR:-/root/.config/gogcli/}"
BACKUP_ROOT="${BACKUP_ROOT:-$HOME/openclaw-migration-backups}"
TRANSFER_GOGCLI="${TRANSFER_GOGCLI:-1}"
STAMP="$(date +%Y%m%d-%H%M%S)"
DEST_DIR="$BACKUP_ROOT/openclaw-source-$STAMP"

mkdir -p "$DEST_DIR"

echo "=== Backing up OpenClaw state from ${SOURCE_USER}@${SOURCE_HOST} ==="
rsync -avz --progress "${SOURCE_USER}@${SOURCE_HOST}:${SOURCE_OPENCLAW_DIR}" "$DEST_DIR/.openclaw/"

if [[ "$TRANSFER_GOGCLI" == "1" ]]; then
  echo "=== Backing up gogcli state ==="
  rsync -avz --progress "${SOURCE_USER}@${SOURCE_HOST}:${SOURCE_GOGCLI_DIR}" "$DEST_DIR/.config/gogcli/"
fi

echo
echo "=== DONE ==="
echo "Backup saved to: $DEST_DIR"
