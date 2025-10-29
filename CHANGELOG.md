# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.7.0] - 2025-10-29

### Added
- Comprehensive critical path test suite (tests/test-critical-path.sh)
  - Behavioral tests covering installation, backup/restore, cross-platform
  - OS detection and platform-specific behavior
  - Template processing (JSON parsing, placeholder replacement)
  - Symlink creation and overwrite operations
  - Backup creation and restore verification
  - Cross-platform file handling (path with spaces)
  - Dry-run mode behavior testing
- Total test coverage: 22 tests (9 basic + 13 critical path)

### Changed
- **Function Organization**: Reorganized shell functions into 10 logical sections for better discoverability
  - File & Directory Operations
  - Git Operations
  - Development & Processes
  - System Information
  - Docker Operations
  - Kubernetes Operations
  - Tmux Session Management
  - Text & Data Processing
  - Visualization & Utilities
  - Dotfiles & Workflow Management
- **Consolidated Functions**: Moved qc, acp, status, workflowutil, mkproject from personal-functions to main functions file
- **personal-functions**: Now a minimal placeholder for user-specific customizations
- All function names preserved (no renames, maintaining short/abbreviated forms)
- Consolidate documentation: merge docs/README.md and docs/customization-guide.md into main README
- Simplify COMMAND_EXAMPLES.md from 387 to 63 lines (quick reference only)
- Remove CONTRIBUTING.md (streamlining for personal dotfiles focus)
- Update README to remove references to deleted workflow tools (dev, test, testwatch)
- Workflow directory simplified: removed dev-server, test-runner, project-init (653 lines)
- Git helpers: remove emoji from commit suggestions, opt-in via DOTFILES_SKIP_WORKFLOW
- Pre-commit: exclude tests/ directory from hardcoded path checks

### Removed
- docs/README.md (merged into main README)
- docs/customization-guide.md (merged into main README)
- CONTRIBUTING.md (not needed for personal dotfiles repo)
- config/workflow/dev-server, test-runner, project-init (unused tools)
- config/workflow/git-helpers.clean (dead code)

## [3.6.0] - 2025-10-29

### Added
- `make restore` command for interactive backup restoration
  - Lists available backups with timestamps
  - Supports numbered selection or direct path input
- `make uninstall` command for clean dotfiles removal
  - Safely removes symlinks
  - Preserves backups for recovery
- Dependabot configuration for automated dependency updates
  - Weekly updates for GitHub Actions
  - Weekly updates for pre-commit hooks
- Gitleaks security scanning in CI workflow
  - Scans all commits for accidentally committed secrets
  - Generates SARIF artifacts for GitHub Security
- CONTRIBUTING.md with development guidelines
  - Clear contribution process
  - Code quality standards
  - Testing requirements
- docs/troubleshooting.md for common issues
  - Installation problems and solutions
  - Shell performance debugging
  - Platform-specific guidance
  - Recovery procedures
- Repository badges to README
  - CI status badge
  - Version badge

### Changed
- Updated VERSION file from 3.3.0 to 3.5.0 (sync with releases)

## [3.5.0] - 2025-10-14

### Added
- User-owned TMPDIR management system to resolve permission errors
  - Auto-creates ~/tmp directory with secure permissions (700)
  - Automatic cleanup of files older than 7 days (configurable)
  - Management commands: tmpdir-status, tmpdir-disable, tmpdir-enable, tmpdir-clean
  - Optional disable with DOTFILES_SKIP_TMPDIR=1
  - Reduces Time Machine backup overhead on macOS
- Gource visualization aliases and package installations (gource, sox, ffmpeg)
- Git status list alias (gsl)

### Fixed
- Touch command path in cleanup_tmpdir for reliable execution during shell initialization
- Use $HOME instead of ~ in home paths for better path resolution
- Shell reload command lookup errors
- Packages target in Makefile
- Remove find=fd alias to prevent tooling conflicts
- Reduce restrictive patterns in global gitignore

### Changed
- Rename gstat to gsl (git status list)
- Major refactoring: removed 291 lines of unused code and duplicates
- Clean up redundant comments and notes
- Remove marketing language from documentation, use factual descriptions
- Code formatting improvements

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
