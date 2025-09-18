# Professional Dotfiles

> Clean, fast, intelligent dotfiles designed for customization

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Zsh-green.svg)](https://www.zsh.org/)

## Features

- **Git Workflow**: Smart commit suggestions, branch management, enhanced aliases
- **Performance**: 76% faster shell startup (0.135s) with lazy loading
- **Cross-Platform**: Unified experience across macOS, Linux, WSL, containers
- **Modern Tools**: bat, eza, fd, ripgrep, delta, zoxide integration
- **Security**: Pre-commit hooks, secret scanning, SSH validation
- **Quality**: Comprehensive testing with 20+ validation checks

## Quick Start

```bash
# Clone and preview
git clone https://github.com/vnykmshr/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install-dry-run

# Install
make install
```

## Key Commands

```bash
# Installation & Management
make install        # Install dotfiles
make test          # Run quality tests
make help          # Show all options

# Git Workflow (new)
gsave              # Smart commit with suggestions
gnew feature-name  # Create and switch to branch
gswitch main       # Switch branches
gclean             # Remove merged branches

# Performance
shell-bench        # Measure startup time
```

## What's Included

- **Shell Environment**: Optimized zsh with intelligent completion
- **Git Integration**: 40+ aliases, smart workflow helpers, enhanced diffs
- **Editor Setup**: Neovim configuration with LSP
- **Terminal**: tmux with sensible defaults
- **Development Tools**: mise, modern CLI alternatives
- **Quality Assurance**: Comprehensive testing and validation

## Documentation

- **[📚 Project Overview](docs/README.md)** - Philosophy and design principles
- **[🔧 Customization Guide](docs/customization-guide.md)** - Adaptation examples

## Requirements

- **macOS**: Xcode Command Line Tools
- **Linux**: git, curl, zsh
- **Optional**: homebrew, mise for tool management

## Philosophy

**Build your development identity, don't copy mine.**

This project provides professional patterns and examples. The real value comes from understanding and adapting them to your workflow. Great developers don't just copy configurations—they evolve them.

## License

MIT © [vnykmshr](https://github.com/vnykmshr)
