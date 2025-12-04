#!/bin/bash
# install/brew-packages.sh - Install Homebrew packages from Brewfile

set -euo pipefail

# Source common utilities when not testing
if [[ "${BATS_TEST_FILENAME:-}" == "" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck source=./common.sh
  source "$SCRIPT_DIR/common.sh"
fi

# Generate Brewfile content from package list
generate_brewfile() {
  local -a brews=("$@")
  for pkg in "${brews[@]}"; do
    echo "brew \"$pkg\""
  done
}

# Generate cask entries
generate_caskfile() {
  local -a casks=("$@")
  for cask in "${casks[@]}"; do
    echo "cask \"$cask\""
  done
}

# Install from Brewfile content
install_from_brewfile() {
  local brewfile_content="$1"
  ensure_brew || return 1
  echo "$brewfile_content" | brew bundle --file=/dev/stdin
}

# Main execution (only when run directly)
main() {
  local brewfile="${1:-}"
  if [[ -n "$brewfile" && -f "$brewfile" ]]; then
    ensure_brew || return 1
    brew bundle --file="$brewfile"
  else
    log_error "Usage: brew-packages.sh <brewfile>"
    return 1
  fi
}

# Run main only if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
