#!/usr/bin/env bash
# Common test utilities for BATS tests

# Project root - resolved from test helper location
export PROJECT_ROOT
PROJECT_ROOT="$(cd "${BATS_TEST_DIRNAME:-$(dirname "${BASH_SOURCE[0]}")}/../.." && pwd)"

# Setup temp directory for each test
setup_temp_dir() {
  export TEST_TEMP_DIR
  TEST_TEMP_DIR=$(mktemp -d)
  export ORIGINAL_HOME="$HOME"
  export HOME="$TEST_TEMP_DIR"
}

# Cleanup temp directory
teardown_temp_dir() {
  export HOME="$ORIGINAL_HOME"
  [[ -d "$TEST_TEMP_DIR" ]] && rm -rf "$TEST_TEMP_DIR"
}

# Mock brew command
mock_brew() {
  brew() {
    echo "MOCK: brew $*"
    return 0
  }
  export -f brew
}

# Mock pnpm command
mock_pnpm() {
  pnpm() {
    echo "MOCK: pnpm $*"
    return 0
  }
  export -f pnpm
}

# Assert file exists
assert_file_exists() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    echo "Expected file to exist: $file"
    return 1
  fi
}

# Assert directory exists
assert_dir_exists() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    echo "Expected directory to exist: $dir"
    return 1
  fi
}
