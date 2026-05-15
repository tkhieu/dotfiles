# Makefile - Test orchestration for chezmoi dotfiles
.PHONY: test lint lint-bash lint-install check install-test-deps validate-configs test-config test-install ci ci-lint ci-test

SHELL := /bin/bash
BATS := bats
SHELLCHECK := shellcheck

# Shellcheck excludes for zsh-specific syntax that shellcheck can't parse
# SC2296: zsh prompt expansion ${(%):-%n}
# SC1090: non-constant source (dynamic paths)
# SC1091: not following external sources
# SC2148: missing shebang (rc files sourced, not executed)
SC_EXCLUDES := -e SC2296 -e SC1090 -e SC1091 -e SC2148
# Extra excludes for dot_zshrc when parsed by the bash-based shellcheck
# SC2181: $? check (acceptable in the conda init block)
SC_ZSH_EXCLUDES := $(SC_EXCLUDES) -e SC2181
# SC2329: helper functions invoked indirectly via `export -f`
SC_TEST_EXCLUDES := -e SC1091 -e SC2329

# Test all (recursive)
test: lint
	@$(BATS) --recursive tests/

# Lint all shell files
lint: lint-bash lint-install
	@echo "Lint passed"

# Lint bash/zsh config files (with zsh-specific exclusions)
lint-bash:
	@$(SHELLCHECK) -s bash $(SC_EXCLUDES) dot_bashrc
	@$(SHELLCHECK) -s bash $(SC_ZSH_EXCLUDES) dot_zshrc

# Lint install scripts (strict)
lint-install:
	@$(SHELLCHECK) -x -e SC1091 install/*.sh
	@$(SHELLCHECK) -x $(SC_TEST_EXCLUDES) tests/test_helper/*.bash

# Full check
check: test
	@echo "All checks passed"

# Install test dependencies (for CI)
install-test-deps:
	brew install bats-core shellcheck

# Validate shell configs (quick syntax check)
validate-configs:
	@zsh -n dot_zshrc && echo "zshrc: OK"
	@bash -n dot_bashrc && echo "bashrc: OK"
	@(python3 -c "import yaml; yaml.safe_load(open('.chezmoidata/packages.yaml'))" 2>/dev/null || grep -q "packages:" .chezmoidata/packages.yaml) && echo "packages.yaml: OK"

# Run config tests only
test-config:
	@$(BATS) tests/config/

# Run install tests only
test-install:
	@$(BATS) tests/install/

# CI entry point
ci: ci-lint ci-test validate-configs
	@echo "CI passed"

# CI lint — identical to local lint (single source of truth, no divergence)
ci-lint: lint

# CI test (all tests must pass)
ci-test:
	@$(BATS) --recursive tests/
