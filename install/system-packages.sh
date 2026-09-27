#!/bin/bash
# install/system-packages.sh - Install distro packages (Homebrew prerequisites + zsh)

set -euo pipefail

# Source common utilities when not testing
if [[ "${BATS_TEST_FILENAME:-}" == "" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck source=./common.sh
  source "$SCRIPT_DIR/common.sh"
fi

# Run as root directly (containers, CI) and through sudo otherwise.
as_root() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  elif sudo -n true 2>/dev/null || [[ -t 0 ]]; then
    sudo "$@"
  else
    log_error "sudo needs a password but there is no terminal; run 'chezmoi apply' from a terminal"
    return 1
  fi
}

# Succeeds when the package (or "@group" for dnf groups) is already installed.
system_package_installed() {
  local family="$1" package="$2"
  case "$family" in
    fedora)
      if [[ "$package" == @* ]]; then
        dnf group list --installed --quiet 2>/dev/null | awk '{print $1}' | grep -qxF -- "${package#@}"
      else
        rpm -q "$package" >/dev/null 2>&1
      fi
      ;;
    debian)
      dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q "install ok installed"
      ;;
    *)
      return 1
      ;;
  esac
}

# Print the packages from the argument list that are not installed yet.
missing_system_packages() {
  local family="$1"
  shift
  local package
  for package in "$@"; do
    system_package_installed "$family" "$package" || echo "$package"
  done
}

# Install packages with the family's package manager, skipping installed ones
# so a fully provisioned machine never prompts for a sudo password.
install_system_packages() {
  local family="$1"
  shift
  local -a missing=()
  local package
  while IFS= read -r package; do
    [[ -n "$package" ]] && missing+=("$package")
  done < <(missing_system_packages "$family" "$@")

  if [[ ${#missing[@]} -eq 0 ]]; then
    log_info "System packages already installed"
    return 0
  fi

  log_info "Installing system packages: ${missing[*]}"
  case "$family" in
    fedora)
      as_root dnf install -y "${missing[@]}"
      ;;
    debian)
      as_root apt-get update
      as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "${missing[@]}"
      ;;
    *)
      log_error "Unsupported distro family: ${family:-unknown}"
      return 1
      ;;
  esac
}
