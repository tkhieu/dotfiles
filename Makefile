# Makefile - Test orchestration for chezmoi dotfiles
.PHONY: test-container test-container-clean test lint lint-bash lint-install check install-test-deps validate-configs test-config test-install ci ci-lint ci-test

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
# SC2034: zsh special parameters (SAVEHIST, plugin settings) look unused to bash
# SC2154: zsh $functions / $+functions[...] parameter lookups
SC_ZSH_EXCLUDES := $(SC_EXCLUDES) -e SC2181 -e SC2034 -e SC2154
# SC2329 (SC2317 before shellcheck 0.10): helper functions invoked indirectly via `export -f`
SC_TEST_EXCLUDES := -e SC1091 -e SC2329 -e SC2317

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
	@$(SHELLCHECK) -x -e SC1091 install/*.sh .chezmoiscripts/*.sh
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

# --- End-to-end tests in a clean container (podman or docker) ---
# make test-container DISTRO=fedora|ubuntu [GROUPS_SELECTION=core/media]
ENGINE ?= $(shell command -v podman 2>/dev/null || command -v docker)
DISTRO ?= fedora
BASE_fedora := registry.fedoraproject.org/fedora:44
BASE_ubuntu := docker.io/library/ubuntu:24.04
GROUPS_SELECTION ?=

test-container:
	@test -n "$(BASE_$(DISTRO))" || { echo "unknown DISTRO=$(DISTRO) (fedora|ubuntu)"; exit 1; }
	$(ENGINE) build -t dotfiles-test:$(DISTRO) -f tests/container/Containerfile --build-arg BASE=$(BASE_$(DISTRO)) tests/container
	$(ENGINE) run --rm -e GROUPS_SELECTION="$(GROUPS_SELECTION)" \
	  -v "$(CURDIR)":/src:ro,z -v dotfiles-brew-$(DISTRO):/home/linuxbrew \
	  dotfiles-test:$(DISTRO) /src/tests/container/run.sh

# ":z" (shared SELinux label) lets several containers read the repo at once;
# ":Z" would relabel it privately and lock out a concurrently running container.

# Drop the cached Homebrew volume to test a completely fresh machine.
test-container-clean:
	-$(ENGINE) volume rm dotfiles-brew-$(DISTRO)
