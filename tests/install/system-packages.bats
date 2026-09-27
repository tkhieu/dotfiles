#!/usr/bin/env bats
# tests/install/system-packages.bats - Unit tests for install/system-packages.sh

load '../test_helper/common'

setup() {
  setup_temp_dir
  # shellcheck source=../../install/common.sh
  source "$BATS_TEST_DIRNAME/../../install/common.sh"
  # shellcheck source=../../install/system-packages.sh
  source "$BATS_TEST_DIRNAME/../../install/system-packages.sh"
  CALLS="$TEST_TEMP_DIR/calls.log"
  export CALLS
  # Record privileged commands instead of running them.
  as_root() { echo "$*" >> "$CALLS"; }
  export -f as_root
}

teardown() {
  teardown_temp_dir
}

@test "installs only missing packages on fedora" {
  system_package_installed() { [[ "$2" == "git" ]]; }
  run install_system_packages fedora git zsh curl
  [ "$status" -eq 0 ]
  grep -qx "dnf install -y zsh curl" "$CALLS"
}

@test "uses apt-get non-interactively on debian" {
  system_package_installed() { return 1; }
  run install_system_packages debian zsh
  [ "$status" -eq 0 ]
  grep -qx "apt-get update" "$CALLS"
  grep -qx "env DEBIAN_FRONTEND=noninteractive apt-get install -y zsh" "$CALLS"
}

@test "does nothing when every package is installed" {
  system_package_installed() { return 0; }
  run install_system_packages fedora git zsh
  [ "$status" -eq 0 ]
  [[ "$output" == *"already installed"* ]]
  [ ! -s "$CALLS" ]
}

@test "fails for an unsupported family" {
  system_package_installed() { return 1; }
  run install_system_packages arch zsh
  [ "$status" -ne 0 ]
}
