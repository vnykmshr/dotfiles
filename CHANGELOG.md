# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.4.0] - 2025-09-23

### Added
- Enhanced alias reminder system with global scope and improved randomization
- Cross-platform utility aliases (conncount, memfree, duckload, findbig)
- Environment variable control for workflow completions

### Fixed
- Alias reminder math expression errors and array scoping issues
- Completion system warnings caused by conflicting workflow definitions
- findbig command execution error with fd/find conflicts
- Shell compatibility issues with associative arrays and parsing

### Changed
- Improved shell script quality and zsh compatibility
- Disabled problematic workflow completions by default (opt-in with DOTFILES_ENABLE_WORKFLOW_COMPLETIONS)
- Enhanced error handling and documentation

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

### Added
- Smart alias reminder system with periodic helpful shortcuts
- Cross-platform installation (macOS, Linux, WSL2)
- Modern CLI tools integration (mise, homebrew, fzf, zoxide)
- Comprehensive testing framework with 20+ validation checks
- Modular zsh configuration with performance optimizations
- Git workflow enhancement with 40+ aliases and smart commits
- Neovim setup with LSP configuration
- Workflow automation with project detection
- Professional directory structure and documentation

### Changed
- Complete rewrite focusing on minimalism and maintainability
- 65% code reduction by eliminating verbose patterns
- Optimized shell startup time with lazy loading
- Unified coding style and naming conventions

### Technical Details
- alias-reminder: 366 → 107 lines (70% reduction)
- personal-functions: 370 → 87 lines (76% reduction)
- lib/utils.sh: 143 → 32 lines (78% reduction)
- Makefile: 354 → 91 lines (74% reduction)
- CI workflow: 277 → 35 lines (87% reduction)

---

## Development History

### [0.1.0] - 2024-09-10
- Initial dotfiles collection with basic configurations
- Simple zsh and git setup
- Basic installation scripts

---

[1.0.0]: https://github.com/vnykmshr/dotfiles/releases/tag/v1.0.0
[0.1.0]: https://github.com/vnykmshr/dotfiles/releases/tag/v0.1.0
