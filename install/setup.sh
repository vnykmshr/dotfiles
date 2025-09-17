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
            run_cmd "sudo apt update && sudo apt install -y curl git zsh jq"
            ;;
        fedora | centos | rhel)
            run_cmd "sudo dnf install -y curl git zsh jq"
            ;;
        arch)
            run_cmd "sudo pacman -S --needed curl git zsh jq"
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

# Create initial config.json from example if it doesn't exist
init_config() {
    local config_file="$DOTFILES_DIR/config.json"
    local example_file="$DOTFILES_DIR/config.json.example"

    if [[ ! -f "$config_file" ]]; then
        if [[ -f "$example_file" ]]; then
            if [[ "$DRY_RUN" == "true" ]]; then
                log_info "[DRY RUN] Would copy config.json.example to config.json"
                return 0  # In dry-run, continue without creating file
            else
                cp "$example_file" "$config_file"
                log_success "Created config.json from example template"
                echo
                log_info "📝 Next steps:"
                log_info "   1. Edit config.json with your personal settings (name, email, SSH keys, etc.)"
                if command -v code >/dev/null 2>&1; then
                    log_info "      Example: code config.json"
                elif command -v nvim >/dev/null 2>&1; then
                    log_info "      Example: nvim config.json"
                elif command -v vim >/dev/null 2>&1; then
                    log_info "      Example: vim config.json"
                else
                    log_info "      Example: nano config.json"
                fi
                log_info "   2. Run the setup script again: ./install/setup.sh"
                echo
                log_info "💡 Key settings to update in config.json:"
                log_info "   • user.name and user.email (for Git commits)"
                log_info "   • ssh.keys.* paths (if different from defaults)"
                log_info "   • environment.workspace_dir (your preferred workspace location)"
                echo
                return 1
            fi
        else
            log_error "Neither config.json nor config.json.example found"
            return 1
        fi
    fi
    return 0
}

# Load configuration from JSON file
load_config() {
    local config_file="$DOTFILES_DIR/config.json"

    if [[ -f "$config_file" ]]; then
        log_info "Loading configuration from config.json"
        return 0
    else
        log_warn "No config.json found, will use defaults or prompts"
        return 1
    fi
}

# Get value from JSON config with fallback
get_config_value() {
    local key="$1"
    local default="$2"
    local config_file="$DOTFILES_DIR/config.json"

    if [[ -f "$config_file" ]] && command -v jq >/dev/null 2>&1; then
        local value
        value=$(jq -r "$key // \"$default\"" "$config_file" 2>/dev/null)
        if [[ "$value" != "null" && -n "$value" ]]; then
            echo "$value"
        else
            echo "$default"
        fi
    else
        echo "$default"
    fi
}

# Process template files to generate personalized configs
process_templates() {
    log_step "Processing configuration templates"

    # Initialize config file if needed
    if ! init_config; then
        log_error "Config initialization failed or config.json needs to be edited"
        return 1
    fi

    # Load configuration
    load_config

    # Process gitconfig template
    process_gitconfig_template

    # Process SSH config template
    process_ssh_template

    # Process zsh exports template
    process_zsh_exports_template

    log_info "Template processing complete"
}

# Generic template processor
process_template_generic() {
    local template_file="$1"
    local output_file="$2"
    local description="$3"
    shift 3

    if [[ ! -f "$template_file" ]]; then
        log_warn "$description template not found, skipping"
        return 0
    fi

    log_info "Processing $description..."

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would generate $description from template"
        return 0
    fi

    # Build sed command with all placeholder replacements
    local sed_cmd=""
    while (( $# >= 2 )); do
        local placeholder="$1"
        local value="$2"
        sed_cmd+="-e 's|{{${placeholder}}}|${value}|g' "
        shift 2
    done

    # Create output directory if needed
    mkdir -p "$(dirname "$output_file")"

    # Process template
    eval "sed $sed_cmd '$template_file' > '$output_file'"
    log_success "Generated $description"
}

# Process gitconfig template with user input
process_gitconfig_template() {
    local template_file="$DOTFILES_DIR/config/git/gitconfig.template"
    local output_file="$DOTFILES_DIR/config/git/gitconfig"

    # Load values from JSON config with fallbacks
    local git_user_name=$(get_config_value '.user.name' 'Your Name')
    local git_user_email=$(get_config_value '.user.email' 'your.email@example.com')
    local git_signing_key=$(get_config_value '.git.signing_key' '~/.ssh/id_ed25519.pub')
    local editor=$(get_config_value '.user.editor' 'nvim')
    local git_gpg_sign=$(get_config_value '.git.gpg_sign' 'false')

    # Prompt for user details if using defaults and not in dry run
    if [[ "$git_user_name" == "Your Name" ]] && [[ "$DRY_RUN" != "true" ]]; then
        read -rp "Enter your name for Git commits: " git_user_name
        git_user_name="${git_user_name:-Your Name}"
    fi

    if [[ "$git_user_email" == "your.email@example.com" ]] && [[ "$DRY_RUN" != "true" ]]; then
        read -rp "Enter your email for Git commits: " git_user_email
        git_user_email="${git_user_email:-your.email@example.com}"
    fi

    # Show preview in dry run mode
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would generate gitconfig with:"
        log_info "  Name: $git_user_name"
        log_info "  Email: $git_user_email"
        log_info "  Signing key: $git_signing_key"
        log_info "  Editor: $editor"
        log_info "  GPG sign: $git_gpg_sign"
        return 0
    fi

    # Process template using generic processor
    process_template_generic "$template_file" "$output_file" "personalized gitconfig" \
        "GIT_USER_NAME" "$git_user_name" \
        "GIT_USER_EMAIL" "$git_user_email" \
        "GIT_SIGNING_KEY" "$git_signing_key" \
        "EDITOR" "$editor" \
        "GIT_GPG_SIGN" "$git_gpg_sign"
}

# Process SSH config template
process_ssh_template() {
    local template_file="$DOTFILES_DIR/config/ssh/config.template"
    local output_file="$DOTFILES_DIR/config/ssh/config"

    # Load values from JSON config with fallbacks
    local ssh_github_key=$(get_config_value '.ssh.keys.github' '~/.ssh/id_ed25519')
    local ssh_gitlab_key=$(get_config_value '.ssh.keys.gitlab' '~/.ssh/id_ed25519')
    local ssh_personal_key=$(get_config_value '.ssh.keys.personal' '~/.ssh/id_ed25519')
    local ssh_work_key=$(get_config_value '.ssh.keys.work' '~/.ssh/id_rsa')
    local ssh_local_key=$(get_config_value '.ssh.keys.local' '~/.ssh/id_ed25519')

    local personal_server_alias=$(get_config_value '.ssh.servers.personal.alias' 'my-server')
    local personal_server_host=$(get_config_value '.ssh.servers.personal.host' 'example.com')
    local personal_server_user=$(get_config_value '.ssh.servers.personal.user' "$USER")
    local personal_server_port=$(get_config_value '.ssh.servers.personal.port' '22')

    local work_server_alias=$(get_config_value '.ssh.servers.work.alias' 'work-server')
    local work_server_host=$(get_config_value '.ssh.servers.work.host' 'work.example.com')
    local work_server_user=$(get_config_value '.ssh.servers.work.user' "$USER")
    local work_server_port=$(get_config_value '.ssh.servers.work.port' '22')

    local local_dev_host=$(get_config_value '.ssh.servers.local_dev.host' 'localhost')
    local local_dev_user=$(get_config_value '.ssh.servers.local_dev.user' "$USER")

    # Show preview in dry run mode
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would generate SSH config with standard keys and server templates"
        return 0
    fi

    # Process template using generic processor
    process_template_generic "$template_file" "$output_file" "personalized SSH config" \
        "SSH_GITHUB_KEY" "$ssh_github_key" \
        "SSH_GITLAB_KEY" "$ssh_gitlab_key" \
        "SSH_PERSONAL_KEY" "$ssh_personal_key" \
        "SSH_WORK_KEY" "$ssh_work_key" \
        "SSH_LOCAL_KEY" "$ssh_local_key" \
        "PERSONAL_SERVER_ALIAS" "$personal_server_alias" \
        "PERSONAL_SERVER_HOST" "$personal_server_host" \
        "PERSONAL_SERVER_USER" "$personal_server_user" \
        "PERSONAL_SERVER_PORT" "$personal_server_port" \
        "WORK_SERVER_ALIAS" "$work_server_alias" \
        "WORK_SERVER_HOST" "$work_server_host" \
        "WORK_SERVER_USER" "$work_server_user" \
        "WORK_SERVER_PORT" "$work_server_port" \
        "LOCAL_DEV_HOST" "$local_dev_host" \
        "LOCAL_DEV_USER" "$local_dev_user"
}

# Process zsh exports template
process_zsh_exports_template() {
    local template_file="$DOTFILES_DIR/config/zsh/exports.local.template"
    local output_file="$DOTFILES_DIR/config/zsh/exports.local"

    # Load values from JSON config with fallbacks
    local workspace_dir=$(get_config_value '.environment.workspace_dir' '~/workspace')
    local projects_dir=$(get_config_value '.environment.projects_dir' '~/projects')
    local personal_bin_dir=$(get_config_value '.environment.personal_bin_dir' '~/.local/bin')
    local browser=$(get_config_value '.user.browser' 'open')
    local terminal=$(get_config_value '.user.terminal' 'Terminal')
    local pager=$(get_config_value '.environment.pager' 'less')
    local npm_prefix=$(get_config_value '.development.node.npm_prefix' '~/.npm-global')
    local python_path=$(get_config_value '.development.python.path' '')
    local go_path=$(get_config_value '.development.go.path' '~/go')
    local cargo_home=$(get_config_value '.development.rust.cargo_home' '~/.cargo')
    local preferred_editor=$(get_config_value '.user.editor' 'nvim')
    local preferred_lang="en_US.UTF-8"
    local code_editor="code"

    # Show preview in dry run mode
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would generate local exports with workspace: $workspace_dir"
        return 0
    fi

    # Process template using generic processor
    process_template_generic "$template_file" "$output_file" "local environment exports" \
        "WORKSPACE_DIR" "$workspace_dir" \
        "PROJECTS_DIR" "$projects_dir" \
        "PERSONAL_BIN_DIR" "$personal_bin_dir" \
        "BROWSER" "$browser" \
        "TERMINAL" "$terminal" \
        "PAGER" "$pager" \
        "NPM_PREFIX" "$npm_prefix" \
        "PYTHON_PATH" "$python_path" \
        "GO_PATH" "$go_path" \
        "CARGO_HOME" "$cargo_home" \
        "PREFERRED_EDITOR" "$preferred_editor" \
        "PREFERRED_LANG" "$preferred_lang" \
        "CODE_EDITOR" "$code_editor"
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
