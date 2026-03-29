#!/bin/bash
set -euo pipefail

# Run on the destination Mac as the admin user.

AGENTS_USER="${AGENTS_USER:-agents}"
AGENTS_FULL_NAME="${AGENTS_FULL_NAME:-AI Agents}"
AGENTS_PASSWORD="${AGENTS_PASSWORD:-}"

find_brew_bin() {
  local candidate

  if command -v brew >/dev/null 2>&1; then
    command -v brew
    return 0
  fi

  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

echo "=== Phase 1: system setup ==="
softwareupdate --install --all || echo "No updates available or a reboot is required."
fdesetup status | grep -q "On" || sudo fdesetup enable
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
sudo pmset -a disablesleep 1
sudo pmset -a sleep 0
sudo pmset -a displaysleep 15
sudo pmset -a hibernatemode 0

echo "=== Phase 2: create agents user ==="
if id "$AGENTS_USER" >/dev/null 2>&1; then
  echo "$AGENTS_USER already exists"
else
  if [[ -z "$AGENTS_PASSWORD" ]]; then
    read -r -s -p "Enter password for $AGENTS_USER: " AGENTS_PASSWORD
    echo
  fi

  if [[ -z "$AGENTS_PASSWORD" || "$AGENTS_PASSWORD" == "SET_A_REAL_PASSWORD" ]]; then
    echo "Set AGENTS_PASSWORD to a strong, non-placeholder password." >&2
    exit 1
  fi

  sudo sysadminctl -addUser "$AGENTS_USER" -fullName "$AGENTS_FULL_NAME" -password "$AGENTS_PASSWORD" -home "/Users/$AGENTS_USER"
fi

if [[ ! -d "/Users/$AGENTS_USER" ]]; then
  sudo createhomedir -u "$AGENTS_USER" -c
fi

chmod 700 "$HOME"
sudo chmod 700 "/Users/$AGENTS_USER"

echo "=== Phase 3: install tools ==="
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

BREW_BIN="$(find_brew_bin)" || {
  echo "Homebrew was expected but no brew executable was found." >&2
  exit 1
}

eval "$("$BREW_BIN" shellenv)"

if ! grep -q 'brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
  printf '\n%s\n' "eval \"\$($BREW_BIN shellenv)\"" >> "$HOME/.zprofile"
fi

brew install git gh node python@3.12 ripgrep tmux
brew install --cask google-chrome tailscale

npm install -g @anthropic-ai/claude-code
npm install -g @openai/codex

echo "=== Phase 4: enable remote access ==="
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist 2>/dev/null || true

echo
echo "Manual steps:"
echo "  1. System Settings -> General -> Sharing -> enable Remote Login"
echo "  2. Allow both the admin user and $AGENTS_USER"
echo "  3. From the main Mac, run 02-quick-start-main-machine.sh"
echo
echo "Press Enter once the main Mac bootstrap has completed."
read -r

chmod 600 "$HOME/.ssh/id_ed25519" "$HOME/.ssh/id_rsa" 2>/dev/null || true

echo "=== GitHub login for the admin user ==="
gh auth login

echo
echo "=== DONE ==="
echo "Next:"
echo "  1. Log into $AGENTS_USER locally once."
echo "  2. Run 03-quick-start-agents-user.sh as $AGENTS_USER."
