# Chezmoi Dotfiles Repository

Personal macOS dotfiles management with chezmoi, featuring declarative package management, zsh configuration with modern plugins, and integrated AI-assisted development workflow via ClaudeKit.

## Quick Start

### Prerequisites
- macOS 12+ (Apple Silicon or Intel)
- Homebrew installed
- Git with SSH access configured
- 1Password with SSH agent (for commit signing)

### Installation (5 minutes)

```bash
# Clone repo
chezmoi init https://github.com/<username>/dotfiles.git

# Preview changes
chezmoi diff

# Apply configuration
chezmoi apply

# Verify installation
zsh --version
brew list | head -5
```

### First Time Setup
```bash
# 1. Clone with chezmoi
chezmoi init https://github.com/<username>/dotfiles.git

# 2. Review what will change
chezmoi diff

# 3. Apply (installs packages, creates dotfiles)
chezmoi apply

# 4. Reload shell
exec zsh

# 5. Verify (should be fast < 100ms)
time zsh -c "echo test"
```

## What's Included

### Package Management (45 packages)
**Homebrew Brews (22)**:
- Core: git, zsh, neovim, htop
- Node.js: npm, yarn, pnpm, nvm
- Python: pyenv, pip
- Version managers: asdf, rvm, sdkman
- Utils: direnv, antigen, git-extras, tig, act

**Homebrew Casks (23)**:
- Dev: VS Code, iTerm2, Docker Desktop, Postman
- Browsers: Google Chrome
- Productivity: Notion, Slack, Raycast, 1Password
- AI: Claude, Claude Code, LM Studio, Antigravity
- Database: DBeaver
- Media: Spotify, Mimestream

### Shell Configuration (Zsh)
- **Theme**: Powerlevel10k with instant prompt (fast startup)
- **Plugin Manager**: Antigen with oh-my-zsh plugins
- **Key plugins**: git, autosuggestions, fast-syntax-highlighting
- **Version managers**: nvm (lazy), pyenv, asdf, rvm, sdkman
- **SDKs**: Android, Google Cloud, Conda support
- **Custom aliases**: `ccd` (claude --dangerously-skip-permissions)

### Development Tools
- Git SSH signing via 1Password (cryptographic commits)
- AWS CLI with SSO profiles (peraichi-stg, peraichi-prod)
- Complete Node.js + Python + Go development setup
- Docker & container support
- Cloud SDKs (Android, GCP)

### AI Assistant Framework (ClaudeKit)
- 17 specialized agents (planner, developer, tester, reviewer, etc.)
- 60+ slash commands for development workflows
- 35 skills across 8 categories (dev, design, data, integration, etc.)
- 4 workflows for orchestration
- Integrates with development process

## File Structure

```
.
├── .chezmoidata/                  # Template data
│   └── packages.yaml              # Package definitions
├── .claude/                       # AI assistant configuration
│   ├── agents/                    # 17 agent definitions
│   ├── commands/                  # 60+ slash commands
│   ├── skills/                    # 35 specialized skills
│   └── workflows/                 # Orchestration workflows
├── bin/
│   └── chezmoi                    # Chezmoi binary
├── dot_zshrc                      # Primary shell configuration
├── dot_bashrc                     # Bash configuration
├── private_dot_gitconfig          # Git config (encrypted, SSH signed)
├── dot_aws/
│   └── private_config             # AWS SSO profiles (encrypted)
├── run_onchange_darwin-install-packages.sh.tmpl  # Auto-install hook
└── docs/                          # Documentation
    ├── project-overview-pdr.md    # Project requirements
    ├── codebase-summary.md        # Codebase structure
    ├── code-standards.md          # Development standards
    └── system-architecture.md     # Architecture & flows
```

### Chezmoi Naming
- `dot_*` → becomes `.*` in home dir (e.g., `dot_zshrc` → `~/.zshrc`)
- `private_dot_*` → encrypted at rest (e.g., `private_dot_gitconfig`)
- `run_onchange_*` → executes when referenced file changes

## Configuration Guide

### Adding Packages

Edit `.chezmoidata/packages.yaml`:
```yaml
packages:
  darwin:
    brews:
      - ripgrep    # Add new tools alphabetically
    casks:
      - raycast    # Add new apps alphabetically
```

Then apply:
```bash
chezmoi apply
```

### Customizing Shell

Edit `dot_zshrc`:
```bash
# Add custom aliases
alias myalias='command'

# Add custom functions
function myfunc() {
  # your code
}
```

Reload:
```bash
exec zsh
```

### Managing Git Configuration

Edit `private_dot_gitconfig`:
```ini
[user]
  name = Your Name
  email = your.email@example.com
```

Auto-encrypted by chezmoi (marked as `private_dot_*`).

### AWS Configuration

Edit `dot_aws/private_config`:
```ini
[profile peraichi-stg]
sso_start_url = https://...
sso_region = ap-southeast-1
```

### Version Managers

Configured in `dot_zshrc`:
- **Node.js (nvm)**: Lazy loaded (improve shell startup)
- **Python (pyenv)**: Initialized after nvm
- **Ruby (rvm)**: Initialized last
- **Multiple (asdf)**: Fallback for other languages

To use:
```bash
# Node versions
nvm install 20
nvm use 20

# Python versions
pyenv install 3.11.0
pyenv local 3.11.0

# Check active versions
node --version
python --version
ruby --version
```

## Daily Workflows

### Updating Configuration

```bash
# Edit any file in repo
chezmoi edit ~/.zshrc
# or
vim /Users/hieu.t/.local/share/chezmoi/dot_zshrc

# Apply changes
chezmoi apply

# Test (reload shell)
exec zsh
```

### Adding New Packages

```bash
# Edit packages
chezmoi edit ~/.chezmoidata/packages.yaml
# Add package name to brews or casks

# Apply (auto-installs via brew bundle)
chezmoi apply

# Verify
brew list | grep <package-name>
```

### Using AI Assistant (ClaudeKit)

```bash
# Plan implementation
/plan implement new feature

# Write code
/code with my implementation plan

# Run tests
/test

# Review code
/fix any issues

# Update docs
/docs:update
```

### Git Workflow

```bash
# Check what changed
chezmoi diff

# Commit changes (SSH signed via 1Password)
cd /Users/hieu.t/.local/share/chezmoi
git add .
git commit -m "feat(zshrc): add custom alias"

# Push
git push

# Sync on other machines
chezmoi pull
chezmoi apply
```

## Troubleshooting

### Slow Shell Startup

Check shell startup time:
```bash
time zsh -c "echo test"
```

If > 200ms, debug:
```bash
# Profile startup
zsh -X -i 2>&1 | head -20

# Disable plugins one by one in dot_zshrc
```

### Packages Not Installing

```bash
# Check brew is working
brew --version
brew doctor

# Manual install via bundle
brew bundle --file=/dev/stdin <<EOF
brew "git"
cask "google-chrome"
EOF
```

### Git Signing Not Working

```bash
# Verify 1Password is running
ssh-add -l

# Check git config
git config user.signingkey

# Test signing
git commit --allow-empty -m "test" -S
```

### SSH Connection Issues

```bash
# Verify SSH keys in 1Password
ssh-add -l

# Test SSH access
ssh -T git@github.com

# Check SSH config
cat ~/.ssh/config
```

## Common Commands

```bash
# Chezmoi essentials
chezmoi apply              # Apply all configurations
chezmoi diff               # Show what would change
chezmoi pull               # Pull & apply latest
chezmoi cd                 # Open repo directory
chezmoi edit <file>        # Edit managed file
chezmoi remove <file>      # Stop managing file

# Shell
exec zsh                   # Reload zsh
source ~/.zshrc            # Reload config
alias | grep <pattern>     # List aliases

# Packages
brew list                  # List installed packages
brew search <term>         # Search for package
brew install <pkg>         # Install single package
brew upgrade               # Upgrade all packages

# Git
git status                 # Check repo status
git log --oneline          # View commit history
git diff                   # Show changes
```

## Documentation

- **[Project Overview & PDR](docs/project-overview-pdr.md)** - Requirements & goals
- **[Codebase Summary](docs/codebase-summary.md)** - File structure & organization
- **[Code Standards](docs/code-standards.md)** - Development guidelines
- **[System Architecture](docs/system-architecture.md)** - Architecture & data flows

## Security

### Secrets Management
- No API keys in git (all in 1Password)
- Private files encrypted: `private_dot_*`
- SSH signing: Cryptographic commit signing
- AWS credentials: SSO via 1Password

### Safe Operations
```bash
# Always review before applying
chezmoi diff

# Dry run before applying
chezmoi apply --dry-run

# Verify integrity
chezmoi verify
```

## Performance

### Shell Startup
- **Target**: < 100ms with lazy loading
- **Optimization**: nvm lazy loads on first use
- **Measurement**: `time zsh -c "echo test"`

### Package Installation
- **Full setup**: ~10-15 minutes (network dependent)
- **Incremental**: Only new packages install
- **Atomic**: All or nothing via brew bundle

## Development Workflow

This repo uses ClaudeKit for AI-assisted development:

1. **Plan**: `/plan implement feature` - Create implementation plan
2. **Code**: `/code with plan` - Implement with AI assistance
3. **Test**: `/test` - Run tests and analyze results
4. **Review**: `/fix any issues` - Code quality review
5. **Docs**: `/docs:update` - Update documentation

### Code Standards
- **YANGI**: You Aren't Gonna Need It (no over-engineering)
- **KISS**: Keep It Simple, Stupid (clarity over cleverness)
- **DRY**: Don't Repeat Yourself (reuse code)
- **Files**: Max 200 lines per file
- **Naming**: kebab-case for files

## Contributing

### Making Changes
```bash
# Create feature branch
git checkout -b feature/description

# Make changes
chezmoi edit <file>
chezmoi apply

# Commit (SSH signed)
git commit -m "feat(component): description"

# Push & create PR
git push origin feature/description
```

### Testing Changes
```bash
# Before committing
chezmoi diff              # Review changes
chezmoi verify            # Check integrity
exec zsh                  # Test shell config

# Common issues
shellcheck <script>       # Check shell syntax
```

## Updating

### Pull Latest Changes
```bash
# From any machine
chezmoi pull           # Pull latest
chezmoi diff           # Review changes
chezmoi apply          # Apply

# Reload shell if zshrc changed
exec zsh
```

### Upgrading Packages
```bash
# Update package list
brew update

# Upgrade installed packages
brew upgrade

# Update casks
brew upgrade --cask

# Cleanup old versions
brew cleanup
```

## References

- [Chezmoi Official Docs](https://www.chezmoi.io)
- [Zsh Documentation](https://zsh.sourceforge.io)
- [Antigen - Zsh Plugin Manager](https://github.com/zsh-users/antigen)
- [Powerlevel10k - Zsh Theme](https://github.com/romkatv/powerlevel10k)
- [Homebrew Package Manager](https://brew.sh)

## License

Personal dotfiles repository. Feel free to use as template for your own setup.

## Author

**Hieu Tran** (tr.kimhieu@gmail.com)

- SSH key signing via 1Password
- Git default branch: main
- SSH-signed commits

---

**Last Updated**: 2025-12-03
**Version**: 1.0

For detailed information, see documentation in `./docs/`
