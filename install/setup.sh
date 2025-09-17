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
    process_templates
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

    # SSH configuration (if generated)
    if [[ -f "$DOTFILES_DIR/config/ssh/config" ]]; then
        link_config "config/ssh/config" ".ssh/config"
    fi

    # Neovim configuration
    mkdir -p "$HOME/.config"
    link_config "config/nvim" ".config/nvim"

    # Tmux configuration
    link_config "config/tmux/tmux.conf" ".tmux.conf"

    # mise configuration
    link_config "config/mise/config.toml" ".config/mise/config.toml"
}

# Process template files to generate personalized configs
process_templates() {
    log_step "Processing configuration templates"

    # Process gitconfig template
    process_gitconfig_template

    # Process SSH config template
    process_ssh_template

    # Process zsh exports template
    process_zsh_exports_template

    log_info "Template processing complete"
}

# Process gitconfig template with user input
process_gitconfig_template() {
    local template_file="$DOTFILES_DIR/config/git/gitconfig.template"
    local output_file="$DOTFILES_DIR/config/git/gitconfig"

    if [[ ! -f "$template_file" ]]; then
        log_warn "Git config template not found, skipping"
        return 0
    fi

    log_info "Configuring Git settings..."

    # Default values
    local git_user_name="${GIT_USER_NAME:-}"
    local git_user_email="${GIT_USER_EMAIL:-}"
    local git_signing_key="${GIT_SIGNING_KEY:-~/.ssh/id_ed25519.pub}"
    local editor="${EDITOR:-nvim}"
    local git_gpg_sign="${GIT_GPG_SIGN:-false}"

    # Prompt for user details if not provided via environment
    if [[ -z "$git_user_name" ]] && [[ "$DRY_RUN" != "true" ]]; then
        read -rp "Enter your name for Git commits: " git_user_name
    fi

    if [[ -z "$git_user_email" ]] && [[ "$DRY_RUN" != "true" ]]; then
        read -rp "Enter your email for Git commits: " git_user_email
    fi

    # Use fallback values if still empty
    git_user_name="${git_user_name:-Your Name}"
    git_user_email="${git_user_email:-your.email@example.com}"

    # Process the template
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would generate gitconfig with:"
        log_info "  Name: $git_user_name"
        log_info "  Email: $git_user_email"
        log_info "  Signing key: $git_signing_key"
        log_info "  Editor: $editor"
        log_info "  GPG sign: $git_gpg_sign"
    else
        # Generate the config file
        sed -e "s|{{GIT_USER_NAME}}|$git_user_name|g" \
            -e "s|{{GIT_USER_EMAIL}}|$git_user_email|g" \
            -e "s|{{GIT_SIGNING_KEY}}|$git_signing_key|g" \
            -e "s|{{EDITOR}}|$editor|g" \
            -e "s|{{GIT_GPG_SIGN}}|$git_gpg_sign|g" \
            "$template_file" > "$output_file"

        log_success "Generated personalized gitconfig"
    fi
}

# Process SSH config template
process_ssh_template() {
    local template_file="$DOTFILES_DIR/config/ssh/config.template"
    local output_file="$DOTFILES_DIR/config/ssh/config"

    if [[ ! -f "$template_file" ]]; then
        log_warn "SSH config template not found, skipping"
        return 0
    fi

    log_info "Configuring SSH settings..."

    # Default values
    local ssh_github_key="${SSH_GITHUB_KEY:-~/.ssh/id_ed25519}"
    local ssh_gitlab_key="${SSH_GITLAB_KEY:-~/.ssh/id_ed25519}"
    local ssh_personal_key="${SSH_PERSONAL_KEY:-~/.ssh/id_ed25519}"
    local ssh_work_key="${SSH_WORK_KEY:-~/.ssh/id_rsa}"
    local ssh_local_key="${SSH_LOCAL_KEY:-~/.ssh/id_ed25519}"

    local personal_server_alias="${PERSONAL_SERVER_ALIAS:-my-server}"
    local personal_server_host="${PERSONAL_SERVER_HOST:-example.com}"
    local personal_server_user="${PERSONAL_SERVER_USER:-$USER}"
    local personal_server_port="${PERSONAL_SERVER_PORT:-22}"

    local work_server_alias="${WORK_SERVER_ALIAS:-work-server}"
    local work_server_host="${WORK_SERVER_HOST:-work.example.com}"
    local work_server_user="${WORK_SERVER_USER:-$USER}"
    local work_server_port="${WORK_SERVER_PORT:-22}"

    local local_dev_host="${LOCAL_DEV_HOST:-localhost}"
    local local_dev_user="${LOCAL_DEV_USER:-$USER}"

    # Process the template
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would generate SSH config with standard keys and server templates"
    else
        # Generate the config file
        mkdir -p "$(dirname "$output_file")"
        sed -e "s|{{SSH_GITHUB_KEY}}|$ssh_github_key|g" \
            -e "s|{{SSH_GITLAB_KEY}}|$ssh_gitlab_key|g" \
            -e "s|{{SSH_PERSONAL_KEY}}|$ssh_personal_key|g" \
            -e "s|{{SSH_WORK_KEY}}|$ssh_work_key|g" \
            -e "s|{{SSH_LOCAL_KEY}}|$ssh_local_key|g" \
            -e "s|{{PERSONAL_SERVER_ALIAS}}|$personal_server_alias|g" \
            -e "s|{{PERSONAL_SERVER_HOST}}|$personal_server_host|g" \
            -e "s|{{PERSONAL_SERVER_USER}}|$personal_server_user|g" \
            -e "s|{{PERSONAL_SERVER_PORT}}|$personal_server_port|g" \
            -e "s|{{WORK_SERVER_ALIAS}}|$work_server_alias|g" \
            -e "s|{{WORK_SERVER_HOST}}|$work_server_host|g" \
            -e "s|{{WORK_SERVER_USER}}|$work_server_user|g" \
            -e "s|{{WORK_SERVER_PORT}}|$work_server_port|g" \
            -e "s|{{LOCAL_DEV_HOST}}|$local_dev_host|g" \
            -e "s|{{LOCAL_DEV_USER}}|$local_dev_user|g" \
            "$template_file" > "$output_file"

        log_success "Generated personalized SSH config"
    fi
}

# Process zsh exports template
process_zsh_exports_template() {
    local template_file="$DOTFILES_DIR/config/zsh/exports.local.template"
    local output_file="$DOTFILES_DIR/config/zsh/exports.local"

    if [[ ! -f "$template_file" ]]; then
        log_warn "Zsh exports template not found, skipping"
        return 0
    fi

    log_info "Configuring local environment variables..."

    # Default values
    local workspace_dir="${WORKSPACE_DIR:-$HOME/workspace}"
    local projects_dir="${PROJECTS_DIR:-$HOME/projects}"
    local personal_bin_dir="${PERSONAL_BIN_DIR:-$HOME/.local/bin}"
    local browser="${BROWSER:-open}"
    local terminal="${TERMINAL:-Terminal}"
    local pager="${PAGER:-less}"
    local npm_prefix="${NPM_PREFIX:-$HOME/.npm-global}"
    local python_path="${PYTHON_PATH:-}"
    local go_path="${GO_PATH:-$HOME/go}"
    local cargo_home="${CARGO_HOME:-$HOME/.cargo}"
    local preferred_editor="${PREFERRED_EDITOR:-nvim}"
    local preferred_lang="${PREFERRED_LANG:-en_US.UTF-8}"
    local code_editor="${CODE_EDITOR:-code}"

    # Process the template
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would generate local exports with workspace: $workspace_dir"
    else
        # Generate the config file
        sed -e "s|{{WORKSPACE_DIR}}|$workspace_dir|g" \
            -e "s|{{PROJECTS_DIR}}|$projects_dir|g" \
            -e "s|{{PERSONAL_BIN_DIR}}|$personal_bin_dir|g" \
            -e "s|{{BROWSER}}|$browser|g" \
            -e "s|{{TERMINAL}}|$terminal|g" \
            -e "s|{{PAGER}}|$pager|g" \
            -e "s|{{NPM_PREFIX}}|$npm_prefix|g" \
            -e "s|{{PYTHON_PATH}}|$python_path|g" \
            -e "s|{{GO_PATH}}|$go_path|g" \
            -e "s|{{CARGO_HOME}}|$cargo_home|g" \
            -e "s|{{PREFERRED_EDITOR}}|$preferred_editor|g" \
            -e "s|{{PREFERRED_LANG}}|$preferred_lang|g" \
            -e "s|{{CODE_EDITOR}}|$code_editor|g" \
            "$template_file" > "$output_file"

        log_success "Generated local environment exports"
    fi
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

    # Skip shell change in CI environments
    if [[ -n "${CI:-}" || -n "${GITHUB_ACTIONS:-}" ]]; then
        log_info "CI environment detected, skipping shell change"
        return 0
    fi

    # Change default shell to zsh if not already
    if [[ "$SHELL" != */zsh ]]; then
        local zsh_path
        zsh_path="$(command -v zsh)"

        if [[ -n "$zsh_path" ]]; then
            log_info "Changing default shell to zsh: $zsh_path"
            run_cmd "chsh -s \"$zsh_path\""
        else
            log_error "Zsh not found. Cannot change default shell."
            return 1
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
