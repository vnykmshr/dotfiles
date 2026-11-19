# Dotfiles

> Clean, fast dotfiles designed for customization

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Zsh-green.svg)](https://www.zsh.org/)
[![CI](https://github.com/vnykmshr/dotfiles/workflows/CI/badge.svg)](https://github.com/vnykmshr/dotfiles/actions)
[![Version](https://img.shields.io/badge/Version-4.0.0-blue.svg)](./docs/CHANGELOG.md)

## Philosophy

This is my personal setup. You probably shouldn't use it as-is.

Fork it, understand what each piece does, then adapt it to your workflow.
The value is in the patterns and structure, not the specific
configurations.

## Features

- **Fast Shell**: Sub-200ms startup with completion caching
- **CLI Tools**: bat, eza, fd, ripgrep, delta, zoxide (with fallbacks)
- **Git Helpers**: Extensive git aliases and workflow scripts
- **Organized Functions**: Shell functions in logical categories
- **Cross-Platform**: macOS and Linux, with WSL shims
- **Quality**: Pre-commit hooks and automated tests

## Quick Start

```bash
git clone https://github.com/vnykmshr/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
cp config.json.example config.json   # set your name, email and key paths
make install-dry-run                 # preview
make install                         # link configs, generate gitconfig and ssh config
```

`make install` only links files and generates configs; it needs `jq`
(shipped with macOS 15+). Without `config.json`, it creates one from the
example and stops so you can edit it. Everything that touches the system is
a separate, opt-in step:

```bash
make packages        # prerequisites, Homebrew/apt packages, mise runtimes; zsh as login shell
make macos-defaults  # macOS system preferences (see install/defaults/README.md)
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
├── cli-tools/    # CLI tool init and fallbacks
└── workflow/     # Git helper script
```

CLI tool integrations load only when the tool is installed. The private
TMPDIR is opt-in (`DOTFILES_TMPDIR`), and the Linux/WSL shims can be
skipped (`DOTFILES_SKIP_CROSS_PLATFORM`).

### Progressive Enhancement

- Works out-of-the-box with sensible defaults
- Graceful fallbacks when tools aren't available
- Optional features can be disabled without breaking the system
- Performance-conscious: startup is measured (`shell-bench`)

## Key Commands

```bash
# Installation & Management
make install          # Link configs and generate personal ones
make install-dry-run  # Preview changes
make packages         # Install packages, set zsh as login shell
make macos-defaults   # Apply macOS system preferences
make restore          # Put back files an install replaced
make uninstall        # Remove the links (keeps backups)
make test             # Run the test suites

# Git workflow helpers (config/workflow/git-helpers)
mygh               # Repo status; `mygh help` lists pull, new, switch, clean

# Traditional Git Aliases
g                  # git
ga                 # git add
gc                 # git commit
gd                 # git diff
gp                 # git push
gl                 # git log --oneline

# Performance
shell-bench        # Measure startup time
```

## What's Included

### Shell Environment (Zsh)

- Sub-200ms startup with completion caching
- Shared, deduplicated history; a leading space keeps a command out of it
- CLI tools (bat, eza, fd, ripgrep) with fallbacks
- Organized functions in logical categories
- Linux and WSL shims for `pbcopy`, `pbpaste` and `open`
- Optional private TMPDIR (`DOTFILES_TMPDIR`)

**Customize in**:

- `config/zsh/personal-aliases` - Your shortcuts
- `config/zsh/personal.local` - Local overrides (gitignored)

### Git Integration

- Extensive aliases: `g`, `ga`, `gc`, `gd`, `gp`, `gl`, `gnew`, `gswitch`
- Workflow helpers: `mygh`, `gpull`, `gclean` (via git-helpers script)
- Diffs through delta
- Global gitignore covering major platforms
- SSH signing support

### CLI Tools

Integrated with fallbacks to traditional tools:

| Tool | Replaces | Purpose |
| -------- | ------------- | --------- |
| eza | ls | Better file listing with git integration |
| bat | cat | Syntax highlighting, line numbers |
| fd | find | Faster, simpler file search |
| ripgrep | grep | Faster code search |
| delta | diff | Better git diffs with syntax highlighting |
| zoxide | cd | Directory jumping by frecency |

### Other Configurations

- **Neovim**: Editor setup with LSP support
- **tmux**: Sensible defaults, vim-style navigation
- **SSH**: Template-based config for multiple keys/servers

## Customization Guide

**Personal Info**: Edit `config.json` (created from `config.json.example`
during install) with your name, email, and signing key. Path values may use
`~/...` (recommended) or absolute paths; literal `$HOME` is deprecated and
auto-normalized with a warning.

**Personal Aliases**: Add shortcuts to `config/zsh/personal-aliases`.

**Personal Functions and Overrides**: Use `config/zsh/personal.local`
(gitignored, loaded after the other modules). Start from `config/zsh/personal.local.template`.
Don't edit `config/zsh/exports.local`: install regenerates it.

### Optional Features

```bash
# In config/zsh/personal.local
export DOTFILES_TMPDIR="$HOME/tmp"     # Private TMPDIR, created 700 and excluded from Time Machine

# In ~/.exports.local (read before modules load)
export DOTFILES_SKIP_CROSS_PLATFORM=1  # Skip Linux/WSL shims and keybindings
```

### Environment-Specific Setup

```bash
# Add to config/zsh/personal.local
if [[ "$HOST" == "work-laptop" ]]; then
    alias k="kubectl --context=work"
fi
```

## Testing Your Changes

```bash
make test          # Run the test suites
make lint          # Run pre-commit hooks
shell-bench        # Performance impact
```

## Documentation

- [Troubleshooting Guide](docs/troubleshooting.md) - Common issues and solutions
- [CHANGELOG](docs/CHANGELOG.md) - Version history

## Requirements

- **macOS**: Xcode Command Line Tools; jq (ships with macOS 15+)
- **Linux**: git, curl, zsh, jq
- **Optional**: Homebrew and mise, installed by `make packages`

## Platform Support

CI runs the tests on macOS (Apple Silicon) and Ubuntu.
`make packages` also has package lists for Debian, Fedora/RHEL and Arch,
and the shell has WSL shims; those paths are not covered by CI.

## License

MIT © [vnykmshr](https://github.com/vnykmshr)
