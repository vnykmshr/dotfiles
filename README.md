# Professional Dotfiles Collection

> A modern, well-organized dotfiles collection inspired by best practices and designed for professional development workflows.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Zsh-green.svg)](https://www.zsh.org/)
[![Editor](https://img.shields.io/badge/Editor-Neovim-blue.svg)](https://neovim.io/)

## ✨ Features

- **🎯 Modern Tools**: Neovim with LSP, Treesitter, modern CLI tools (bat, eza, fd, ripgrep)
- **🔄 Cross-Platform**: Works on macOS, Linux, and WSL2
- **📦 Smart Installation**: Dry-run support, OS detection, automatic backups
- **⚡ Performance**: Optimized configurations for speed and efficiency
- **🔧 Extensible**: Modular structure that's easy to customize
- **🚀 Professional**: Production-ready with comprehensive documentation

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/vnykmshr/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Preview what will be installed (dry run)
make install-dry-run

# Install everything
make install

# Or use the setup script directly
./install/setup.sh
```

## 📁 Structure

```
~/.dotfiles/
├── install/                 # Installation & setup scripts
│   ├── setup.sh            # Main bootstrap script
│   ├── install-packages    # Package installation
│   └── defaults/           # OS-specific defaults
├── config/                 # Application configurations
│   ├── zsh/               # Zsh configuration
│   ├── git/               # Git configuration
│   ├── nvim/              # Neovim setup with LSP
│   ├── tmux/              # Tmux configuration
│   └── mise/              # Version manager config
├── bin/                   # Custom scripts & utilities
├── lib/                   # Shared functions & utilities
├── docs/                  # Documentation
├── tests/                 # Installation tests
└── Makefile              # Task automation
```

## 🛠 Installation Options

### Full Installation
```bash
make install              # Complete setup
make install-force        # Overwrite existing files
```

### Package Management
```bash
make packages             # Install all packages
make packages-core        # Install only essential packages
make packages-dev         # Install development tools
```

### Development Setup
```bash
make dev                  # Full development environment
make quick-setup          # Minimal setup for new machines
```

## 📋 What's Included

### Shell & Terminal
- **Zsh** with modern configuration and plugins
- **Oh My Zsh** compatibility with custom enhancements
- **Modern aliases** for enhanced productivity
- **Tmux** with vim-style keybindings

### Development Tools
- **Neovim** with LSP, Treesitter, and modern plugins
- **Git** with helpful aliases and better defaults
- **mise** for runtime version management
- **Modern CLI tools**: bat, eza, fd, ripgrep, fzf, zoxide

### Applications & Languages
- Language runtimes via mise: Node.js, Python, Go, Rust
- Development tools: Docker, kubectl, AWS CLI
- macOS apps: iTerm2, VS Code, Rectangle, Raycast

## 🔧 Configuration

### Environment Variables
```bash
export DRY_RUN=true       # Preview changes only
export VERBOSE=true       # Enable detailed output
export FORCE=true         # Overwrite existing files
export EDITOR=nvim        # Set preferred editor
```

### Customization
```bash
# Edit main zsh config
make edit

# Edit specific configs
$EDITOR ~/.dotfiles/config/zsh/aliases
$EDITOR ~/.dotfiles/config/git/gitconfig
$EDITOR ~/.dotfiles/config/nvim/init.lua
```

## 🧪 Testing & Validation

```bash
make test                 # Run installation tests
make validate            # Validate dotfiles structure
make lint                # Lint shell scripts
make doctor              # System diagnostics
```

## 🔄 Management Commands

### Updates & Sync
```bash
make update              # Pull latest changes
make sync                # Update + reinstall
```

### Backup & Restore
```bash
make backup              # Create configuration backup
make uninstall           # Remove dotfiles (creates backup)
```

### Status & Information
```bash
make status              # Show git and system status
make doctor              # Run system diagnostics
```

### Cleanup
```bash
make clean               # Remove temporary files
make reset               # Clean reinstall
```

## 🎯 Self-Management

The dotfiles include a self-management script:

```bash
# Available in PATH after installation
dotfiles install         # Reinstall dotfiles
dotfiles sync            # Update and reinstall
dotfiles backup          # Create backup
dotfiles status          # Show status
dotfiles edit            # Open in editor
dotfiles test            # Run tests
```

## 🔐 Security & Privacy

- **No sensitive data**: All personal information is templated
- **Secure defaults**: Git signing, SSH key management
- **Local overrides**: Support for machine-specific configs
- **Backup protection**: Automatic backups before changes

## 🌍 Cross-Platform Support

### macOS
- Homebrew package management
- macOS-specific defaults and apps
- Native integration with system features

### Linux
- Support for major distributions (Ubuntu, Fedora, Arch)
- Package manager auto-detection
- X11 clipboard integration

### Windows (WSL2)
- WSL2 compatibility
- Windows-specific adaptations
- Cross-platform clipboard support

## 📖 Documentation

- [`docs/FEATURES.md`](docs/FEATURES.md) - Detailed feature documentation
- [`docs/CUSTOMIZATION.md`](docs/CUSTOMIZATION.md) - Customization guide
- [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) - Common issues and solutions

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Run tests: `make test`
5. Commit changes: `git commit -m 'Add amazing feature'`
6. Push to branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

## 💡 Inspiration

This dotfiles collection draws inspiration from:

- [Thorsten Ball's dotfiles](https://github.com/mrnugget/dotfiles) - Clean, minimal approach
- [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles) - macOS optimization
- [thoughtbot dotfiles](https://github.com/thoughtbot/dotfiles) - Professional practices

## 📄 License

[MIT License](LICENSE) - Use freely, adapt as needed.

---

⭐ **Star this repository if it helped you!**

🐛 **Found a bug?** [Open an issue](https://github.com/vnykmshr/dotfiles/issues)

💬 **Have questions?** [Start a discussion](https://github.com/vnykmshr/dotfiles/discussions)