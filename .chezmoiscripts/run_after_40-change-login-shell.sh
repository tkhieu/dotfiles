#!/bin/bash
# Change login shell to zsh. Linux uses the distro zsh so a broken Homebrew can
# never lock the user out; macOS keeps brew's zsh when installed, else /bin/zsh.
# Runs on every apply (exits early once done) so a skipped change is retried.

set -euo pipefail

# USER is not set in containers or some CI environments.
USER="${USER:-$(id -un)}"

TARGET_SHELL=""
case "$(uname -s)" in
  Darwin)
    if command -v brew >/dev/null 2>&1; then
      candidate="$(brew --prefix)/bin/zsh"
      [[ -x "$candidate" ]] && TARGET_SHELL="$candidate"
    fi
    [[ -z "$TARGET_SHELL" && -x /bin/zsh ]] && TARGET_SHELL=/bin/zsh
    ;;
  *)
    for candidate in /usr/bin/zsh /bin/zsh; do
      if [[ -x "$candidate" ]]; then
        TARGET_SHELL="$candidate"
        break
      fi
    done
    ;;
esac

if [[ -z "$TARGET_SHELL" ]]; then
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

# Never hang waiting for a password when there is no terminal to type it in.
if ! sudo -n true 2>/dev/null && [[ ! -t 0 ]]; then
  echo "[change-login-shell] sudo needs a password; run: chsh -s $TARGET_SHELL"
  exit 0
fi

if ! grep -qxF "$TARGET_SHELL" /etc/shells; then
  echo "[change-login-shell] adding $TARGET_SHELL to /etc/shells"
  echo "$TARGET_SHELL" | sudo tee -a /etc/shells >/dev/null
fi

echo "[change-login-shell] changing login shell to $TARGET_SHELL"
sudo chsh -s "$TARGET_SHELL" "$USER"
echo "[change-login-shell] done — start a new session to use zsh"
