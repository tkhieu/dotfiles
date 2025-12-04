#!/usr/bin/env bats
# tests/install/pnpm-globals.bats - Unit tests for install/pnpm-globals.sh

load '../test_helper/common'

setup() {
  setup_temp_dir
  # shellcheck source=../../install/common.sh
  source "$BATS_TEST_DIRNAME/../../install/common.sh"
  # shellcheck source=../../install/pnpm-globals.sh
  source "$BATS_TEST_DIRNAME/../../install/pnpm-globals.sh"
}

teardown() {
  teardown_temp_dir
}

@test "install_global calls pnpm with correct args" {
  mock_pnpm

  run install_global "typescript"
  [ "$status" -eq 0 ]
  [[ "$output" == *"pnpm install -g typescript"* ]]
}

@test "install_globals installs multiple packages" {
  mock_pnpm

  run install_globals "pkg1" "pkg2"
  [ "$status" -eq 0 ]
  [[ "$output" == *"pkg1"* ]]
  [[ "$output" == *"pkg2"* ]]
}

@test "install_globals logs info for each package" {
  mock_pnpm

  run install_globals "typescript" "eslint"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[INFO]"* ]]
  [[ "$output" == *"Installing"* ]]
}

@test "main fails without arguments" {
  run main
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage"* ]]
}

@test "main succeeds with package arguments" {
  mock_pnpm

  run main "typescript" "eslint"
  [ "$status" -eq 0 ]
  [[ "$output" == *"typescript"* ]]
  [[ "$output" == *"eslint"* ]]
}
