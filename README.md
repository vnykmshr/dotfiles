# Professional Dotfiles

> Clean, fast, intelligent dotfiles for modern development

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Zsh-green.svg)](https://www.zsh.org/)

## Features

- **Modern CLI Tools**: bat, eza, fd, ripgrep, delta, zoxide
- **Smart Environment**: Auto-detects project versions (Node.js, Python, Go, Rust)
- **Security Automation**: .env protection, secret scanning, SSH validation
- **Cross-Platform**: macOS, Linux, WSL, containers, cloud IDEs
- **Workflow Automation**: Smart dev servers, test runners, project init
- **Intelligent History**: Enhanced search and filtering
- **Clean Install**: Dry-run, backups, validation

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

## Key Commands

```bash
# Automation
dev                 # Smart project dev server
test                # Auto-detect and run tests
envrc               # Create .envrc for project type
status              # Enhanced git + system status

# Security
seccheck            # SSH security validation
envcheck            # Secure .env files

# Frequently used
md                  # make dev
gacp                # git add -u && git commit && git push
gst                 # git status --short --branch
```

## Core Features

### Environment Detection

Auto-activates project tools and versions:

- **Node.js**: Reads `.nvmrc`, switches versions
- **Python**: Uses `.python-version` with mise/pyenv
- **Go/Rust**: Configures paths and environments
- **npm scripts**: Creates dynamic aliases

### Security Automation

- **.env Protection**: Auto-secures environment files
- **Git Hooks**: Pre-commit secret scanning
- **SSH Validation**: Key permission checks

### Cross-Platform Support

Unified experience across macOS, Linux, WSL, containers:

- Consistent clipboard commands (`pbcopy`/`pbpaste`)
- Normalized keybindings and environment detection

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

Clean, minimal, practical dotfiles for real development work.

## License

MIT © [vnykmshr](https://github.com/vnykmshr)
