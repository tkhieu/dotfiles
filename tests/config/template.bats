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
    run chezmoi execute-template --source "$PROJECT_ROOT" '{{ .chezmoi.sourceDir }}'
    [ "$status" -eq 0 ]
    [ "$output" = "$PROJECT_ROOT" ]
  else
    skip "chezmoi not available"
  fi
}

# Install script rendering per platform is covered by scripts-render.bats.
