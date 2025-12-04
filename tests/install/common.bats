#!/usr/bin/env bats
# tests/install/common.bats - Unit tests for install/common.sh

load '../test_helper/common'

setup() {
  setup_temp_dir
  # shellcheck source=../../install/common.sh
  source "$BATS_TEST_DIRNAME/../../install/common.sh"
}

teardown() {
  teardown_temp_dir
}

@test "command_exists returns 0 for existing command" {
  run command_exists bash
  [ "$status" -eq 0 ]
}

@test "command_exists returns 1 for missing command" {
  run command_exists nonexistent_command_xyz
  [ "$status" -eq 1 ]
}

@test "log_info outputs with INFO prefix" {
  run log_info "test message"
  [[ "$output" == *"[INFO]"* ]]
  [[ "$output" == *"test message"* ]]
}

@test "log_error outputs with ERROR prefix" {
  run log_error "error message"
  [[ "$output" == *"[ERROR]"* ]]
  [[ "$output" == *"error message"* ]]
}

@test "ensure_brew succeeds when brew available" {
  # brew is available on this macOS system
  if command -v brew >/dev/null 2>&1; then
    run ensure_brew
    [ "$status" -eq 0 ]
  else
    skip "brew not installed"
  fi
}

@test "ensure_pnpm succeeds when pnpm available" {
  # pnpm is available on this system
  if command -v pnpm >/dev/null 2>&1; then
    run ensure_pnpm
    [ "$status" -eq 0 ]
  else
    skip "pnpm not installed"
  fi
}
