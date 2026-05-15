# Dotfiles

![Tests](https://github.com/tkhieu/dotfiles/actions/workflows/test.yml/badge.svg)

Cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io). Supports macOS, Linux, and WSL2 with declarative package management, zsh configuration, and 1Password SSH commit signing.

## Quick Start

```bash
# Install chezmoi and apply dotfiles
chezmoi init https://github.com/tkhieu/dotfiles.git
chezmoi diff      # preview changes
chezmoi apply     # apply configuration
exec zsh          # reload shell
```

### Prerequisites

| Platform | Requirements |
|----------|-------------|
| macOS | macOS 12+, Homebrew, Git, 1Password (SSH agent) |
| Linux | Ubuntu/Debian, Git, curl |
| WSL2 | Windows 1Password app, Ubuntu in WSL |

## What's Managed

### Packages (`.chezmoidata/packages.yaml`)

| Category | macOS | Linux | Examples |
|----------|-------|-------|----------|
| Homebrew brews | 39 | 39 | git, zsh, neovim, fzf, pyenv, awscli |
| Homebrew casks | 40 | -- | VS Code, Docker Desktop, Claude, 1Password, Raycast |
| pnpm globals | 7 | 7 | vercel, wrangler, amp, claudekit-cli |
| apt prerequisites | -- | 5 | build-essential, curl, procps |

Packages install automatically on `chezmoi apply` via `run_onchange_` scripts triggered by changes to `packages.yaml`.

### Shell (Zsh)

`dot_zshrc` -- primary shell config (~215 lines):

- **Theme**: Powerlevel10k with instant prompt (< 100ms startup)
- **Plugins** (via Antigen): git, aws, pip, terraform, heroku, git-extras, zsh-autosuggestions, fast-syntax-highlighting, alias-tips
- **Version managers**: nvm (lazy-loaded), pyenv, asdf, rvm, sdkman
- **SDKs**: Android, Google Cloud, Conda, Bun, Dart
- **Tools**: direnv, dnscontrol, fvm, pnpm, JBang, Krew
- **Aliases**: `ccd` (claude --dangerously-skip-permissions), `flutter`/`dart` (via fvm)

### Git (`private_dot_gitconfig.tmpl`)

- SSH commit signing via 1Password (ed25519)
- Cross-platform: macOS (`op-ssh-sign`), WSL (`op-ssh-sign-wsl`), Linux native (`/opt/1Password/op-ssh-sign`)
- Default branch: `main`, signing enabled by default

### AWS (`dot_aws/private_config`)

- SSO profiles for peraichi (staging + production)
- Stored with `0600` permissions via chezmoi `private_` prefix. **Not encrypted** -- chezmoi `private_` only sets file mode, it does not encrypt. The file contains only SSO start URLs and account IDs (no long-lived secrets). Use the `encrypted_` prefix + age/gpg if real secrets are ever added.

## File Structure

```
.
├── .chezmoidata/packages.yaml           # Declarative package lists
├── dot_zshrc                            # Zsh config (primary shell)
├── dot_bashrc                           # Bash config (minimal fallback)
├── dot_asdfrc                           # asdf version manager config
├── private_dot_gitconfig.tmpl           # Git config (templated per OS)
├── dot_aws/private_config               # AWS SSO profiles (chmod 600, not encrypted)
├── private_dot_ssh/allowed_signers      # SSH signing verification
├── run_onchange_darwin-install-*.tmpl   # macOS package install hook
├── run_onchange_linux-install-*.tmpl    # Linux package install hook
├── run_darwin-update-packages.sh.tmpl   # macOS update hook
├── run_linux-update-packages.sh.tmpl    # Linux update hook
├── install/                             # Modular install scripts
│   ├── common.sh                        #   Shared utilities (logging, pnpm guard)
│   └── pnpm-globals.sh                  #   pnpm global installer
├── tests/                               # BATS test suites
│   ├── smoke.bats                       #   Infrastructure smoke tests
│   ├── config/                          #   Config validation
│   └── install/                         #   Install script unit tests
├── .github/workflows/test.yml           # CI: lint + test (macOS & Ubuntu)
└── Makefile                             # Test orchestration
```

### Chezmoi Naming Conventions

| Prefix | Meaning | Example |
|--------|---------|---------|
| `dot_` | Becomes `.` in `$HOME` | `dot_zshrc` -> `~/.zshrc` |
| `private_dot_` | Encrypted at rest | `private_dot_gitconfig.tmpl` |
| `run_onchange_` | Runs when data changes | Package install hooks |
| `run_` | Runs on every apply | Package update hooks |
| `.tmpl` | Chezmoi template | OS-conditional rendering |

## Development

### Testing

```bash
make test              # lint + all BATS tests
make lint              # shellcheck (bash + install scripts)
make test-config       # config validation tests only
make test-install      # install script unit tests only
make validate-configs  # quick syntax check (zsh, bash, YAML)
make ci                # full CI pipeline locally
```

### CI Pipeline (GitHub Actions)

4 parallel jobs on push/PR to `main`:
1. **Lint** -- ShellCheck on shell scripts
2. **Test (macOS)** -- BATS tests + config validation
3. **Test (Ubuntu)** -- BATS tests
4. **Template Validation** -- chezmoi template rendering

### Adding a Package

1. Edit `.chezmoidata/packages.yaml` -- add to the appropriate section alphabetically
2. Run `chezmoi apply` -- triggers `run_onchange_` hook, installs via `brew bundle`
3. Commit: `git commit -m "feat(packages): add <package-name>"`

### Modifying Shell Config

1. Edit `dot_zshrc`
2. Run `chezmoi apply && exec zsh`
3. Verify startup: `time zsh -c "echo test"` (target < 100ms)

## Troubleshooting

| Problem | Diagnosis |
|---------|-----------|
| Slow shell startup (> 200ms) | `zsh -X -i 2>&1 \| head -20` to profile |
| Packages not installing | `brew doctor`, check `packages.yaml` syntax |
| Git signing fails | Verify 1Password is running: `ssh-add -l` |
| SSH issues | `ssh -T git@github.com` to test connectivity |

## Common Commands

```bash
chezmoi apply          # apply all configurations
chezmoi diff           # preview pending changes
chezmoi pull           # pull + apply latest from remote
chezmoi edit <file>    # edit a managed file
chezmoi cd             # cd to chezmoi source directory
```

## References

- [Chezmoi Docs](https://www.chezmoi.io)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Antigen](https://github.com/zsh-users/antigen)
- [Homebrew](https://brew.sh)

## Author

**Hieu Tran** (tr.kimhieu@gmail.com)
