#!/usr/bin/env bats
# tests/config/packages-yaml.bats - Validation tests for packages.yaml

load '../test_helper/common'

PACKAGES_YAML="$PROJECT_ROOT/.chezmoidata/packages.yaml"
CONFIG_TMPL="$PROJECT_ROOT/.chezmoi.toml.tmpl"

setup() {
  if ! python3 -c "import yaml" 2>/dev/null && ! command -v yq >/dev/null 2>&1; then
    skip "no YAML parser (python3-yaml or yq) available"
  fi
}

# Print packages.yaml as JSON.
yaml_json() {
  if python3 -c "import yaml" 2>/dev/null; then
    python3 -c "import json,sys,yaml; print(json.dumps(yaml.safe_load(open(sys.argv[1]))))" "$PACKAGES_YAML"
  else
    yq -o=json '.' "$PACKAGES_YAML"
  fi
}

@test "packages.yaml exists" {
  [ -f "$PACKAGES_YAML" ]
}

@test "packages.yaml is valid YAML" {
  run yaml_json
  [ "$status" -eq 0 ]
}

@test "packages.yaml brews are quoted strings" {
  run grep -E "^\s+-\s+['\"]" "$PACKAGES_YAML"
  [ "$status" -eq 0 ]
}

@test "packages.yaml has system packages for fedora and debian with zsh" {
  json="$(yaml_json)"
  run jq -e '.packages.system.fedora | index("zsh")' <<<"$json"
  [ "$status" -eq 0 ]
  run jq -e '.packages.system.debian | index("zsh")' <<<"$json"
  [ "$status" -eq 0 ]
}

@test "core group includes the shell toolchain" {
  json="$(yaml_json)"
  for pkg in git fzf antidote starship mise; do
    run jq -e --arg p "$pkg" '.packages.groups.core.brew | index($p)' <<<"$json"
    [ "$status" -eq 0 ] || { echo "missing core package: $pkg"; return 1; }
  done
}

@test "every group offered by .chezmoi.toml.tmpl exists in packages.yaml" {
  json="$(yaml_json)"
  offered="$(grep -o 'list "core"[^-]*' "$CONFIG_TMPL" | head -1 | grep -o '"[^"]*"' | tr -d '"')"
  [ -n "$offered" ]
  for group in $offered; do
    run jq -e --arg g "$group" '.packages.groups | has($g)' <<<"$json"
    [ "$status" -eq 0 ] || { echo "group not defined: $group"; return 1; }
  done
}

@test "retired tools are not listed" {
  for pkg in antigen nvm pyenv asdf aws-sso-util semgrep grpc; do
    run grep -qE "^\s+-\s+'$pkg'" "$PACKAGES_YAML"
    [ "$status" -ne 0 ] || { echo "retired package still listed: $pkg"; return 1; }
  done
}

@test "zsh is not installed through brew" {
  run grep -qE "^\s+-\s+'zsh'" <(sed -n '/^  groups:/,$p' "$PACKAGES_YAML")
  [ "$status" -ne 0 ]
}
