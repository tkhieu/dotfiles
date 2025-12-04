#!/usr/bin/env bats
# tests/config/zshrc.bats - Validation tests for zsh configuration

load '../test_helper/common'

ZSHRC="$PROJECT_ROOT/dot_zshrc"

@test "dot_zshrc exists" {
  [ -f "$ZSHRC" ]
}

@test "dot_zshrc has valid zsh syntax" {
  if command -v zsh >/dev/null 2>&1; then
    run zsh -n "$ZSHRC"
    [ "$status" -eq 0 ]
  else
    skip "zsh not available"
  fi
}

@test "dot_zshrc sources p10k instant prompt" {
  run grep -q "p10k-instant-prompt" "$ZSHRC"
  [ "$status" -eq 0 ]
}

@test "dot_zshrc initializes antigen" {
  run grep -q "antigen.zsh" "$ZSHRC"
  [ "$status" -eq 0 ]
}

@test "dot_zshrc calls antigen apply" {
  run grep -q "antigen apply" "$ZSHRC"
  [ "$status" -eq 0 ]
}

@test "dot_zshrc sets up PATH" {
  run grep -q 'PATH' "$ZSHRC"
  [ "$status" -eq 0 ]
}

@test "dot_zshrc sources p10k theme" {
  run grep -q "p10k.zsh" "$ZSHRC"
  [ "$status" -eq 0 ]
}
