#!/bin/bash
# install/pnpm-globals.sh - Install pnpm global packages

set -euo pipefail

# Source common utilities when not testing
if [[ "${BATS_TEST_FILENAME:-}" == "" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck source=./common.sh
  source "$SCRIPT_DIR/common.sh"
fi

# Install single global package
install_global() {
  local package="$1"
  ensure_pnpm || return 1
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
