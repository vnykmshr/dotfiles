#!/usr/bin/env bash

# Dotfiles Setup Script
# Professional dotfiles installation with dry-run support and cross-platform compatibility

set -euo pipefail

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
DRY_RUN="${DRY_RUN:-false}"
VERBOSE="${VERBOSE:-false}"
FORCE="${FORCE:-false}"

# Colors are defined in lib/logging.sh

# Source utilities
source "$DOTFILES_DIR/lib/utils.sh"
source "$DOTFILES_DIR/lib/os-detect.sh"
source "$DOTFILES_DIR/lib/logging.sh"

# Usage information
usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Professional dotfiles setup with modern best practices.

OPTIONS:
    -d, --dry-run       Show what would be done without making changes
    -v, --verbose       Enable verbose output
    -f, --force         Force overwrite existing files
    -h, --help          Show this help message

ENVIRONMENT:
    DRY_RUN=true        Same as --dry-run
    VERBOSE=true        Same as --verbose
    FORCE=true          Same as --force

EXAMPLES:
    $0                  # Normal installation
    $0 --dry-run        # Preview changes
    $0 --force          # Overwrite existing files
    DRY_RUN=true $0     # Environment variable dry-run

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d | --dry-run)
                DRY_RUN=true
                shift
                ;;
            -v | --verbose)
                VERBOSE=true
                shift
                ;;
            -f | --force)
                FORCE=true
                shift
                ;;
            -h | --help)
                usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1" >&2
                usage
                exit 1
                ;;
        esac
    done
}

# Main installation steps
main() {
    parse_args "$@"

    log_info "Starting dotfiles setup..."
    log_info "Dotfiles directory: $DOTFILES_DIR"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_warn "DRY RUN MODE - No changes will be made"
    fi

    # Detect OS and architecture
    detect_os
    log_info "Detected OS: $OS_NAME ($OS_ARCH)"

    # Create backup directory if needed
    if [[ "$DRY_RUN" != "true" ]]; then
        mkdir -p "$BACKUP_DIR"
        log_info "Backup directory: $BACKUP_DIR"
    fi

    # Installation steps
    install_dependencies
    setup_symlinks
    install_packages
    configure_shell
    setup_development_tools
    apply_os_defaults

    log_success "Dotfiles setup complete!"

    if [[ "$DRY_RUN" != "true" ]]; then
        log_info "Backup created at: $BACKUP_DIR"
        log_info "Run 'source ~/.zshrc' or restart your shell to apply changes"
    fi
}

# Install system dependencies
install_dependencies() {
    log_step "Installing system dependencies"

    case "$OS_NAME" in
        macos)
            install_homebrew
            ;;
        ubuntu | debian)
            run_cmd "sudo apt update && sudo apt install -y curl git zsh"
            ;;
        fedora | centos | rhel)
            run_cmd "sudo dnf install -y curl git zsh"
            ;;
        arch)
            run_cmd "sudo pacman -S --needed curl git zsh"
            ;;
        *)
            log_warn "Unknown OS: $OS_NAME. Skipping package installation."
            ;;
    esac
}

# Install Homebrew on macOS
install_homebrew() {
    if command_exists brew; then
        log_info "Homebrew already installed"
        return
    fi

    log_info "Installing Homebrew..."
    if [[ "$DRY_RUN" != "true" ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for Apple Silicon Macs
        # Initialize brew environment if installed
        if command -v brew >/dev/null 2>&1; then
            eval "$(brew shellenv)"
        fi
    else
        log_info "Would install Homebrew"
    fi
}

# Setup configuration symlinks
setup_symlinks() {
    log_step "Setting up configuration symlinks"

    # Zsh configuration
    link_config "config/zsh/zshrc" ".zshrc"
    link_config "config/zsh/aliases" ".aliases"

    # Git configuration
    link_config "config/git/gitconfig" ".gitconfig"
    link_config "config/git/gitignore_global" ".gitignore_global"

    # Neovim configuration
    mkdir -p "$HOME/.config"
    link_config "config/nvim" ".config/nvim"

    # Tmux configuration
    link_config "config/tmux/tmux.conf" ".tmux.conf"

    # mise configuration
    link_config "config/mise/config.toml" ".config/mise/config.toml"
}

# Link a config file/directory
link_config() {
    local source="$1"
    local target="$2"
    local source_path="$DOTFILES_DIR/$source"
    local target_path="$HOME/$target"

    # Create target directory if needed
    local target_dir
    target_dir="$(dirname "$target_path")"
    run_cmd "mkdir -p \"$target_dir\""

    # Backup existing file if it exists and is not a symlink
    if [[ -e "$target_path" && ! -L "$target_path" ]]; then
        if [[ "$FORCE" == "true" || "$DRY_RUN" == "true" ]]; then
            local backup_file
            backup_file="$(basename "$target_path")"
            run_cmd "mv \"$target_path\" \"$BACKUP_DIR/$backup_file\""
        else
            log_warn "File exists: $target_path. Use --force to overwrite."
            return
        fi
    fi

    # Remove existing symlink
    if [[ -L "$target_path" ]]; then
        run_cmd "rm \"$target_path\""
    fi

    # Create symlink
    run_cmd "ln -sf \"$source_path\" \"$target_path\""
    log_info "Linked: $target"
}

# Install packages using OS package manager
install_packages() {
    log_step "Installing packages"

    local package_file="$DOTFILES_DIR/install/install-packages"
    if [[ -f "$package_file" ]]; then
        # shellcheck disable=SC1090
        source "$package_file"
    else
        log_warn "Package installation file not found: $package_file"
    fi
}

# Configure shell
configure_shell() {
    log_step "Configuring shell"

    # Change default shell to zsh if not already
    if [[ "$SHELL" != */zsh ]]; then
        local zsh_path
        zsh_path="$(command -v zsh)"

        if [[ -n "$zsh_path" ]]; then
            log_info "Changing default shell to zsh: $zsh_path"
            run_cmd "chsh -s \"$zsh_path\""
        else
            log_error "Zsh not found. Cannot change default shell."
        fi
    else
        log_info "Shell is already zsh"
    fi
}

# Setup development tools
setup_development_tools() {
    log_step "Setting up development tools"

    # Install mise for version management
    if ! command_exists mise; then
        log_info "Installing mise..."
        run_cmd "curl https://mise.run | sh"
    else
        log_info "mise already installed"
    fi

    # Add bin directory to PATH
    local bin_dir="$DOTFILES_DIR/bin"
    if [[ -d "$bin_dir" ]]; then
        log_info "Custom scripts available in: $bin_dir"
    fi
}

# Apply OS-specific defaults
apply_os_defaults() {
    log_step "Applying OS defaults"

    local defaults_script="$DOTFILES_DIR/install/defaults/$OS_NAME"
    if [[ -f "$defaults_script" && -x "$defaults_script" ]]; then
        log_info "Applying $OS_NAME defaults..."
        run_cmd "\"$defaults_script\""
    else
        log_info "No OS defaults found for: $OS_NAME"
    fi
}

# Run main function
main "$@"
