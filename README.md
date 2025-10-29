# Dotfiles

> Clean, fast dotfiles designed for customization

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Zsh-green.svg)](https://www.zsh.org/)
[![CI](https://github.com/vnykmshr/dotfiles/workflows/CI/badge.svg)](https://github.com/vnykmshr/dotfiles/actions)
[![Version](https://img.shields.io/badge/Version-3.7.0-blue.svg)](./CHANGELOG.md)

## Philosophy

**Build your development identity, don't copy mine.**

This project provides a solid foundation and practical examples. The real value comes from understanding the patterns and adapting them to your unique workflow. Great developers don't just copy configurations—they understand, modify, and evolve them.

## Features

- **Fast Shell**: 0.158s startup with lazy loading and optimized completions
- **Modern CLI Tools**: bat, eza, fd, ripgrep, delta, zoxide with fallbacks
- **Git Workflow**: Smart commit helpers, branch management, 45+ aliases
- **Alias Reminders**: Learn shortcuts through spaced repetition (5 random every 5 commands)
- **Environment Detection**: Auto-activate .nvmrc/.python-version, load .env files
- **Cross-Platform**: macOS, Linux, WSL with graceful fallbacks
- **Quality**: 20+ pre-commit hooks, security scanning, automated tests

## Quick Start

```bash
# Clone and preview
git clone https://github.com/vnykmshr/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install-dry-run

# Install
make install
```

## Design Principles

### Template-Based Configuration

Configuration files use JSON templates to separate personal data (name, email, SSH keys) from versioned configs. This prevents accidental commits of sensitive information and makes customization explicit.

```json
// config.json
{
  "user": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "git": {
    "signing_key": "$HOME/.ssh/id_ed25519.pub"
  }
}
```

### Modular Architecture

```text
config/
├── zsh/          # Shell environment (19 modules, 2946 lines)
├── git/          # Version control templates and aliases
├── nvim/         # Editor configuration
├── tmux/         # Terminal multiplexer
├── ssh/          # SSH client templates
├── cli-tools/    # Modern tool integration
└── workflow/     # Git helpers (optional)
```

Each component is optional and independently configurable with `DOTFILES_SKIP_*` variables.

### Progressive Enhancement

- Works out-of-the-box with sensible defaults
- Graceful fallbacks when tools aren't available
- Optional features can be disabled without breaking the system
- Performance-conscious with lazy loading

## Key Commands

```bash
# Installation & Management
make install        # Install dotfiles
make install-dry-run  # Preview changes
make restore        # Restore from backup
make uninstall      # Remove dotfiles (preserves backups)
make test          # Run validation tests

# Git Workflow (optional, set DOTFILES_SKIP_WORKFLOW=1 to disable)
gw                 # Git workflow helpers
gws                # Git status with helpers

# Traditional Git Aliases
g                  # git
ga                 # git add
gc                 # git commit
gd                 # git diff
gp                 # git push
gl                 # git pull

# Performance
shell-bench        # Measure startup time
```

## What's Included

### Shell Environment (Zsh)

**Performance**:

- Fast startup (0.158s) with lazy loading of fzf and mise
- Optimized completion system with caching
- Conditional module loading (skip what you don't need)

**Features**:

- Intelligent history with search and deduplication
- Cross-platform compatibility (macOS, Linux, WSL)
- Modern CLI tool integration with traditional fallbacks
- Security automation (confirmations for dangerous commands)
- TMPDIR management (resolves permission errors)

**Customization**:

- `config/zsh/personal-aliases` - Your shortcuts
- `config/zsh/personal-functions` - Your utilities
- `config/zsh/personal.local` - Local overrides (gitignored)

### Git Integration

**Smart Workflow** (optional via `gw` command):

- Commit message suggestions based on conventional commits
- Interactive numbered selection or custom messages
- Quick save workflow helpers

**45+ Aliases**:

- Short forms: `g`, `ga`, `gc`, `gd`, `gp`, `gl`
- Branch management: `gnew`, `gswitch`, `gclean`
- Enhanced viewing: delta for diffs, better log formats
- Shortcuts for common operations

**Configuration**:

- Comprehensive gitconfig with smart defaults
- Global gitignore (185 lines covering all major platforms/tools)
- Delta integration for better diffs
- SSH signing support

### Modern CLI Tools

Integrated with fallbacks to traditional tools:

| Modern | Traditional | Purpose |
|--------|-------------|---------|
| eza | ls | Better file listing with git integration |
| bat | cat | Syntax highlighting, line numbers |
| fd | find | Faster, simpler file search |
| ripgrep | grep | Faster code search |
| delta | diff | Better git diffs with syntax highlighting |
| zoxide | cd | Smart directory jumping with frecency |

### Other Configurations

- **Neovim**: Modern editor setup with LSP support
- **tmux**: Sensible defaults, vim-style navigation
- **SSH**: Template-based config for multiple keys/servers

## Customization Guide

### Quick Customization

**1. Personal Info** (`config.json`)

Created during installation from `config.json.example`:

```json
{
  "user": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "git": {
    "signing_key": "$HOME/.ssh/id_ed25519.pub"
  },
  "environment": {
    "workspace_dir": "$HOME/workspace"
  }
}
```

**2. Personal Aliases** (`config/zsh/personal-aliases`)

```bash
# Navigation shortcuts
alias work="cd ~/work"
alias personal="cd ~/personal"

# Project-specific
alias build="npm run build"
alias lint="npm run lint"

# Docker workflow
alias dc="docker-compose"
alias dcup="docker-compose up -d"
```

**3. Personal Functions** (`config/zsh/personal-functions`)

```bash
# Quick project setup
mkproject() {
    mkdir -p ~/projects/$1
    cd ~/projects/$1
    git init
}

# Docker helpers
dcbash() {
    docker-compose exec ${1:-app} bash
}
```

### Performance Tuning

Skip features you don't need:

```bash
# Add to config/zsh/exports.local (gitignored)
export DOTFILES_SKIP_WORKFLOW=1        # Disable git workflow helpers
export DOTFILES_SKIP_CROSS_PLATFORM=1  # Skip platform detection
export DOTFILES_SKIP_TMPDIR=1          # Disable TMPDIR management
export DOTFILES_SKIP_ALIAS_REMINDER=1  # No alias reminders
```

Measure impact:

```bash
shell-bench 5           # Benchmark startup time
make test              # Validate changes
```

### Environment-Specific Setup

```bash
# Add to config/zsh/exports.local
if [[ "$HOST" == "work-laptop" ]]; then
    alias k="kubectl --context=work"
    export WORK_MODE=1
fi

if [[ "$HOST" == "personal-mbp" ]]; then
    alias blog="cd ~/projects/blog"
fi
```

### Common Patterns

**Frontend Developer**:

```bash
# Personal aliases
alias serve="npm run dev"
alias preview="npm run preview"

# Personal functions
npm_fresh() {
    rm -rf node_modules package-lock.json
    npm install
}
```

**Backend Developer**:

```bash
# Database shortcuts
alias db_reset="docker-compose down && docker-compose up -d postgres"

# API testing
api_test() {
    curl -s "http://localhost:3000/$1" | jq
}
```

**DevOps Engineer**:

```bash
# Kubernetes shortcuts
alias pods="kubectl get pods"
alias logs="kubectl logs -f"

# Terraform
tf_plan() {
    terraform plan -var-file="envs/$1.tfvars"
}
```

## Testing Your Changes

```bash
make test           # Run validation tests
make lint          # Shell script linting
shell-bench        # Performance impact
```

## Documentation

- [Troubleshooting Guide](docs/troubleshooting.md) - Common issues and solutions
- [CHANGELOG](CHANGELOG.md) - Version history

## Requirements

- **macOS**: Xcode Command Line Tools
- **Linux**: git, curl, zsh
- **Optional**: homebrew (macOS), mise (language runtime manager)

## Platform Support

Tested and supported on:

- macOS (Intel and Apple Silicon)
- Ubuntu / Debian
- Fedora / RHEL / CentOS
- Arch Linux
- WSL (Windows Subsystem for Linux)

## License

MIT © [vnykmshr](https://github.com/vnykmshr)
