#!/usr/bin/env bats
# tests/config/tool-configs.bats - Validation tests for mise, starship and zsh-abbr configs

load '../test_helper/common'

toml_valid() {
  python3 -c "import sys,tomllib; tomllib.load(open(sys.argv[1],'rb'))" "$1"
}

setup() {
  python3 -c "import tomllib" 2>/dev/null || skip "python3 >= 3.11 (tomllib) not available"
}

@test "mise config is valid TOML and pins node" {
  run toml_valid "$PROJECT_ROOT/dot_config/mise/config.toml"
  [ "$status" -eq 0 ]
  run python3 -c "import sys,tomllib; assert tomllib.load(open(sys.argv[1],'rb'))['tools']['node']" "$PROJECT_ROOT/dot_config/mise/config.toml"
  [ "$status" -eq 0 ]
}

@test "starship config is valid TOML" {
  run toml_valid "$PROJECT_ROOT/dot_config/starship.toml"
  [ "$status" -eq 0 ]
}

@test "zsh-abbr abbreviations are only created, never overwritten" {
  [ -f "$PROJECT_ROOT/dot_config/zsh-abbr/create_user-abbreviations" ]
  run grep -vcE '^abbr "[^"]+"="[^"]+"$' "$PROJECT_ROOT/dot_config/zsh-abbr/create_user-abbreviations"
  [ "$output" = "0" ]
}
