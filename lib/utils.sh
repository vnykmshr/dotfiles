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
