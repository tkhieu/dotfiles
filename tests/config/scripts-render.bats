#!/usr/bin/env bats
# tests/config/scripts-render.bats - Render chezmoi scripts for each supported platform

load '../test_helper/common'

SCRIPTS="$PROJECT_ROOT/.chezmoiscripts"

setup() {
  command -v chezmoi >/dev/null 2>&1 || skip "chezmoi not available"
  setup_temp_dir
}

teardown() {
  teardown_temp_dir
}

# render <template> <os> <osRelease-id> <idLike> [groups-json | "none"]
# "none" renders like a machine initialised before package groups existed.
render() {
  local data groups=${5:-'["core","dev","ai"]'}
  if [[ "$groups" == none ]]; then
    data=$(printf '{"chezmoi":{"os":"%s","osRelease":{"id":"%s","idLike":"%s"}}}' "$2" "$3" "$4")
  else
    data=$(printf '{"chezmoi":{"os":"%s","osRelease":{"id":"%s","idLike":"%s"}},"groups":%s}' \
      "$2" "$3" "$4" "$groups")
  fi
  chezmoi execute-template --source "$PROJECT_ROOT" --override-data "$data" < "$1"
}

@test "system packages use dnf on fedora" {
  run render "$SCRIPTS/run_onchange_before_10-linux-system-packages.sh.tmpl" linux fedora ""
  [ "$status" -eq 0 ]
  [[ "$output" == *'install_system_packages "fedora"'*'"@development-tools"'*'"zsh"'* ]]
}

@test "system packages use the debian family on ubuntu" {
  run render "$SCRIPTS/run_onchange_before_10-linux-system-packages.sh.tmpl" linux ubuntu debian
  [ "$status" -eq 0 ]
  [[ "$output" == *'install_system_packages "debian"'*'"build-essential"'* ]]
}

@test "rhel clones are unsupported and skip (their dnf group ids differ)" {
  run render "$SCRIPTS/run_onchange_before_10-linux-system-packages.sh.tmpl" linux rocky "rhel centos fedora"
  [ "$status" -eq 0 ]
  [[ "$output" == *"unsupported distro 'rocky', skipping"* ]]
}

@test "unsupported distros skip without failing" {
  run render "$SCRIPTS/run_onchange_before_10-linux-system-packages.sh.tmpl" linux arch ""
  [ "$status" -eq 0 ]
  [[ "$output" == *"unsupported distro 'arch', skipping"* ]]
  [[ "$output" != *"install_system_packages"* ]]
}

@test "system package script is empty on macOS" {
  run render "$SCRIPTS/run_onchange_before_10-linux-system-packages.sh.tmpl" darwin "" ""
  [ "$status" -eq 0 ]
  [ -z "$(echo "$output" | tr -d '[:space:]')" ]
}

@test "install script renders only the selected groups plus core" {
  run render "$SCRIPTS/run_onchange_after_30-install-packages.sh.tmpl" linux fedora "" '["media"]'
  [ "$status" -eq 0 ]
  [[ "$output" == *'brew "starship"'* ]]
  [[ "$output" == *'brew "ffmpeg"'* ]]
  [[ "$output" != *'brew "uv"'* ]]
  [[ "$output" != *"install_globals"* ]]
  [[ "$output" != *"cask "* ]]
}

@test "install script adds pnpm globals and macOS casks when applicable" {
  run render "$SCRIPTS/run_onchange_after_30-install-packages.sh.tmpl" darwin "" ""
  [ "$status" -eq 0 ]
  [[ "$output" == *'install_globals'*'"@sourcegraph/amp"'* ]]
  [[ "$output" == *'cask "1password"'* ]]
  [[ "$output" == *'brew "asc"'* ]]
}

@test "install script installs pnpm whenever pnpm globals are selected" {
  run render "$SCRIPTS/run_onchange_after_30-install-packages.sh.tmpl" linux fedora "" '["ai"]'
  [ "$status" -eq 0 ]
  [[ "$output" == *'brew "pnpm"'* ]]
  [[ "$output" == *'install_globals'*'"@sourcegraph/amp"'* ]]
}

@test "machines without a groups setting get the default groups" {
  run render "$SCRIPTS/run_onchange_after_30-install-packages.sh.tmpl" darwin "" "" none
  [ "$status" -eq 0 ]
  [[ "$output" == *"selected package groups: core, dev, ai"* ]]
}

@test "install script trusts only the listed third-party tap formulae" {
  run render "$SCRIPTS/run_onchange_after_30-install-packages.sh.tmpl" linux fedora "" '["ai"]'
  [ "$status" -eq 0 ]
  [[ "$output" == *'brew trust --formula "multica-ai/tap/multica"'* ]]
  [[ "$output" != *'brew trust --formula "git"'* ]]
  [[ "$output" != *"--tap"* ]]
}

@test "an empty selection installs core only" {
  run render "$SCRIPTS/run_onchange_after_30-install-packages.sh.tmpl" linux fedora "" '[]'
  [ "$status" -eq 0 ]
  [[ "$output" == *"selected package groups: core"$'\n'* ]]
  [[ "$output" != *'brew "uv"'* ]]
}

@test "rendered scripts pass shellcheck" {
  command -v shellcheck >/dev/null 2>&1 || skip "shellcheck not available"
  local tmpl name
  for tmpl in "$SCRIPTS"/*.tmpl; do
    name="$TEST_TEMP_DIR/$(basename "$tmpl" .tmpl)"
    render "$tmpl" linux fedora "" > "$name"
    [[ -s "$name" ]] || continue
    shellcheck -x -e SC1091 "$name" || { echo "shellcheck failed: $tmpl"; return 1; }
  done
}
