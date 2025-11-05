# Release v3.5.0 - TMPDIR Management & Stability Improvements

## Overview

This release introduces user-owned TMPDIR management to resolve permission
errors with modern development tools, along with multiple bug fixes and
codebase cleanup.

## Key Features

### User-Owned TMPDIR Management

Comprehensive temporary directory management system that solves permission
issues with Claude Code, Flutter, and other tools that require TMPDIR access:

- **Automatic setup**: Creates `~/tmp` directory with secure permissions (700)
- **Smart cleanup**: Automatically removes files older than 7 days
  (configurable via `DOTFILES_TMP_CLEANUP_DAYS`)
- **Background operation**: Cleanup runs asynchronously to avoid blocking shell
  startup
- **Management commands**:
  - `tmpdir-status` - Show current TMPDIR configuration and statistics
  - `tmpdir-disable` - Temporarily disable custom TMPDIR
  - `tmpdir-enable` - Re-enable custom TMPDIR
  - `tmpdir-clean` - Manually trigger cleanup
- **Optional disable**: Set `DOTFILES_SKIP_TMPDIR=1` to skip initialization
- **macOS optimization**: Excludes directory from Time Machine backups

**Location**: `config/zsh/tmpdir-management` (134 lines)

### Visualization Tools

- Added gource aliases for repository visualization
- Install gource, sox, and ffmpeg packages for video generation

## Bug Fixes

- **TMPDIR cleanup**: Use absolute path for touch command to ensure
  reliability during shell initialization
- **Path resolution**: Replace `~` with `$HOME` in home paths for consistent
  expansion
- **Shell reload**: Fix command lookup errors when reloading shell
  configuration
- **Makefile**: Correct packages target implementation
- **Alias conflicts**: Remove `find=fd` alias that conflicted with system
  tooling
- **Gitignore**: Reduce overly restrictive patterns in global gitignore

## Code Quality

### Refactoring

- Removed 291 lines of unused code and duplicate files
- Eliminated unnecessary logging functions and color variables
- Simplified symlink detection logic (52 lines removed)
- Consolidated duplicate documentation (RELEASE-NOTES.md)

### Documentation

- Removed marketing language, using factual descriptions
- Cleaned up redundant comments and notes
- Improved code clarity and maintainability

## Technical Details

### Architecture

```text
config/zsh/tmpdir-management     # TMPDIR management (134 lines)
install/setup.sh                 # Automatic ~/tmp setup on macOS
```

### Performance Impact

- Cleanup runs in background subprocess
- No impact on shell startup time
- Rate-limited to once per day

### Safety Features

- Multiple safety checks prevent accidental deletion of important
  directories
- Paranoid checks: won't clean `/` or `$HOME`
- Graceful handling when TMPDIR doesn't exist
- Comprehensive error handling

## Compatibility

- **Cross-platform**: macOS and Linux support
- **No breaking changes**: All existing functionality preserved
- **Optional feature**: Can be disabled without affecting other dotfiles
  functionality

## Testing

All 13 tests passing with comprehensive validation:

- TMPDIR initialization and permissions
- Cleanup functionality and safety checks
- Management command functionality
- Background subprocess operation

## Migration Notes

No migration required. The TMPDIR management initializes automatically on shell
startup. Existing workflows continue unchanged.

To disable if needed:

```bash
export DOTFILES_SKIP_TMPDIR=1
```

## What's Changed Since v3.4.0

- 13 commits addressing features, fixes, and maintenance
- 1 new feature (TMPDIR management)
- 6 bug fixes
- 3 code quality improvements
- 2 alias updates
- 1 package addition

**Full Changelog**: <https://github.com/vnykmshr/dotfiles/compare/v3.4.0...v3.5.0>

---

**Previous Release**: [v3.3.0 - Development Automation Complete](https://github.com/vnykmshr/dotfiles/releases/tag/v3.3.0)
