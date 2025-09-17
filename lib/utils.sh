#!/usr/bin/env bash

# Utility functions for dotfiles setup

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Run command with dry-run support
run_cmd() {
    local cmd="$1"

    if [[ "$VERBOSE" == "true" ]]; then
        log_debug "Command: $cmd"
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        echo "[DRY RUN] $cmd"
        return 0
    else
        eval "$cmd"
    fi
}

# Check if running on macOS
is_macos() {
    [[ "$OSTYPE" == "darwin"* ]]
}

# Check if running on Linux
is_linux() {
    [[ "$OSTYPE" == "linux-gnu"* ]]
}

# Get the user's shell
get_user_shell() {
    if [[ -n "$SHELL" ]]; then
        basename "$SHELL"
    else
        echo "unknown"
    fi
}

# Create a backup of a file
backup_file() {
    local file="$1"
    local backup_name="${file}.backup.$(date +%Y%m%d-%H%M%S)"

    if [[ -f "$file" ]]; then
        run_cmd "cp \"$file\" \"$backup_name\""
        log_info "Backed up: $file -> $backup_name"
    fi
}

# Check if a file is a symlink pointing to dotfiles
is_dotfiles_symlink() {
    local file="$1"
    local dotfiles_dir="$2"

    if [[ -L "$file" ]]; then
        local target
        target="$(readlink "$file")"
        [[ "$target" == "$dotfiles_dir"* ]]
    else
        return 1
    fi
}

# Get the absolute path of a file
get_absolute_path() {
    local file="$1"

    if [[ -d "$file" ]]; then
        (cd "$file" && pwd)
    else
        local dir
        dir="$(dirname "$file")"
        local base
        base="$(basename "$file")"
        echo "$(cd "$dir" && pwd)/$base"
    fi
}

# Check if script is being run as root
is_root() {
    [[ $EUID -eq 0 ]]
}

# Prompt user for yes/no confirmation
confirm() {
    local prompt="${1:-Are you sure?}"
    local default="${2:-n}"

    if [[ "$FORCE" == "true" ]]; then
        return 0
    fi

    local response
    read -p "$prompt [y/N]: " -r response
    response="${response:-$default}"

    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Wait for user input
pause() {
    local message="${1:-Press any key to continue...}"
    read -n 1 -s -r -p "$message"
    echo
}

# Check if a port is in use
port_in_use() {
    local port="$1"
    netstat -an | grep ":$port " > /dev/null 2>&1
}

# Get the current Git branch
get_git_branch() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null
    fi
}

# Check if directory is a Git repository
is_git_repo() {
    local dir="${1:-.}"
    (cd "$dir" && git rev-parse --git-dir > /dev/null 2>&1)
}

# Generate a random string
random_string() {
    local length="${1:-32}"
    LC_ALL=C tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "$length"
}