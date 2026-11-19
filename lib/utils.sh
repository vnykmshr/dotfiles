#!/usr/bin/env bash
# Essential utility functions

# Check if command exists
command_exists() { command -v "$1" >/dev/null 2>&1; }

# Run command with dry-run support
run_cmd() {
    [[ $VERBOSE == "true" ]] && echo "Command: $1" >&2
    if [[ $DRY_RUN == "true" ]]; then
        echo "[DRY RUN] $1"
    else
        bash -o pipefail -c "$1"
    fi
}

# OS detection functions available in lib/os-detect.sh

# Backup file with timestamp
backup_file() {
    local file="$1"
    [[ -e $file ]] && cp "$file" "$file.backup.$(date +%Y%m%d_%H%M%S)"
}

# Confirmation prompt
confirm() {
    local prompt="${1:-Continue?}"
    read -r -p "$prompt (y/N) " response
    [[ $response =~ ^[Yy]$ ]]
}

# True when symlink $1 points into repo dir $2 (a physical path). Walks up to
# an existing parent so a dangling link to a removed repo file still counts.
owned_link() {
    local path rest=""
    [[ -L $1 ]] || return 1
    path="$(readlink "$1")"
    [[ $path == /* ]] || path="$(dirname "$1")/$path"
    while [[ ! -d $path ]]; do
        rest="/$(basename "$path")$rest"
        path="$(dirname "$path")"
    done
    path="$(cd "$path" && pwd -P)$rest"
    [[ $path == "$2" || $path == "$2"/* ]]
}
