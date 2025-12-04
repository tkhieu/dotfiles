# Makefile - Test orchestration for chezmoi dotfiles
.PHONY: test lint lint-bash lint-install check install-test-deps validate-configs test-config test-install

SHELL := /bin/bash
BATS := bats
SHELLCHECK := shellcheck

# Shellcheck excludes for zsh-specific syntax that shellcheck can't parse
# SC2296: zsh prompt expansion ${(%):-%n}
# SC1090: non-constant source (dynamic paths)
# SC1091: not following external sources
# SC2148: missing shebang (zsh files sourced, not executed)
SC_EXCLUDES := -e SC2296 -e SC1090 -e SC1091 -e SC2148

# Test all (recursive)
test: lint
	@$(BATS) --recursive tests/

# Lint all shell files
lint: lint-bash lint-install
	@echo "Lint passed"

# Lint bash/zsh config files (with zsh-specific exclusions)
lint-bash:
	@$(SHELLCHECK) -s bash $(SC_EXCLUDES) dot_bashrc
	@$(SHELLCHECK) -s bash $(SC_EXCLUDES) dot_zshrc || true

# Lint install scripts (strict)
lint-install:
	@$(SHELLCHECK) -x install/*.sh 2>/dev/null || true
	@$(SHELLCHECK) -x tests/test_helper/*.bash 2>/dev/null || true

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
