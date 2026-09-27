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

@test "dot_bashrc keeps the distro bashrc" {
  run grep -qE "/etc/bashrc|/etc/bash.bashrc" "$BASHRC"
  [ "$status" -eq 0 ]
}

@test "dot_bashrc activates mise" {
  run grep -q "mise activate bash" "$BASHRC"
  [ "$status" -eq 0 ]
}

@test "dot_bashrc exports PATH" {
  run grep -q "export PATH" "$BASHRC"
  [ "$status" -eq 0 ]
}

@test "dot_bashrc and dot_zshrc keep the aws-vault file backend on Linux" {
  run grep -q "AWS_VAULT_BACKEND=file" "$BASHRC"
  [ "$status" -eq 0 ]
  run grep -q "AWS_VAULT_BACKEND=file" "$PROJECT_ROOT/dot_zshrc"
  [ "$status" -eq 0 ]
}

@test "dot_bashrc sources machine-specific files from ~/.bashrc.d" {
  run grep -q '.bashrc.d' "$BASHRC"
  [ "$status" -eq 0 ]
}
