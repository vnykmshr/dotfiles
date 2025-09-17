# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2024-09-17

### Changed
- Simplified CI workflow from 277 to 35 lines (87% reduction)
- Focused on essential checks: config validation and cross-platform install testing
- Removed CI bloat and over-engineering

## [1.0.0] - 2024-09-17

### Added
- Complete dotfiles reorganization with modern professional structure
- Intelligent alias reminder system for building muscle memory
- Cross-platform installation system with OS detection
- Comprehensive testing suite with CI/CD pipeline
- Modern development tools integration (mise, homebrew, fzf, zoxide)
- Quality assurance automation (linting, formatting, validation)
- Modular zsh configuration with optimized performance
- Professional git configuration with 40+ useful aliases
- Neovim setup with LSP and modern plugin management
- Workflow automation tools and productivity shortcuts

### Changed
- Migrated from scattered config files to organized directory structure
- Improved shell startup performance with lazy loading
- Enhanced cross-platform compatibility (macOS, Linux, WSL2)
- Updated all hardcoded paths to use dynamic detection

### Fixed
- Shell compatibility issues across different environments
- Installation reliability with proper error handling
- Git configuration syntax and alias functionality
- Test suite reliability and cross-platform compatibility

### Security
- Removed hardcoded paths that could be security risks
- Added validation for all configuration files
- Implemented safe backup system for existing configurations

## [0.1.0] - 2024-09-10

### Added
- Initial dotfiles collection with basic zsh and git configuration
- Simple installation scripts
- Basic aliases and functions

[1.0.0]: https://github.com/vnykmshr/dotfiles/releases/tag/v1.0.0
[0.1.0]: https://github.com/vnykmshr/dotfiles/releases/tag/v0.1.0