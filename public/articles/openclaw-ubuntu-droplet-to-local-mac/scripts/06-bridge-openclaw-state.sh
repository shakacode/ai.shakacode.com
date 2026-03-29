#!/bin/bash
set -euo pipefail

# Run on the main Mac. This bridges the Ubuntu source to the destination Mac.

SOURCE_HOST="${SOURCE_HOST:-ubuntu-openclaw.example.com}"
SOURCE_USER="${SOURCE_USER:-root}"
DEST_HOST="${DEST_HOST:-agent-box-agents}"
SOURCE_HOME="${SOURCE_HOME:-/root}"
TRANSFER_GOGCLI="${TRANSFER_GOGCLI:-0}"
SOURCE_HOME_ESCAPED="$(printf '%q' "$SOURCE_HOME")"
SOURCE_CONFIG_ESCAPED="$(printf '%q' "$SOURCE_HOME/.config")"

echo "=== Verifying source and destination access ==="
ssh -o BatchMode=yes "${SOURCE_USER}@${SOURCE_HOST}" 'printf "source-ok\n"' >/dev/null
ssh -o BatchMode=yes "${DEST_HOST}" 'printf "dest-ok\n"' >/dev/null

echo "=== Copying ~/.openclaw from ${SOURCE_USER}@${SOURCE_HOST} to ${DEST_HOST} ==="
ssh "${SOURCE_USER}@${SOURCE_HOST}" "tar -C ${SOURCE_HOME_ESCAPED} -czf - .openclaw" \
  | ssh "${DEST_HOST}" 'tar -C "$HOME" -xzf -'

echo "=== Locking down ~/.openclaw permissions on ${DEST_HOST} ==="
ssh "${DEST_HOST}" '
  chmod 700 "$HOME/.openclaw" 2>/dev/null || true
  find "$HOME/.openclaw" -type d -exec chmod 700 {} \; 2>/dev/null || true
  find "$HOME/.openclaw" -type f -exec chmod 600 {} \; 2>/dev/null || true
'

if [[ "$TRANSFER_GOGCLI" == "1" ]]; then
  echo "=== Copying ~/.config/gogcli from ${SOURCE_USER}@${SOURCE_HOST} to ${DEST_HOST} ==="
  ssh "${SOURCE_USER}@${SOURCE_HOST}" "tar -C ${SOURCE_CONFIG_ESCAPED} -czf - gogcli" \
    | ssh "${DEST_HOST}" 'mkdir -p "$HOME/.config" && tar -C "$HOME/.config" -xzf -'

  echo "=== Locking down ~/.config/gogcli permissions on ${DEST_HOST} ==="
  ssh "${DEST_HOST}" '
    chmod 700 "$HOME/.config/gogcli" 2>/dev/null || true
    find "$HOME/.config/gogcli" -type d -exec chmod 700 {} \; 2>/dev/null || true
    find "$HOME/.config/gogcli" -type f -exec chmod 600 {} \; 2>/dev/null || true
  '
fi

echo
echo "=== DONE ==="
echo "Transferred to ${DEST_HOST}:"
echo "  ~/.openclaw"
if [[ "$TRANSFER_GOGCLI" == "1" ]]; then
  echo "  ~/.config/gogcli"
fi
echo
echo "GitHub CLI auth was intentionally not copied."
