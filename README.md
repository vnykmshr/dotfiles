# Dotfiles

> Clean, fast dotfiles designed for customization

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Zsh-green.svg)](https://www.zsh.org/)
[![CI](https://github.com/vnykmshr/dotfiles/workflows/CI/badge.svg)](https://github.com/vnykmshr/dotfiles/actions)
[![Version](https://img.shields.io/badge/Version-3.7.0-blue.svg)](./docs/CHANGELOG.md)

## Philosophy

This is my personal setup. You probably shouldn't use it as-is.

Fork it, understand what each piece does, then adapt it to your workflow.
The value is in the patterns and structure, not the specific
configurations.

## Features

- **Fast Shell**: Sub-200ms startup with lazy loading
- **Modern CLI Tools**: bat, eza, fd, ripgrep, delta, zoxide (with fallbacks)
- **Git Helpers**: Extensive git aliases and workflow scripts
- **Organized Functions**: Shell functions in logical categories
- **Cross-Platform**: macOS, Linux, WSL
- **Quality**: Pre-commit hooks and automated tests

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

Configuration files use JSON templates to separate personal data
(name, email, SSH keys) from versioned configs. This prevents accidental
commits of sensitive information and makes customization explicit.

`config.json`

```json
{
  "user": {
    "name": "Your Name",
    "email": "you@example.com"
  },
  "git": {
    "signing_key": "~/.ssh/id_edxyz.pub"
  }
}
```

### Modular Architecture

```text
config/
├── zsh/          # Shell environment
├── git/          # Version control and aliases
├── nvim/         # Editor configuration
├── tmux/         # Terminal multiplexer
├── ssh/          # SSH client templates
├── cli-tools/    # Modern tool init and fallbacks
└── workflow/     # Git helpers (optional)
```

Each component is optional and independently configurable with
`DOTFILES_SKIP_*` variables.

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

- Sub-200ms startup with lazy loading and completion caching
- History with search and deduplication
- Modern CLI tools (bat, eza, fd, ripgrep) with fallbacks
- Organized functions in logical categories
- Cross-platform support (macOS, Linux, WSL)
- Security automation and TMPDIR management

**Customize in**:

- `config/zsh/personal-aliases` - Your shortcuts
- `config/zsh/personal.local` - Local overrides (gitignored)

### Git Integration

- Extensive aliases: `g`, `ga`, `gc`, `gd`, `gp`, `gl`, `gnew`, `gswitch`
- Workflow helpers: `gsave`, `gpull`, `gclean` (via git-helpers script)
- Enhanced diffs with delta integration
- Global gitignore covering major platforms
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

**Personal Info**: Edit `config.json` (created from `config.json.example`
during install) with your name, email, and signing key. Path values may use
`~/...` (recommended) or absolute paths; literal `$HOME` is deprecated and
auto-normalized with a warning.

**Personal Aliases**: Add shortcuts to `config/zsh/personal-aliases`.

**Personal Functions**: Add utilities to `config/zsh/personal.local`.

**Local Overrides**: Use `config/zsh/personal.local` (gitignored)
for machine-specific config.

### Performance Tuning

Skip features you don't need in `config/zsh/exports.local` (gitignored):

```bash
export DOTFILES_SKIP_WORKFLOW=1        # Disable git workflow helpers
export DOTFILES_SKIP_CROSS_PLATFORM=1  # Skip platform detection
export DOTFILES_SKIP_TMPDIR=1          # Disable TMPDIR management
```

### Environment-Specific Setup

```bash
# Add to config/zsh/exports.local
if [[ "$HOST" == "work-laptop" ]]; then
    alias k="kubectl --context=work"
fi
```

## Testing Your Changes

```bash
make test           # Run validation tests
make lint          # Shell script linting
shell-bench        # Performance impact
```

## Documentation

- [Troubleshooting Guide](docs/troubleshooting.md) - Common issues and solutions
- [CHANGELOG](docs/CHANGELOG.md) - Version history

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
