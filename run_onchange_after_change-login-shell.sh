#!/bin/bash
# Change login shell to zsh. Prefers brew's zsh, falls back to system zsh.
# Runs after install scripts so zsh is guaranteed to be installed.

set -euo pipefail

TARGET_SHELL=""
if command -v brew >/dev/null 2>&1; then
  candidate="$(brew --prefix)/bin/zsh"
  [[ -x "$candidate" ]] && TARGET_SHELL="$candidate"
fi
if [[ -z "$TARGET_SHELL" ]]; then
  TARGET_SHELL="$(command -v zsh || true)"
fi
if [[ -z "$TARGET_SHELL" || ! -x "$TARGET_SHELL" ]]; then
  echo "[change-login-shell] zsh not found, skipping"
  exit 0
fi

case "$(uname -s)" in
  Darwin) current_shell="$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')" ;;
  *)      current_shell="$(getent passwd "$USER" | cut -d: -f7)" ;;
esac

if [[ "$current_shell" == "$TARGET_SHELL" ]]; then
  echo "[change-login-shell] already $TARGET_SHELL"
  exit 0
fi

if ! grep -qxF "$TARGET_SHELL" /etc/shells; then
  echo "[change-login-shell] adding $TARGET_SHELL to /etc/shells"
  echo "$TARGET_SHELL" | sudo tee -a /etc/shells >/dev/null
fi

echo "[change-login-shell] changing login shell to $TARGET_SHELL"
sudo chsh -s "$TARGET_SHELL" "$USER"
echo "[change-login-shell] done — start a new session to use zsh"
