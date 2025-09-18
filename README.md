# Professional Dotfiles

> Clean, fast, intelligent dotfiles designed for customization

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Zsh-green.svg)](https://www.zsh.org/)

## Features

- **Development Automation**: Universal `dev`, `test`, `testwatch` commands for any project
- **Git Workflow**: Smart commit suggestions, branch management, 45+ aliases
- **Environment Detection**: Auto-activate .nvmrc/.python-version, load .env files
- **Performance**: Fast shell startup (0.158s) with lazy loading
- **Modern Tools**: bat, eza, fd, ripgrep, delta, zoxide integration
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

# Development Automation
dev                # Start dev server (any project type)
test               # Run tests (any project type)
testwatch          # Continuous testing with file watching

# Git Workflow
gsave              # Smart commit with suggestions
gnew feature-name  # Create and switch to branch
gswitch main       # Switch branches
gclean             # Remove merged branches

# Performance
shell-bench        # Measure startup time
```

## What's Included

- **Shell Environment**: Optimized zsh with intelligent completion
- **Development Automation**: Universal commands for any project type
- **Environment Detection**: Auto-activation and .env loading
- **Git Integration**: 45+ aliases, smart workflow helpers, enhanced diffs
- **Editor Setup**: Neovim configuration with LSP
- **Terminal**: tmux with sensible defaults
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
