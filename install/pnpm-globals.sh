#!/bin/bash
# install/pnpm-globals.sh - Install pnpm global packages

set -euo pipefail

# Source common utilities when not testing
if [[ "${BATS_TEST_FILENAME:-}" == "" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck source=./common.sh
  source "$SCRIPT_DIR/common.sh"
fi

# Ensure pnpm's global bin dir is on PATH.
# chezmoi runs install hooks in a non-interactive shell that does not source
# ~/.zshrc, and pnpm refuses global operations when its global bin dir is not
# on PATH. pnpm 11+ uses "$PNPM_HOME/bin" as the global bin dir; "$PNPM_HOME"
# is kept for pre-11 layout compatibility. Idempotent.
ensure_pnpm_global_path() {
  export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"
  local dir
  for dir in "$PNPM_HOME/bin" "$PNPM_HOME"; do
    case ":$PATH:" in
      *":$dir:"*) ;;
      *) export PATH="$dir:$PATH" ;;
    esac
  done
}

# Install single global package
install_global() {
  local package="$1"
  ensure_pnpm || return 1
  ensure_pnpm_global_path
  pnpm install -g "$package"
}

# Install multiple global packages
install_globals() {
  local -a packages=("$@")
  for pkg in "${packages[@]}"; do
    log_info "Installing: $pkg"
    install_global "$pkg"
  done
}

# Main
main() {
  if [[ $# -eq 0 ]]; then
    log_error "Usage: pnpm-globals.sh <package1> [package2...]"
    return 1
  fi
  install_globals "$@"
}

# Run main only if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
