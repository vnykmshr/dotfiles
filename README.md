# Professional Dotfiles

> Clean, minimal dotfiles for productive development workflows

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Zsh-green.svg)](https://www.zsh.org/)

## Features

- **🎯 Modern Tools**: Neovim, modern CLI tools (bat, eza, fd, ripgrep)
- **🔄 Cross-Platform**: macOS, Linux, WSL2
- **📦 Smart Install**: Dry-run, OS detection, automatic backups
- **⚡ Fast**: Optimized for speed and efficiency
- **🧠 Smart Reminders**: Learn aliases through periodic suggestions
- **🔧 Extensible**: Easy to customize and extend

## Quick Start

```bash
# Clone
git clone https://github.com/vnykmshr/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Preview (dry run)
make install-dry-run

# Install
make install
```

## Key Commands

```bash
make help          # Show all commands
make install       # Install everything
make test          # Run tests
make validate      # Check setup
make status        # Show info
```

## Alias Highlights

Based on actual usage patterns:

```bash
# Development (most used)
md                  # make dev
acp                 # git add -u && git commit && git push
gst                 # git status --short --branch

# Navigation
ws                  # cd ~/workspace
proj                # cd ~/workspace/projects

# Workflow
dev                 # smart project dev server
qc                  # quick commit with auto-message
status              # enhanced git + system status
```

## Smart Features

### Alias Reminders
Shows helpful aliases every 10 shell sessions to build muscle memory:

```bash
ar-show             # Show reminders now
ar-level beginner   # Set skill level
ar-off              # Disable reminders
```

### Project Detection
The `dev` command automatically detects project type:
- Node.js → `npm run dev`
- Rust → `cargo run`
- Go → `go run .`
- Make → `make dev`

## Structure

```
├── config/         # All configuration files
│   ├── zsh/        # Zsh setup and functions
│   ├── git/        # Git config with 40+ aliases
│   ├── nvim/       # Neovim with LSP
│   └── tmux/       # Terminal multiplexer
├── install/        # Installation scripts
├── tests/          # Quality assurance
└── bin/            # Utility scripts
```

## Requirements

- **macOS**: Xcode Command Line Tools
- **Linux**: git, curl, zsh
- **Optional**: homebrew, mise, fzf, zoxide

## Testing

Comprehensive test suite ensures reliability:

```bash
make test           # All tests
make test-configs   # Config validation
make test-install   # Installation tests
make lint           # Code quality
```

## Customization

1. **Personal configs**: Edit files in `config/`
2. **Local overrides**: Create `~/.zshrc.local`
3. **Extra aliases**: Add to `config/zsh/personal-aliases`

## Philosophy

- **Minimal**: Every line serves a purpose
- **Fast**: Optimized for quick startup
- **Reliable**: Thoroughly tested
- **Human**: No AI bloat, real-world usage
- **Maintainable**: Clean, readable code

## License

MIT © [vnykmshr](https://github.com/vnykmshr)