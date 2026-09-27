#!/bin/bash
# End-to-end dotfiles test, run inside the container as `tester`.
# Env: GROUPS_SELECTION="core/media" to pick groups (default: template defaults).
set -euo pipefail

SRC=/src
PROMPT="Package groups to install"

step() { printf '\n=== %s ===\n' "$*"; }

step "chezmoi init --apply (first run)"
if [[ -n "${GROUPS_SELECTION:-}" ]]; then
  chezmoi init --source "$SRC" --promptMultichoice "$PROMPT=$GROUPS_SELECTION" --apply
else
  chezmoi init --source "$SRC" --promptDefaults --apply
fi

step "login shell"
login_shell="$(getent passwd "$(id -un)" | cut -d: -f7)"
echo "login shell: $login_shell"
[[ "$login_shell" == */zsh && "$login_shell" != /home/linuxbrew/* ]]

step "zsh behaviour (inside a pseudo-terminal, like a real terminal session)"
script -qec "zsh -i $SRC/tests/container/verify.zsh" /dev/null

step "no errors when started without a terminal (e.g. editors reading the env)"
no_tty_errors="$(zsh -i -c exit 2>&1 >/dev/null </dev/null)"
if [[ -n "$no_tty_errors" ]]; then
  echo "$no_tty_errors"
  echo "FAIL: zsh -i printed errors without a terminal"
  exit 1
fi

step "bash sees the managed tools"
bash -ic 'command -v brew && command -v mise && command -v starship'
if [[ "$(chezmoi data --format json)" == *'"dev"'* ]]; then
  bash -ic 'node --version && typescript-language-server --version'
fi

step "second apply is idempotent"
# No --verbose: it prints every run_ script's source, which contains the markers below.
if ! second_run="$(chezmoi apply 2>&1)"; then
  echo "$second_run" | tail -n 40
  echo "FAIL: second apply exited non-zero"
  exit 1
fi
if grep -qE '\[homebrew\] installing|Installing system packages|Homebrew Bundle complete|\[change-login-shell\] changing' <<<"$second_run"; then
  echo "$second_run"
  echo "FAIL: install scripts ran again on an unchanged apply"
  exit 1
fi
if [[ -n "$(chezmoi diff --exclude=scripts)" ]]; then
  chezmoi diff --exclude=scripts
  echo "FAIL: target state still differs after apply"
  exit 1
fi

step "PASS"
