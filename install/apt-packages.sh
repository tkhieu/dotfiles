#!/bin/bash
# install/apt-packages.sh - Install apt prerequisite packages

set -euo pipefail

# Source common utilities when not testing
if [[ "${BATS_TEST_FILENAME:-}" == "" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck source=./common.sh
  source "$SCRIPT_DIR/common.sh"
fi

# Install apt packages
install_apt_packages() {
  local -a packages=("$@")
  if [[ ${#packages[@]} -eq 0 ]]; then
    log_error "No packages specified"
    return 1
  fi
  log_info "Installing apt packages: ${packages[*]}"
  sudo apt-get update
  sudo apt-get install -y "${packages[@]}"
}

# Main
main() {
  if [[ $# -eq 0 ]]; then
    log_error "Usage: apt-packages.sh <package1> [package2...]"
    return 1
  fi
  install_apt_packages "$@"
}

# Run main only if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
