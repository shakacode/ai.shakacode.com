#!/bin/bash
set -euo pipefail

# Run on the main Mac. This bootstraps SSH access to the destination Mac.

AGENT_BOX_HOST="${AGENT_BOX_HOST:-agent-box.local}"
AGENT_BOX_ADMIN_USER="${AGENT_BOX_ADMIN_USER:-adminuser}"
AGENT_BOX_AGENTS_USER="${AGENT_BOX_AGENTS_USER:-agents}"
SSH_CONFIG_FILE="${SSH_CONFIG_FILE:-$HOME/.ssh/config}"
COPY_LOCAL_KEYPAIR_TO_DESTINATION="${COPY_LOCAL_KEYPAIR_TO_DESTINATION:-0}"

BOOTSTRAP_SSH_OPTS=(
  -o PreferredAuthentications=password
  -o PubkeyAuthentication=no
  -o KbdInteractiveAuthentication=yes
  -o StrictHostKeyChecking=accept-new
  -o ConnectTimeout=5
)

REMOTE_ADMIN_TARGET="${AGENT_BOX_ADMIN_USER}@${AGENT_BOX_HOST}"
REMOTE_AGENTS_TARGET="${AGENT_BOX_AGENTS_USER}@${AGENT_BOX_HOST}"

pick_local_key() {
  if [[ -f "$HOME/.ssh/id_ed25519" && -f "$HOME/.ssh/id_ed25519.pub" ]]; then
    LOCAL_KEY_BASE="$HOME/.ssh/id_ed25519"
  elif [[ -f "$HOME/.ssh/id_rsa" && -f "$HOME/.ssh/id_rsa.pub" ]]; then
    LOCAL_KEY_BASE="$HOME/.ssh/id_rsa"
  else
    echo "No usable SSH keypair found in ~/.ssh." >&2
    exit 1
  fi

  LOCAL_KEY_PATH="$LOCAL_KEY_BASE"
  LOCAL_KEY_PUB_PATH="$LOCAL_KEY_BASE.pub"
  LOCAL_KEY_NAME="$(basename "$LOCAL_KEY_BASE")"
}

rewrite_ssh_config() {
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  touch "$SSH_CONFIG_FILE"
  chmod 600 "$SSH_CONFIG_FILE"

  local tmp_file
  tmp_file="$(mktemp)"

  awk '
    function is_target_host_line(line, fields, i) {
      n = split(line, fields, /[[:space:]]+/)
      for (i = 2; i <= n; i++) {
        if (fields[i] == "agent-box" || fields[i] == "agent-box-agents") {
          return 1
        }
      }
      return 0
    }
    /^[[:space:]]*Host[[:space:]]+/ {
      skip = is_target_host_line($0)
      if (skip) next
    }
    /^[[:space:]]*Match[[:space:]]+/ {
      skip = 0
    }
    skip { next }
    { print }
  ' "$SSH_CONFIG_FILE" > "$tmp_file"

  cat >> "$tmp_file" <<EOF

Host agent-box
    HostName $AGENT_BOX_HOST
    User $AGENT_BOX_ADMIN_USER
    IdentityFile $LOCAL_KEY_PATH

Host agent-box-agents
    HostName $AGENT_BOX_HOST
    User $AGENT_BOX_AGENTS_USER
    IdentityFile $LOCAL_KEY_PATH
EOF

  mv "$tmp_file" "$SSH_CONFIG_FILE"
}

ensure_host_reachable() {
  if nc -G 5 -z "$AGENT_BOX_HOST" 22 >/dev/null 2>&1; then
    return 0
  fi

  echo "Could not reach $AGENT_BOX_HOST on port 22." >&2
  echo "Retry with AGENT_BOX_HOST=<ip-or-tailnet-host> if Bonjour is flaky." >&2
  exit 1
}

bootstrap_remote_access() {
  local pubkey
  pubkey="$(< "$LOCAL_KEY_PUB_PATH")"

  echo "This prompt is for the macOS password of '$AGENT_BOX_ADMIN_USER' on the destination Mac."

  ssh "${BOOTSTRAP_SSH_OPTS[@]}" "$REMOTE_ADMIN_TARGET" \
    'umask 077; mkdir -p ~/.ssh; touch ~/.ssh/authorized_keys; chmod 700 ~/.ssh; chmod 600 ~/.ssh/authorized_keys'

  ssh "${BOOTSTRAP_SSH_OPTS[@]}" "$REMOTE_ADMIN_TARGET" \
    "grep -qxF '$pubkey' ~/.ssh/authorized_keys || printf '%s\n' '$pubkey' >> ~/.ssh/authorized_keys"

  echo "This prompt is for the macOS password of '$AGENT_BOX_AGENTS_USER' on the destination Mac."

  ssh "${BOOTSTRAP_SSH_OPTS[@]}" "$REMOTE_AGENTS_TARGET" \
    'umask 077; mkdir -p ~/.ssh; touch ~/.ssh/authorized_keys; chmod 700 ~/.ssh; chmod 600 ~/.ssh/authorized_keys'

  ssh "${BOOTSTRAP_SSH_OPTS[@]}" "$REMOTE_AGENTS_TARGET" \
    "grep -qxF '$pubkey' ~/.ssh/authorized_keys || printf '%s\n' '$pubkey' >> ~/.ssh/authorized_keys"
}

copy_keypair_to_remote() {
  if [[ "$COPY_LOCAL_KEYPAIR_TO_DESTINATION" != "1" ]]; then
    echo "Skipping local private key copy."
    echo "If the destination admin user needs GitHub access, generate a fresh key there."
    echo "Set COPY_LOCAL_KEYPAIR_TO_DESTINATION=1 only if you explicitly want to share this machine's keypair."
    return 0
  fi

  ssh agent-box 'mkdir -p ~/.ssh && chmod 700 ~/.ssh'
  scp "$LOCAL_KEY_PATH" "agent-box:~/.ssh/$LOCAL_KEY_NAME"
  scp "$LOCAL_KEY_PUB_PATH" "agent-box:~/.ssh/$LOCAL_KEY_NAME.pub"
  ssh agent-box "chmod 600 ~/.ssh/$LOCAL_KEY_NAME && chmod 644 ~/.ssh/$LOCAL_KEY_NAME.pub"
}

verify_non_interactive_ssh() {
  ssh -o BatchMode=yes agent-box 'printf "agent-box-ok\n"' >/dev/null
  ssh -o BatchMode=yes agent-box-agents 'printf "agent-box-agents-ok\n"' >/dev/null
}

install_remote_shell_helpers() {
  if grep -q 'agent_gui_switch()' "$HOME/.zshrc" 2>/dev/null; then
    echo "Shell helpers already exist in ~/.zshrc"
    return
  fi

  cat >> "$HOME/.zshrc" <<EOF

agent_gui_switch() {
  local remote_user="\$1"
  ssh agent-box "uid=\\\$(id -u \\"\$remote_user\\") && sudo /System/Library/CoreServices/Menu\\\\ Extras/User.menu/Contents/Resources/CGSession -switchToUserID \\\$uid"
}

alias agent-gui-admin='agent_gui_switch ${AGENT_BOX_ADMIN_USER}'
alias agent-gui-agents='agent_gui_switch ${AGENT_BOX_AGENTS_USER}'
EOF
}

echo "=== Preparing SSH settings for the destination Mac ==="
pick_local_key
rewrite_ssh_config
echo "SSH config updated"

echo "=== Checking connectivity ==="
ensure_host_reachable
echo "Port 22 is reachable on $AGENT_BOX_HOST"

echo "=== Bootstrapping password-based SSH ==="
bootstrap_remote_access
echo "Public key added to authorized_keys for both SSH aliases"

echo "=== Optional private-key copy for destination admin GitHub use ==="
copy_keypair_to_remote
echo "Key copy step complete"

echo "=== Verifying key-based SSH from the main Mac ==="
verify_non_interactive_ssh
echo "Key-based SSH is working"

echo "=== Installing shell helpers ==="
install_remote_shell_helpers
echo "Shell helpers installed"

echo
echo "=== DONE ==="
echo "Next:"
echo "  1. Return to the destination Mac."
echo "  2. Continue the admin bootstrap."
