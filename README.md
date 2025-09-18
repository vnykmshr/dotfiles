# Professional Dotfiles (v2.2)

> Secure, intelligent dotfiles with cross-platform compatibility and automation

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Zsh-green.svg)](https://www.zsh.org/)

## Features

- **🎯 Modern Tools**: Neovim, modern CLI tools (bat, eza, fd, ripgrep, delta, zoxide)
- **🚀 Smart Environment**: Auto-detects and activates project versions (Node.js, Python, Go, Rust)
- **📋 Intelligent History**: Enhanced search, filtering, and security for shell history
- **🛡️ Security Automation**: Automatic .env protection, secret scanning, SSH validation
- **🌍 Cross-Platform**: Seamless experience across macOS, Linux, WSL, containers, cloud IDEs
- **🔄 Auto-Environment**: Seamless direnv integration with smart .envrc templates
- **⚡ Workflow Automation**: Smart test runners, dev servers, and project initialization
- **📦 Smart Install**: Dry-run, OS detection, automatic backups
- **🧠 Smart Reminders**: Learn aliases through periodic suggestions
- **🔧 Extensible**: Clean, modular configuration that's easy to customize

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

## Smart Commands

Intelligent automation with security and cross-platform support:

```bash
# Environment Detection (automatic)
envdetect           # Manual environment detection
envinfo             # Show detailed environment info (v2.2+)
platform            # Quick platform identification

# Security Automation (v2.2+)
seccheck            # SSH security validation
envcheck            # Secure .env files automatically
gitsec              # Install git security hooks

# Smart History
hstats              # History statistics and analysis
hsuggest <query>    # Find similar commands
hclean              # Remove duplicate history entries
hpriv               # Clean sensitive commands from history

# Direnv Integration
envrc               # Smart .envrc creation (auto-detects project type)
mkenvrc <type>      # Create .envrc for specific type (node/python/go/rust)
denv                # Show direnv status

# Workflow Automation
dev                 # Smart project dev server
test                # Auto-detect and run tests
qc                  # Quick commit with auto-message
status              # Enhanced git + system status
```

### Development Aliases (most used)
```bash
md                  # make dev
gacp                # git add -u && git commit && git push
gst                 # git status --short --branch
```

## Smart Features (Phase 2.2)

### 🛡️ Security Automation (v2.2+)
Professional security practices with zero configuration:
- **Environment File Protection**: Auto-detects .env files, sets 600 permissions, adds to .gitignore
- **Git Security Hooks**: Automatic pre-commit secret scanning for passwords, tokens, API keys
- **SSH Security**: Validates key permissions and provides security recommendations
- **Cross-Platform Security**: Works seamlessly across macOS, Linux, WSL, and containers

```bash
cd my-project/          # Automatically secures any .env files found
git commit              # Pre-commit hook scans for secrets
seccheck                # Manual SSH security validation
```

### 🌍 Cross-Platform Compatibility (v2.2+)
Seamless experience across all development environments:
- **Smart Detection**: Auto-identifies macOS, Linux, WSL, Docker, Codespaces, Gitpod
- **Unified Commands**: Consistent clipboard (`pbcopy`/`pbpaste`) and open across platforms
- **Keybinding Harmony**: Word movement works the same on macOS (Alt) and Linux (Ctrl)
- **Environment Optimization**: Automatic performance tuning for containers and cloud IDEs

```bash
envinfo                 # Shows: Environment: macos (native)
pbcopy < file.txt       # Works on all platforms
platform                # Quick platform check
```

## Environment Intelligence (Phase 2.1)

### 🎯 Automatic Environment Detection
Changes directory → Automatically activates the right tools:
- **Node.js**: Detects `.nvmrc` and switches versions with mise/nvm
- **Python**: Reads `.python-version` and activates with mise/pyenv
- **Go**: Sets up `GOPATH` and adds project `bin/` to PATH
- **Rust**: Configures cargo and adds `target/release/` to PATH
- **npm scripts**: Creates dynamic aliases (`npm:dev`, `npm:build`, etc.)

```bash
cd my-node-project/     # Automatically switches to Node 18.17.0
npm:dev                 # Runs npm run dev (auto-created alias)
```

### 📋 Intelligent History Management
Enhanced shell history with security and analytics:
- **Smart filtering**: Excludes sensitive commands (passwords, tokens, keys)
- **Advanced search**: `hsearch "docker run"` with context
- **Statistics**: `hstats` shows usage patterns and top commands
- **Suggestions**: `hsuggest git` finds similar commands
- **Cleanup**: `hclean` removes duplicates, `hpriv` removes sensitive entries

### 🔄 Smart Direnv Integration
Seamless environment switching with template generation:
- **Auto-detection**: `envrc` creates appropriate .envrc for your project
- **Templates**: Pre-built configurations for Node.js, Python, Go, Rust, Docker
- **Security**: Automatically adds .envrc to .gitignore

```bash
cd new-project/
envrc                   # Detects package.json → creates Node.js .envrc
```

### 🧠 Alias Reminders
Shows helpful aliases every 10 shell sessions to build muscle memory:

```bash
ar-show             # Show reminders now
ar-level beginner   # Set skill level
ar-off              # Disable reminders
```

### ⚡ Workflow Automation
Smart project commands that adapt to your environment:
- `dev` → Detects and runs appropriate dev server
- `test` → Finds and runs project tests
- `quickstart` → Interactive project creation

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