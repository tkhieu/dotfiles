#!/bin/bash
# install/common.sh - Shared utilities for install scripts

set -euo pipefail

# Check if command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Log with prefix
log_info() {
  echo "[INFO] $*"
}

log_error() {
  echo "[ERROR] $*" >&2
}

# Ensure brew is available
ensure_brew() {
  if ! command_exists brew; then
    log_error "Homebrew not installed"
    return 1
  fi
}

# Ensure pnpm is available
ensure_pnpm() {
  if ! command_exists pnpm; then
    log_error "pnpm not installed"
    return 1
  fi
}
