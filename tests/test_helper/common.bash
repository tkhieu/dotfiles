#!/usr/bin/env bash
# Common test utilities for BATS tests

# Setup temp directory for each test
setup_temp_dir() {
  export TEST_TEMP_DIR
  TEST_TEMP_DIR=$(mktemp -d)
  export HOME="$TEST_TEMP_DIR"
}

# Cleanup temp directory
teardown_temp_dir() {
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
