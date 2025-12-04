#!/usr/bin/env bats
# tests/config/template.bats - Validation tests for chezmoi templates

load '../test_helper/common'

@test "chezmoi execute-template works for os" {
  if command -v chezmoi >/dev/null 2>&1; then
    run chezmoi execute-template '{{ .chezmoi.os }}'
    [ "$status" -eq 0 ]
    [[ "$output" == "darwin" ]] || [[ "$output" == "linux" ]]
  else
    skip "chezmoi not available"
  fi
}

@test "chezmoi execute-template works for sourceDir" {
  if command -v chezmoi >/dev/null 2>&1; then
    run chezmoi execute-template '{{ .chezmoi.sourceDir }}'
    [ "$status" -eq 0 ]
    [[ "$output" == *"chezmoi"* ]]
  else
    skip "chezmoi not available"
  fi
}

@test "install template renders for darwin" {
  local template="$PROJECT_ROOT/run_onchange_darwin-install-packages.sh.tmpl"
  if command -v chezmoi >/dev/null 2>&1; then
    run chezmoi execute-template < "$template"
    [ "$status" -eq 0 ]
    [[ "$output" == *"brew bundle"* ]]
  else
    skip "chezmoi not available"
  fi
}

@test "install template includes pnpm globals" {
  local template="$PROJECT_ROOT/run_onchange_darwin-install-packages.sh.tmpl"
  if command -v chezmoi >/dev/null 2>&1; then
    run chezmoi execute-template < "$template"
    [ "$status" -eq 0 ]
    [[ "$output" == *"install_globals"* ]]
  else
    skip "chezmoi not available"
  fi
}
