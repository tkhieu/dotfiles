# Documentation Index

Welcome to the comprehensive documentation for this chezmoi dotfiles repository.

## Getting Started

**New to this repository?** Start here:
- **[README.md](README.md)** - Quick start guide & daily reference (5-minute setup)

## Core Documentation

### 1. Project Overview & Requirements
**File**: [docs/project-overview-pdr.md](docs/project-overview-pdr.md)

What you need to know about the project:
- Project purpose & target platform
- Functional & non-functional requirements
- Key features overview
- Success criteria
- Development workflow approach
- Dependencies & maintenance strategy

**Read this if**: You're a manager, stakeholder, or need high-level project context.

### 2. Codebase Structure
**File**: [docs/codebase-summary.md](docs/codebase-summary.md)

Understanding the repository organization:
- Directory structure breakdown
- File naming conventions (dot_, private_dot_, run_onchange_)
- Configuration files explained
- ClaudeKit agent system (17 agents)
- Development standards overview
- Security & encryption patterns

**Read this if**: You're onboarding as a developer or need to understand code organization.

### 3. Code Standards & Guidelines
**File**: [docs/code-standards.md](docs/code-standards.md)

Development rules & conventions:
- YANGI/KISS/DRY principles
- File organization (200-line limit, kebab-case naming)
- Shell scripting standards
- YAML configuration format
- Chezmoi template patterns
- Git commit conventions
- Security standards
- Performance targets
- Code review checklist

**Read this if**: You're contributing code, reviewing PRs, or implementing features.

### 4. System Architecture
**File**: [docs/system-architecture.md](docs/system-architecture.md)

Technical design & implementation:
- Architectural overview with diagrams
- 8 component layers explained
- Data flow diagrams (installation, updates, packages)
- Technology stack
- Scaling & extensibility
- Performance characteristics
- Disaster recovery procedures
- ClaudeKit agent orchestration

**Read this if**: You're a technical architect, senior developer, or need deep system understanding.

## Quick References

### For Different Roles

**New User**:
1. Start → [README.md](README.md) (5 minutes)
2. Troubleshooting → [README.md - Troubleshooting](README.md#troubleshooting)

**Developer**:
1. Review → [docs/code-standards.md](docs/code-standards.md)
2. Code structure → [docs/codebase-summary.md](docs/codebase-summary.md)
3. Architecture → [docs/system-architecture.md](docs/system-architecture.md)

**Project Manager**:
1. Overview → [docs/project-overview-pdr.md](docs/project-overview-pdr.md)
2. Success criteria → [docs/project-overview-pdr.md#success-criteria](docs/project-overview-pdr.md)

**System Architect**:
1. Architecture → [docs/system-architecture.md](docs/system-architecture.md)
2. Scaling → [docs/system-architecture.md#scaling--extensibility](docs/system-architecture.md)
3. Security → [docs/system-architecture.md#security-architecture](docs/system-architecture.md)

### By Topic

**Installation & Setup**:
- Quick start: [README.md#quick-start](README.md#quick-start)
- Prerequisites: [README.md#prerequisites](README.md#prerequisites)
- First time setup: [README.md#first-time-setup](README.md#first-time-setup)

**Configuration**:
- Adding packages: [README.md#adding-packages](README.md#adding-packages)
- Customizing shell: [README.md#customizing-shell](README.md#customizing-shell)
- Git config: [README.md#managing-git-configuration](README.md#managing-git-configuration)
- AWS setup: [README.md#aws-configuration](README.md#aws-configuration)

**Development**:
- Code standards: [docs/code-standards.md](docs/code-standards.md)
- Git workflow: [README.md#git-workflow](README.md#git-workflow)
- Development workflow: [README.md#development-workflow](README.md#development-workflow)

**Troubleshooting**:
- Common issues: [README.md#troubleshooting](README.md#troubleshooting)
- Shell performance: [README.md#slow-shell-startup](README.md#slow-shell-startup)
- Package installation: [README.md#packages-not-installing](README.md#packages-not-installing)

**Security**:
- Security basics: [README.md#security](README.md#security)
- SSH signing: [docs/codebase-summary.md#private_dot_gitconfig](docs/codebase-summary.md#private_dot_gitconfig)
- Secret management: [docs/code-standards.md#sensitive-information](docs/code-standards.md#sensitive-information)

## Documentation Overview

| Document | Purpose | Length | Audience |
|----------|---------|--------|----------|
| README.md | Quick start & daily reference | 492 lines | Everyone |
| project-overview-pdr.md | Project requirements & goals | 183 lines | Managers, Stakeholders |
| codebase-summary.md | Structure & organization | 329 lines | Developers, Architects |
| code-standards.md | Development guidelines | 383 lines | Developers, Code Reviewers |
| system-architecture.md | Technical design | 486 lines | Architects, Senior Devs |

**Total Documentation**: 1,873 lines

## Key Components Documented

### Package Management
- 22 Homebrew CLI packages (git, zsh, node, python, etc.)
- 23 Homebrew GUI applications (VS Code, Docker, Notion, etc.)
- Declarative installation via brew bundle
- See: [docs/codebase-summary.md#package-definitions](docs/codebase-summary.md#package-definitions)

### Shell Configuration
- Zsh with Powerlevel10k theme
- Antigen plugin manager
- Multiple version managers (nvm, pyenv, asdf, rvm, sdkman)
- See: [docs/codebase-summary.md#shell-configuration-dot_zshrc](docs/codebase-summary.md#shell-configuration-dot_zshrc)

### Git & Security
- SSH commit signing via 1Password
- Encrypted private files
- AWS SSO configuration
- See: [docs/system-architecture.md#security-architecture](docs/system-architecture.md#security-architecture)

### AI Assistant (ClaudeKit)
- 17 specialized agents
- 60+ slash commands
- 35 skills across 8 categories
- 4 orchestration workflows
- See: [docs/codebase-summary.md#claude-directory-ai-assistant-framework](docs/codebase-summary.md#claude-directory-ai-assistant-framework)

## Development Workflow

Integrated with ClaudeKit AI assistant framework:

1. **Plan** → `/plan implement new feature`
2. **Code** → `/code with implementation plan`
3. **Test** → `/test` - Run test suite
4. **Review** → `/fix any issues` - Code quality
5. **Docs** → `/docs:update` - Update documentation

See: [docs/project-overview-pdr.md#development-workflow](docs/project-overview-pdr.md#development-workflow)

## Code Standards

**YANGI** (You Aren't Gonna Need It):
- No over-engineering
- Solve current requirements

**KISS** (Keep It Simple, Stupid):
- Clarity over cleverness
- Simple solutions preferred

**DRY** (Don't Repeat Yourself):
- Extract duplicated logic
- Single source of truth

**Organization**:
- Max 200 lines per file
- kebab-case naming
- Descriptive names for searchability

See: [docs/code-standards.md#core-principles](docs/code-standards.md#core-principles)

## Getting Help

### Common Tasks

**I want to...**
- **Setup on a new Mac** → [README.md#quick-start](README.md#quick-start)
- **Add a new package** → [README.md#adding-packages](README.md#adding-packages)
- **Customize my shell** → [README.md#customizing-shell](README.md#customizing-shell)
- **Fix slow shell startup** → [README.md#slow-shell-startup](README.md#slow-shell-startup)
- **Understand the codebase** → [docs/codebase-summary.md](docs/codebase-summary.md)
- **Learn development standards** → [docs/code-standards.md](docs/code-standards.md)
- **Understand architecture** → [docs/system-architecture.md](docs/system-architecture.md)
- **Write code** → [docs/code-standards.md](docs/code-standards.md)
- **Review code** → [docs/code-standards.md#code-review-checklist](docs/code-standards.md#code-review-checklist)

### Troubleshooting

Common issues documented in [README.md#troubleshooting](README.md#troubleshooting):
- Slow shell startup
- Package installation failures
- Git signing issues
- SSH connection problems

## Documentation Maintenance

### When to Update Docs

- When adding new packages
- When changing shell configuration
- When updating git config
- When adding agents/skills
- When changing development standards
- When fixing bugs in setup procedures

### How to Update Docs

1. Edit relevant documentation file in `./docs/`
2. Update code examples if applicable
3. Run syntax check: `bash -n script.sh`
4. Test changes locally
5. Commit: `git commit -m "docs: update <component>"`

See: [docs/system-architecture.md#maintenance-patterns](docs/system-architecture.md#maintenance-patterns)

## Links & References

### External Resources
- [Chezmoi Documentation](https://www.chezmoi.io)
- [Zsh Documentation](https://zsh.sourceforge.io)
- [Antigen - Zsh Plugin Manager](https://github.com/zsh-users/antigen)
- [Powerlevel10k - Zsh Theme](https://github.com/romkatv/powerlevel10k)
- [Homebrew Package Manager](https://brew.sh)
- [1Password Developer Tools](https://developer.1password.com)

### Project Files
- Repository: `.local/share/chezmoi/`
- Configuration: `.chezmoidata/packages.yaml`
- Shell config: `dot_zshrc`
- Git config: `private_dot_gitconfig`
- AI assistant: `.claude/`

## Documentation Info

**Created**: 2025-12-03
**Last Updated**: 2025-12-03
**Version**: 1.0
**Status**: Production-Ready

**Total Coverage**: 1,873 lines across 5 core documents
**Format**: Markdown with cross-references
**Accessibility**: All files in `./docs/` or root directory

---

**Start with**: [README.md](README.md) for quick start
**Deep dive**: [docs/system-architecture.md](docs/system-architecture.md) for full understanding
