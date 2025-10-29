# Quick Command Reference

Quick reference for testing and exploring dotfiles functionality.

## File Operations

```bash
ls, ll, la, lt          # Enhanced file listing (eza)
cat file.md             # Syntax highlighting (bat)
fd pattern              # Fast file search (fd)
rg "search"             # Fast code search (ripgrep)
```

## Git Workflow

```bash
# Basic git aliases
g, ga, gc, gd, gp, gl   # git, add, commit, diff, push, pull

# Workflow helpers (optional, disable with DOTFILES_SKIP_WORKFLOW=1)
gw                      # Git workflow helper
gws                     # Git status with helpers
```

## Navigation

```bash
z project               # Smart jump to directory (zoxide)
..                      # Up one directory
...                     # Up two directories
```

## Performance

```bash
shell-bench             # Measure shell startup time
make test               # Run validation tests
make lint               # Shell script linting
```

## Alias Management

```bash
ar-show                 # Show 5 random aliases
ar-on                   # Enable alias reminders
ar-off                  # Disable alias reminders
```

## Installation

```bash
make install            # Install dotfiles
make install-dry-run    # Preview changes
make restore            # Restore from backup
make uninstall          # Remove dotfiles
```

For comprehensive examples and testing, run:

```bash
make test               # Run all validation tests
```
