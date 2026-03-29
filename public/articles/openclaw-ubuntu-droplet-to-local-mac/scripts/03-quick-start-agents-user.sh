#!/bin/bash
set -euo pipefail

# Run on the destination Mac as the agents user.

echo "=== Setting up npm for the agents user ==="
mkdir -p "$HOME/.npm-global/bin"
npm config set prefix "$HOME/.npm-global"

if ! grep -q '.npm-global/bin' "$HOME/.zprofile" 2>/dev/null; then
  printf '\n%s\n' 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$HOME/.zprofile"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if ! grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
  printf '\n%s\n' 'eval "$(/opt/homebrew/bin/brew shellenv zsh)"' >> "$HOME/.zprofile"
fi

export PATH="$HOME/.npm-global/bin:$PATH"

echo "=== Installing agent tools ==="
npm install -g @anthropic-ai/claude-code
npm install -g playwright
npx playwright install chromium

echo
echo "=== DONE ==="
echo "Next:"
echo "  1. Set up Chrome profiles or browser state."
echo "  2. Run 04-bootstrap-agent-github.sh if this user needs its own GitHub identity."
echo "  3. If this user will run iMessage, sign into Messages.app locally and complete BlueBubbles setup after the core migration is healthy."
echo "  4. Keep saved browser auth state local to this Mac and out of Git."
echo "  5. Validate one real headed browser login flow before calling the migration complete."
