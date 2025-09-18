# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.1.0] - 2025-09-18

### Added
- macOS defaults automation script with 41 system preferences
- `make tools` command to show development tools status
- Permission handling for macOS accessibility settings

### Fixed
- macOS defaults permission error blocking installation
- Removed missing test-configs.sh hook from pre-commit
- Arithmetic expression failures in test scripts

### Changed
- Enhanced Makefile with development tools overview
- Improved pre-commit system reliability

## [3.0.0] - 2024-10-15

### Added
- JSON-based template system with placeholder replacement
- Advanced OS detection and environment handling
- Full mise integration for tool management
- Automated testing framework

## [2.2.0] - 2024-10-10

### Added
- Alias conflict detection
- Neovim LSP configuration
- Extended language support via mise

## [2.1.0] - 2024-10-05

### Added
- mise version manager integration
- Enhanced shell configuration
- Improved package management

## [1.0.0] - 2024-09-17

### 🎉 First Production Release

This release represents a complete rewrite and professional cleanup of the dotfiles collection, focusing on minimalism, maintainability, and real-world usage patterns.

### ✨ Major Features Added
- **Smart Alias Reminder System**: Periodically shows helpful aliases to build muscle memory
- **Cross-Platform Installation**: Works seamlessly on macOS, Linux, and WSL2
- **Modern Development Tools**: Integration with mise, homebrew, fzf, zoxide, and modern CLI tools
- **Comprehensive Testing**: Full test suite with CI/CD pipeline
- **Quality Assurance**: Automated linting, formatting, and validation
- **Professional Structure**: Organized directory layout with proper documentation

### 🚀 Core Components
- **Modular Zsh Configuration**: Optimized for performance with lazy loading
- **Git Workflow Enhancement**: 40+ useful aliases and professional git configuration
- **Neovim Setup**: Modern editor configuration with LSP and plugin management
- **Workflow Automation**: Smart project detection and development server automation
- **Utility Scripts**: Comprehensive tooling for dotfiles management

### 🎯 Cleanup & Optimization
- **65% Code Reduction**: Eliminated AI-generated bloat and verbose patterns
- **Deduplication**: Removed duplicate code across all files
- **Minimalism**: Every line serves a clear purpose
- **Performance**: Optimized shell startup time and resource usage
- **Consistency**: Unified coding style and naming conventions

### 📦 Installation & Usage
- **Dry-Run Support**: Preview changes before installation
- **Automatic Backups**: Safe installation with backup creation
- **OS Detection**: Intelligent platform-specific configurations
- **Package Management**: Automated installation of development tools
- **Easy Customization**: Clear structure for personal modifications

### 🔧 Developer Experience
- **Minimal CI Pipeline**: Fast, focused GitHub Actions workflow
- **User-Agnostic**: No personal references, ready for community adoption
- **Documentation**: Clear README with practical examples
- **Licensing**: MIT license for open-source usage
- **Versioning**: Semantic versioning with proper release management

### 📊 Technical Achievements
- **alias-reminder**: 366 → 107 lines (70% reduction)
- **personal-functions**: 370 → 87 lines (76% reduction)
- **lib/utils.sh**: 143 → 32 lines (78% reduction)
- **Makefile**: 354 → 91 lines (74% reduction)
- **CI workflow**: 277 → 35 lines (87% reduction)

### 🎖️ Quality Standards
- Comprehensive test coverage
- Cross-platform compatibility
- Professional code review standards
- Production-ready documentation
- Community adoption ready

---

## Development History

### [0.1.0] - 2024-09-10
- Initial dotfiles collection with basic configurations
- Simple zsh and git setup
- Basic installation scripts

---

[1.0.0]: https://github.com/vnykmshr/dotfiles/releases/tag/v1.0.0
[0.1.0]: https://github.com/vnykmshr/dotfiles/releases/tag/v0.1.0
