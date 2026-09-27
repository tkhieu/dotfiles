# Dotfiles

![Tests](https://github.com/tkhieu/dotfiles/actions/workflows/test.yml/badge.svg)

Cross-platform dotfiles managed with [chezmoi](https://www.chezmoi.io). Supports macOS, Fedora, Ubuntu/Debian, and WSL2 with package groups you pick at install time, a fish-like zsh, and 1Password SSH commit signing.

## Quick Start

```bash
chezmoi init https://github.com/tkhieu/dotfiles.git   # asks which package groups to install
chezmoi diff      # preview changes
chezmoi apply     # apply configuration (asks for sudo on a fresh Linux machine)
exec zsh          # reload shell
```

### Prerequisites

| Platform | Requirements |
|----------|-------------|
| macOS | macOS 12+, Homebrew, Git, 1Password (SSH agent) |
| Fedora | Fedora 40+ (tested on 44), Git, curl, sudo |
| Ubuntu/Debian | Ubuntu 22.04+ (tested on 24.04), Git, curl, sudo |
| WSL2 | Windows 1Password app, Ubuntu in WSL |

Other Linux distros apply the dotfiles but skip the distro package step; install `zsh` and the [Homebrew prerequisites](https://docs.brew.sh/Homebrew-on-Linux#requirements) yourself.

## What's Managed

### Packages (`.chezmoidata/packages.yaml`)

On Linux the distro package manager (`dnf` or `apt`) installs only zsh and the Homebrew prerequisites (`packages.system`). Everything else comes from Homebrew and pnpm on every platform, so versions match across machines.

Packages are organised in groups. `chezmoi init` shows a checklist (defaults: `core`, `dev`, `ai`); `core` is always installed.

| Group | Contents |
|-------|----------|
| `core` | antidote, starship, mise, pnpm, fzf, neovim, git, gh, tig, git-extras, git-filter-repo, jq, htop, direnv, aria2, zstd |
| `dev` | bun, uv, pipx, shellcheck, bats-core, mysql-client, libyaml; pnpm: typescript, typescript-language-server, intelephense, ast-grep |
| `ai` | opencode, multica; pnpm: amp, crush, ecc-universal, pen |
| `devops` | awscli, aws-vault, act, dnscontrol |
| `media` | ffmpeg, imagemagick |
| `cloud-cli` | supabase; pnpm: vercel, wrangler, Shopify CLI, Google Workspace CLI |

macOS additionally installs the casks and formulae under `packages.darwin`.

```bash
chezmoi init --prompt                  # pick groups again, then `chezmoi apply`
chezmoi init --promptDefaults          # non-interactive: default groups
chezmoi init --promptMultichoice 'Package groups to install=core/devops'
```

Requires chezmoi 2.72+ (tested; `promptMultichoiceOnce` is needed for the group checklist). Machines initialised before groups existed keep working with the default groups; run `chezmoi init --prompt` to choose.

Scripts in `.chezmoiscripts/` run in order: distro packages (10), Homebrew (20), package groups + mise runtimes + pnpm globals (30), login shell (40, re-checked on every apply until it succeeds). The `run_onchange_` scripts re-run only when the rendered package list changes. `50-update-packages` runs `brew upgrade` and `pnpm update -g` on every apply; distro packages are left to the system updater, so an apply on a provisioned machine never needs sudo.

### Shell (Zsh)

`dot_zshrc` is the primary shell config. The login shell is the distro zsh on Linux (never Homebrew's) so a broken brew cannot lock you out; on macOS it is Homebrew's zsh when installed, otherwise `/bin/zsh`.

- **Plugins** via [antidote](https://antidote.sh) from `dot_zsh_plugins.txt`: oh-my-zsh lib + git aliases, zsh-completions, zsh-autosuggestions, zsh-abbr, fast-syntax-highlighting, zsh-history-substring-search, alias-tips
- **Prompt**: [Starship](https://starship.rs) (`dot_config/starship.toml`)
- **Runtimes**: [mise](https://mise.jdx.dev) (`dot_config/mise/config.toml`, Node LTS; reads `.nvmrc` / `.tool-versions`). Python per project with `uv`
- **SDKs**: Android, Google Cloud, Conda, Bun, Dart
- **Aliases**: `ccd` (claude --dangerously-skip-permissions), `flutter`/`dart` (via fvm)

| Key / input | Action |
|-------------|--------|
| `→` / `End` | Accept autosuggestion |
| `↑` / `↓` | Search history for the typed prefix |
| `Tab` | Completion menu (case-insensitive) |
| `Ctrl+R` / `Ctrl+T` / `Alt+C` | fzf history / files / directories |
| `dc`, `k`, `pn`, `cm` + space | Expand abbreviations (seeded once from `dot_config/zsh-abbr/create_user-abbreviations`; later `abbr add` changes are yours) |

`dot_bashrc` sources `/etc/bashrc` where bash does not read it itself (Fedora, macOS) and sets up Homebrew, `~/.local/bin`, pnpm and mise, so tools that spawn bash see the same environment. It replaces the distro's skeleton `~/.bashrc`.

### Git (`private_dot_gitconfig.tmpl`)

- SSH commit and tag signing via 1Password (ed25519)
- Cross-platform: macOS (`op-ssh-sign`), WSL (`op-ssh-sign-wsl`), Linux native (`/opt/1Password/op-ssh-sign`)
- Default branch: `main`, signing enabled by default
- `gh` as the credential helper for HTTPS on github.com and gist.github.com

### AWS (`dot_aws/private_config`)

- SSO profiles for peraichi (staging + production) and role profiles for the regulator accounts (MFA codes from 1Password via `mfa_process`, used with aws-vault)
- Stored with `0600` permissions via chezmoi `private_` prefix. **Not encrypted** -- chezmoi `private_` only sets file mode, it does not encrypt. The file contains only SSO start URLs and account IDs (no long-lived secrets). Use the `encrypted_` prefix + age/gpg if real secrets are ever added.

## File Structure

```
.
├── .chezmoi.toml.tmpl                   # Asks for package groups on `chezmoi init`
├── .chezmoidata/packages.yaml           # Package groups + distro prerequisites
├── .chezmoitemplates/linux-family       # Maps os-release to fedora / debian
├── .chezmoiscripts/                     # Ordered install / login-shell / update hooks
├── dot_zshrc                            # Zsh config (primary shell)
├── dot_zshenv                           # Skips Ubuntu's duplicate global compinit
├── dot_zsh_plugins.txt                  # antidote plugin list
├── dot_config/                          # starship.toml, mise/config.toml, zsh-abbr/
├── dot_bashrc                           # Bash config (fallback + tool environment)
├── private_dot_gitconfig.tmpl           # Git config (templated per OS)
├── dot_aws/private_config               # AWS SSO profiles (chmod 600, not encrypted)
├── private_dot_ssh/allowed_signers      # SSH signing verification
├── install/                             # Helpers sourced by the scripts
│   ├── common.sh                        #   Shared utilities (logging, pnpm guard)
│   ├── system-packages.sh               #   dnf / apt installer (skips installed packages)
│   └── pnpm-globals.sh                  #   pnpm global installer
├── tests/                               # BATS suites + container end-to-end tests
│   ├── config/  install/                #   Config validation, template rendering, unit tests
│   └── container/                       #   Containerfile, run.sh, verify.zsh
├── .github/workflows/test.yml           # CI: lint, BATS (macOS + Ubuntu), end-to-end (Fedora + Ubuntu)
└── Makefile                             # Test orchestration
```

### Chezmoi Naming Conventions

| Prefix | Meaning | Example |
|--------|---------|---------|
| `dot_` | Becomes `.` in `$HOME` | `dot_zshrc` -> `~/.zshrc` |
| `private_` | Target gets `0600`/`0700` permissions (not encrypted) | `private_dot_gitconfig.tmpl` |
| `run_onchange_` | Runs when its rendered content changes | Package install hooks |
| `run_` | Runs on every apply | Package update hook |
| `before_` / `after_` | Runs before / after files are written | Distro packages / login shell |
| `.tmpl` | Chezmoi template | OS-conditional rendering |

## Development

### Testing

```bash
make test              # lint + all BATS tests
make lint              # shellcheck (bash, install scripts, plain chezmoi scripts)
make test-config       # config validation, template rendering + shellcheck of rendered scripts
make test-install      # install script unit tests only
make validate-configs  # quick syntax check (zsh, bash, YAML)
make ci                # full CI pipeline locally

# End-to-end: apply in a clean Fedora/Ubuntu container (podman or docker) and verify zsh
make test-container DISTRO=fedora
make test-container DISTRO=ubuntu GROUPS_SELECTION=core/media
make test-container-clean DISTRO=fedora   # drop the cached Homebrew volume
```

`tests/container/run.sh` runs `chezmoi init --apply`, checks the login shell, runs `verify.zsh` (plugins, completion, key bindings, fzf, Starship, mise, time to first prompt < 300ms, no startup errors), and checks that a second apply re-runs no install script. Other distros (e.g. Arch, Rocky) are covered by template-rendering tests that assert the distro step is skipped. Never test with `toolbox`/`distrobox`: they share your real `$HOME`.

### CI Pipeline (GitHub Actions)

Jobs on push/PR to `main`:
1. **Lint** -- ShellCheck on shell scripts
2. **Test (macOS)** -- BATS tests, config validation, `chezmoi apply --dry-run`
3. **Test (Ubuntu)** -- BATS tests including template rendering
4. **End-to-end (fedora, ubuntu)** -- `make test-container` with docker

### Adding a Package

1. Edit `.chezmoidata/packages.yaml` -- add it to a group, alphabetically
2. Run `chezmoi apply` -- the rendered install script changes, so it re-runs `brew bundle`
3. Commit: `git commit -m "feat(packages): add <package-name>"`

### Modifying Shell Config

1. Edit `dot_zshrc` or `dot_zsh_plugins.txt`
2. Run `chezmoi apply && exec zsh`
3. Verify startup: `for i in 1 2 3; do time zsh -i -c exit; done` (target < 300ms)

### Migrating an Existing Machine

- **nvm / pyenv / asdf / rvm / sdkman → mise**: after `chezmoi apply`, check `node --version` and your pnpm globals in a new shell, then remove `~/.nvm` (and the others) and any installer lines they left in `~/.bashrc` / `~/.profile`.
- **Antigen / Powerlevel10k → antidote / Starship**: nothing to migrate; `~/.p10k.zsh` and `~/.antigen` can be deleted.
- Back up `~/.zshrc`, `~/.zshenv`, `~/.bashrc` and `~/.gitconfig` first; `chezmoi apply` replaces them (tools such as rustup may have added lines to `~/.zshenv`).

## Troubleshooting

| Problem | Diagnosis |
|---------|-----------|
| Slow shell startup (> 300ms) | `zsh -X -i 2>&1 \| head -20` to profile |
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
- [antidote](https://antidote.sh)
- [Starship](https://starship.rs)
- [mise](https://mise.jdx.dev)
- [Homebrew](https://brew.sh)

## Author

**Hieu Tran** (tr.kimhieu@gmail.com)
