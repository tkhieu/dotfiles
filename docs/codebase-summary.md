# Codebase Summary

**Project**: Chezmoi Dotfiles Repository
**Last Updated**: 2025-12-04
**Version**: 1.0

## Project Overview

Personal macOS dotfiles management system using Chezmoi with:
- Declarative package management via Homebrew (45 packages)
- Modern zsh shell configuration (Powerlevel10k + Antigen)
- Git SSH signing via 1Password
- AWS CLI with SSO profiles
- AI-assisted development via ClaudeKit (17 agents, 60+ commands)
- Comprehensive test infrastructure (Phase 01-03: 19 unit tests + smoke tests)

## File Structure

```
/Users/hieu.t/.local/share/chezmoi/
├── .chezmoidata/
│   └── packages.yaml                          # Homebrew package definitions
├── .claude/                                   # AI assistant configuration
│   ├── agents/                                # 17 specialized agents
│   ├── commands/                              # 60+ slash commands
│   ├── skills/                                # 35 specialized skills
│   └── workflows/                             # Orchestration workflows
├── .opencode/                                 # OpenCode configuration
├── bin/
│   └── chezmoi                                # Chezmoi binary
├── install/                                   # Modular install scripts [NEW - Phase 02]
│   ├── common.sh                              # Shared utilities
│   ├── brew-packages.sh                       # Homebrew install functions
│   └── pnpm-globals.sh                        # pnpm global install functions
├── tests/                                     # Test infrastructure [Phase 01-03]
│   ├── smoke.bats                             # Smoke tests
│   ├── install/                               # Unit tests for install scripts [Phase 03]
│   │   ├── common.bats                        # Tests for common.sh (6 tests)
│   │   ├── brew-packages.bats                 # Tests for brew-packages.sh (8 tests)
│   │   └── pnpm-globals.bats                  # Tests for pnpm-globals.sh (5 tests)
│   └── test_helper/
│       └── common.bash                        # Shared test utilities (mocks, assertions)
├── dot_bashrc                                 # Bash configuration
├── dot_zshrc                                  # Zsh configuration (primary)
├── dot_asdfrc                                 # asdf version manager config
├── dot_aws/
│   └── private_config                         # AWS SSO profiles (encrypted)
├── private_dot_gitconfig                      # Git config (encrypted, SSH signed)
├── run_onchange_darwin-install-packages.sh.tmpl # Package installation hook (uses install/)
├── Makefile                                   # Test orchestration [Phase 01]
├── CLAUDE.md                                  # AI development guidelines
├── DOCUMENTATION.md                           # Project documentation
├── README.md                                  # Main documentation
├── .gitignore                                 # Git ignore rules
├── .repomixignore                             # Repomix ignore rules
└── docs/
    ├── codebase-summary.md                    # This file
    ├── project-overview-pdr.md                # Project requirements & goals
    ├── code-standards.md                      # Development standards
    └── system-architecture.md                 # Architecture & data flows
```

## Key Components

### 1. Configuration Management (.chezmoidata/)

**packages.yaml**: Single source of truth for system configuration
- **Homebrew Brews (28)**: git, zsh, neovim, node tooling, Python, Ruby, version managers, utilities
- **Homebrew Casks (16)**: Development tools (VS Code, Docker), productivity (Notion, Slack), AI (Claude, Claude Code), databases, media
- **pnpm Global Packages (2)**: uipro-cli, claudekit-cli

Chezmoi naming conventions:
- `dot_*` → `.*` in home directory
- `private_dot_*` → encrypted at rest
- `run_onchange_*` → executes on changes

### 2. Shell Configuration (dot_zshrc, dot_bashrc)

**Zsh Configuration**:
- Powerlevel10k theme with instant prompt (< 100ms startup)
- Antigen plugin manager with oh-my-zsh plugins
- Key plugins: git, autosuggestions, fast-syntax-highlighting
- Lazy-loaded version managers (nvm, pyenv, asdf, rvm, sdkman)
- SDK support: Android, Google Cloud, Conda
- Custom aliases and functions

**Bash Configuration**: Fallback configuration with similar setup

### 3. Test Infrastructure [Phase 01]

**Makefile**: Centralized test orchestration
- `make test` - Run all tests (linting + bats tests)
- `make lint` - Run all linters (bash + install scripts)
- `make lint-bash` - Check shell syntax (with zsh exclusions)
- `make lint-install` - Check install scripts
- `make check` - Full verification
- `make install-test-deps` - Install test dependencies (CI)

**Testing Tools**:
- **bats-core**: Bash Automated Testing System (smoke.bats)
- **shellcheck**: Shell script static analysis (SC2296, SC1090, SC1091, SC2148 excludes)

**Test Files**:
- `tests/smoke.bats` - Smoke test suite validating core functionality
- `tests/test_helper/common.bash` - Shared utilities (PROJECT_ROOT, temp directory setup, mocks, assertions)
- `tests/install/common.bats` - 6 unit tests for common.sh utilities (6 tests)
- `tests/install/brew-packages.bats` - 8 unit tests for brew package functions (8 tests)
- `tests/install/pnpm-globals.bats` - 5 unit tests for pnpm global installation (5 tests)

**Test Capabilities** (Phase 03):
- 19 unit tests across install scripts (Phase 03)
- Mock strategy: `mock_brew()` and `mock_pnpm()` functions for external command isolation
- Isolated temp directory per test (prevents cross-test contamination)
- Assert helpers: `assert_file_exists()`, `assert_dir_exists()`, etc.

### 4. Git & Security

**Git Configuration** (`private_dot_gitconfig`):
- SSH signing via 1Password (cryptographic commits)
- Default branch: main
- User identity (encrypted)

**AWS Configuration** (`dot_aws/private_config`):
- SSO profiles (peraichi-stg, peraichi-prod)
- Region: ap-southeast-1

### 5. AI Development Framework (ClaudeKit)

Located in `.claude/` directory:
- **17 Agents**: Specialized for planning, development, testing, review, documentation
- **60+ Commands**: Slash commands for development workflows
- **35 Skills**: Across 8 categories (dev, design, data, integration, etc.)
- **4 Workflows**: Orchestration, development rules, primary workflow, documentation

### 6. Documentation

**docs/ Directory**:
- `project-overview-pdr.md` - Product requirements and goals
- `code-standards.md` - Development guidelines and patterns
- `system-architecture.md` - System architecture and data flows
- `codebase-summary.md` - This file

### 7. Installation & Automation

**run_onchange_darwin-install-packages.sh.tmpl**: Chezmoi hook that:
- Automatically installs packages when packages.yaml changes
- Uses brew bundle for atomic installation
- Updates Homebrew and manages package lifecycle

## Development Patterns

### Chezmoi Workflow
1. Edit files in repository
2. Use `chezmoi edit ~/.zshrc` or direct edit
3. Review with `chezmoi diff`
4. Apply with `chezmoi apply`
5. Reload shell: `exec zsh`

### Package Management
1. Edit `.chezmoidata/packages.yaml`
2. Add package alphabetically to brews or casks
3. Run `chezmoi apply` (auto-installs via hook)
4. Verify: `brew list | grep <package-name>`

### Testing
1. Run `make test` for full test suite
2. Run `make lint` for linting only
3. Run `make lint-bash` for shell syntax
4. Run `make lint-install` for installation scripts

### Git Workflow
1. Make changes (edit files or run chezmoi apply)
2. Review: `chezmoi diff` or `git status`
3. Commit: `git commit -m "feat(component): description"` (SSH signed)
4. Push: `git push origin feature-branch`

## Dependencies

### Runtime
- macOS 12+
- Homebrew
- Git with SSH (1Password signed)
- Zsh shell
- Various CLI tools (managed via packages.yaml)

### Development/Testing
- bats-core (Bash testing framework)
- shellcheck (Shell linting)
- make (Test orchestration)

## Performance Targets

- Shell startup: < 100ms (lazy-loaded version managers)
- Full setup: 10-15 minutes (first install)
- Incremental updates: < 1 minute
- Test suite: < 5 seconds (smoke tests only)

## Security Considerations

1. **Encryption**: All `private_dot_*` files encrypted at rest
2. **SSH Signing**: Git commits signed via 1Password SSH agent
3. **Secrets**: No API keys in repository (all in 1Password)
4. **AWS**: SSO profiles managed via 1Password
5. **Safe Operations**: Always review with `chezmoi diff` before applying

### 8. Modular Installation Scripts (install/) [NEW - Phase 02]

**install/common.sh**: Shared utilities library
- `command_exists()` - Check if command is available
- `log_info()` / `log_error()` - Logging with prefixes
- `ensure_brew()` - Verify Homebrew availability
- `ensure_pnpm()` - Verify pnpm availability

**install/brew-packages.sh**: Homebrew package installation
- `generate_brewfile()` - Create Homebrew formula entries
- `generate_caskfile()` - Create Homebrew cask entries
- `install_from_brewfile()` - Install from Brewfile content
- Dual-mode: Can be sourced (for testing) or executed directly
- Supports stdin-based Brewfile for atomic installations

**install/pnpm-globals.sh**: Node.js global package installation
- `install_global()` - Install single pnpm global package
- `install_globals()` - Install multiple packages
- Dual-mode: Can be sourced (for testing) or executed directly
- Integrated with common.sh for utility access

**Dual-Mode Capability**: All scripts support both:
1. **Source Mode** (testing): `source install/script.sh` then call functions
2. **Execute Mode** (production): `./install/script.sh` direct execution

## Phase 01 Testing Infrastructure Completion

**Scope**: Added foundational testing infrastructure for shell scripts and configurations.

**Added Components**:
- Makefile with test orchestration targets
- bats-core integration for behavior testing
- shellcheck integration for shell script linting
- Test helper utilities (common.bash)
- Initial smoke tests (smoke.bats)
- SC exclusions for zsh-specific syntax

**Capabilities**:
- Linting shell configuration files
- Testing installation scripts
- Validating shell behavior
- Static analysis with exclusions for modern shell features

## Phase 02 Refactored Installation Scripts

**Scope**: Modularized install scripts for maintainability and testability.

**Motivation**:
- Single monolithic script difficult to test
- Functions isolated for unit testing capability
- Utilities separated for reuse across scripts
- Support both Chezmoi hooks and standalone execution

**Architecture**:
- **install/common.sh**: Central utilities library
- **install/brew-packages.sh**: Brew installation logic
- **install/pnpm-globals.sh**: Node.js global packages logic
- **run_onchange_darwin-install-packages.sh.tmpl**: Chezmoi hook sourcing modular scripts

**Integration Pattern**:
```bash
# Chezmoi hook sources modular scripts
source "$CHEZMOI_SOURCE_DIR/install/common.sh"
source "$CHEZMOI_SOURCE_DIR/install/pnpm-globals.sh"
install_globals uipro-cli claudekit-cli
```

**Testability**: Each script can be sourced independently for unit testing without executing main logic

## Phase 03 Unit Tests for Install Scripts

**Scope**: Comprehensive unit tests for all install script functions.

**Coverage**:
- **19 unit tests** across three install test suites
- `tests/install/common.bats` - 6 tests for common.sh utilities
- `tests/install/brew-packages.bats` - 8 tests for brew package functions
- `tests/install/pnpm-globals.bats` - 5 tests for pnpm globals installation

**Test Infrastructure**:
- **Mocking Strategy**: `mock_brew()` and `mock_pnpm()` functions isolate external commands
- **Isolation**: Each test runs in isolated temp directory (prevents cross-test contamination)
- **Assertions**: Helper functions `assert_file_exists()`, `assert_dir_exists()`, etc.
- **Setup/Teardown**: PROJECT_ROOT resolution, temp directory lifecycle management

**Makefile Enhancement**:
- Added `--recursive` flag to `make test` for recursive BATS discovery
- Supports both smoke tests and new install script unit tests

## Common Commands

```bash
# Chezmoi
chezmoi apply              # Apply configurations
chezmoi diff               # Preview changes
chezmoi pull               # Pull & apply latest
chezmoi cd                 # Open repo directory

# Testing
make test                  # Run all tests
make lint                  # Run linting only
make check                 # Full verification

# Shell
exec zsh                   # Reload zsh
source ~/.zshrc            # Reload config

# Packages
brew list                  # List installed
brew search <term>         # Search packages

# Git
git status                 # Check status
git commit -m "msg"        # Commit (SSH signed)
git push                   # Push changes
```

## Related Documentation

See `./docs/` for detailed information:
- **Project Overview & PDR**: requirements and goals
- **Code Standards**: development guidelines
- **System Architecture**: architecture and data flows
