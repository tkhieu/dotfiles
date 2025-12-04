#!/usr/bin/env bats
# tests/config/bashrc.bats - Validation tests for bash configuration

load '../test_helper/common'

BASHRC="$PROJECT_ROOT/dot_bashrc"

@test "dot_bashrc exists" {
  [ -f "$BASHRC" ]
}

@test "dot_bashrc has valid bash syntax" {
  run bash -n "$BASHRC"
  [ "$status" -eq 0 ]
}

@test "dot_bashrc sets RVM path" {
  run grep -q "\.rvm/bin" "$BASHRC"
  [ "$status" -eq 0 ]
}

@test "dot_bashrc exports PATH" {
  run grep -q "export PATH" "$BASHRC"
  [ "$status" -eq 0 ]
}
