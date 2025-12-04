#!/usr/bin/env bats
# Smoke tests to verify testing infrastructure

load 'test_helper/common'

@test "shellcheck is available" {
  run shellcheck --version
  [ "$status" -eq 0 ]
}

@test "bats is working" {
  run echo "hello"
  [ "$output" = "hello" ]
}
