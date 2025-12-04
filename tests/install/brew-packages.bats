#!/usr/bin/env bats
# tests/install/brew-packages.bats - Unit tests for install/brew-packages.sh

load '../test_helper/common'

setup() {
  setup_temp_dir
  # shellcheck source=../../install/common.sh
  source "$BATS_TEST_DIRNAME/../../install/common.sh"
  # shellcheck source=../../install/brew-packages.sh
  source "$BATS_TEST_DIRNAME/../../install/brew-packages.sh"
}

teardown() {
  teardown_temp_dir
}

@test "generate_brewfile creates valid brew entries" {
  run generate_brewfile "git" "zsh" "htop"
  [ "$status" -eq 0 ]
  [[ "$output" == *'brew "git"'* ]]
  [[ "$output" == *'brew "zsh"'* ]]
  [[ "$output" == *'brew "htop"'* ]]
}

@test "generate_brewfile handles single package" {
  run generate_brewfile "git"
  [ "$status" -eq 0 ]
  [[ "$output" == 'brew "git"' ]]
}

@test "generate_caskfile creates valid cask entries" {
  run generate_caskfile "google-chrome" "slack"
  [ "$status" -eq 0 ]
  [[ "$output" == *'cask "google-chrome"'* ]]
  [[ "$output" == *'cask "slack"'* ]]
}

@test "generate_caskfile handles single cask" {
  run generate_caskfile "iterm2"
  [ "$status" -eq 0 ]
  [[ "$output" == 'cask "iterm2"' ]]
}

@test "install_from_brewfile calls brew bundle with mocked brew" {
  # Define mock inside the test to ensure it's available in subshell
  brew() {
    echo "MOCK: brew $*"
    return 0
  }
  export -f brew

  local content='brew "git"'

  run install_from_brewfile "$content"
  [ "$status" -eq 0 ]
  [[ "$output" == *"MOCK: brew"* ]]
}

@test "main fails without brewfile argument" {
  run main
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage"* ]]
}

@test "main fails with nonexistent brewfile" {
  # Define mock inside the test to ensure it's available in subshell
  brew() {
    echo "MOCK: brew $*"
    return 0
  }
  export -f brew

  run main "/nonexistent/path/brewfile"
  [ "$status" -eq 1 ]
}

@test "main succeeds with valid brewfile" {
  # Define mock inside the test to ensure it's available in subshell
  brew() {
    echo "MOCK: brew $*"
    return 0
  }
  export -f brew

  # Create temp brewfile
  echo 'brew "git"' > "$TEST_TEMP_DIR/Brewfile"

  run main "$TEST_TEMP_DIR/Brewfile"
  [ "$status" -eq 0 ]
  [[ "$output" == *"MOCK: brew"* ]]
}
