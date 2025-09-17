#!/usr/bin/env bash
# Essential utility functions

# Check if command exists
command_exists() { command -v "$1" >/dev/null 2>&1; }

# Run command with dry-run support
run_cmd() {
    [[ "$VERBOSE" == "true" ]] && echo "Command: $1" >&2
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] $1"
    else
        eval "$1"
    fi
}

# OS detection
is_macos() { [[ "$OSTYPE" == "darwin"* ]]; }
is_linux() { [[ "$OSTYPE" == "linux-gnu"* ]]; }

# Backup file with timestamp
backup_file() {
    local file="$1"
    [[ -e "$file" ]] && cp "$file" "$file.backup.$(date +%Y%m%d_%H%M%S)"
}

# Confirmation prompt
confirm() {
    local prompt="${1:-Continue?}"
    read -r -p "$prompt (y/N) " response
    [[ "$response" =~ ^[Yy]$ ]]
}