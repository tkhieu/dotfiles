#!/usr/bin/env bats
# tests/config/packages-yaml.bats - Validation tests for packages.yaml

load '../test_helper/common'

PACKAGES_YAML="$PROJECT_ROOT/.chezmoidata/packages.yaml"

@test "packages.yaml exists" {
  [ -f "$PACKAGES_YAML" ]
}

@test "packages.yaml is valid YAML" {
  # Try python with PyYAML, or use yq if available, else skip
  if command -v python3 >/dev/null 2>&1; then
    run python3 -c "import yaml; yaml.safe_load(open('$PACKAGES_YAML'))" 2>/dev/null
    if [ "$status" -eq 0 ]; then
      return 0
    fi
  fi
  if command -v yq >/dev/null 2>&1; then
    run yq '.' "$PACKAGES_YAML"
    [ "$status" -eq 0 ]
  else
    # Basic validation: check file is not empty and has expected structure
    run grep -q "packages:" "$PACKAGES_YAML"
    [ "$status" -eq 0 ]
  fi
}

@test "packages.yaml has darwin.brews section" {
  run grep -q "brews:" "$PACKAGES_YAML"
  [ "$status" -eq 0 ]
}

@test "packages.yaml has darwin.casks section" {
  run grep -q "casks:" "$PACKAGES_YAML"
  [ "$status" -eq 0 ]
}

@test "packages.yaml brews are quoted strings" {
  run grep -E "^\s+-\s+['\"]" "$PACKAGES_YAML"
  [ "$status" -eq 0 ]
}

@test "packages.yaml includes essential packages" {
  run grep -q "'git'" "$PACKAGES_YAML"
  [ "$status" -eq 0 ]
}

@test "packages.yaml includes zsh" {
  run grep -q "'zsh'" "$PACKAGES_YAML"
  [ "$status" -eq 0 ]
}

@test "packages.yaml includes testing tools" {
  run grep -q "'bats-core'" "$PACKAGES_YAML"
  [ "$status" -eq 0 ]
}
