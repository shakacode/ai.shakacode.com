#!/bin/bash
set -euo pipefail

# Run on the destination Mac as the agents user.

EXPECTED_USER="${EXPECTED_USER:-agents}"
GIT_NAME="${GIT_NAME:-Agent Operator}"
GIT_EMAIL="${GIT_EMAIL:-agent@company.com}"
SSH_KEY_PATH="${SSH_KEY_PATH:-$HOME/.ssh/id_ed25519}"

if [[ "$(id -un)" != "$EXPECTED_USER" ]]; then
  echo "Run this script as '$EXPECTED_USER'." >&2
  exit 1
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "=== Configuring git identity ==="
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

echo "=== Preparing SSH key ==="
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [[ -f "$SSH_KEY_PATH" && -f "$SSH_KEY_PATH.pub" ]]; then
  echo "SSH key already exists at $SSH_KEY_PATH"
else
  ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY_PATH" -N ""
fi

chmod 600 "$SSH_KEY_PATH"
chmod 644 "$SSH_KEY_PATH.pub"

echo "=== GitHub login ==="
echo "When prompted, choose:"
echo "  1. GitHub.com"
echo "  2. SSH"
echo "  3. Upload the existing public key: $SSH_KEY_PATH.pub"
echo "  4. Login with a web browser"
gh auth login

echo "=== Verifying GitHub access ==="
gh auth status
ssh -T git@github.com || true

echo
echo "=== DONE ==="
git config --global user.name
git config --global user.email
