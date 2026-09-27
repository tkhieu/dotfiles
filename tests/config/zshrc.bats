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

@test "dot_zshrc loads plugins with antidote" {
  run grep -q "antidote load" "$ZSHRC"
  [ "$status" -eq 0 ]
}

@test "dot_zshrc no longer uses antigen or powerlevel10k" {
  run grep -qE "antigen|p10k" "$ZSHRC"
  [ "$status" -ne 0 ]
}

@test "dot_zshrc sets up PATH" {
  run grep -q 'PATH' "$ZSHRC"
  [ "$status" -eq 0 ]
}

@test "dot_zshrc initializes starship, mise and fzf" {
  for tool in "starship init zsh" "mise activate zsh" "fzf --zsh"; do
    run grep -qF "$tool" "$ZSHRC"
    [ "$status" -eq 0 ] || { echo "missing: $tool"; return 1; }
  done
}

@test "dot_zshrc drops retired version managers" {
  run grep -qE "pyenv|NVM_|\\.rvm|sdkman|asdf" "$ZSHRC"
  [ "$status" -ne 0 ]
}

@test "zsh plugin list loads highlighting before history-substring-search" {
  plugins="$PROJECT_ROOT/dot_zsh_plugins.txt"
  hl=$(grep -n "fast-syntax-highlighting" "$plugins" | cut -d: -f1)
  hss=$(grep -n "zsh-history-substring-search" "$plugins" | cut -d: -f1)
  as=$(grep -n "zsh-autosuggestions" "$plugins" | cut -d: -f1)
  [ -n "$hl" ] && [ -n "$hss" ] && [ -n "$as" ]
  [ "$as" -lt "$hl" ] && [ "$hl" -lt "$hss" ]
}
