#!/usr/bin/env bash

# Dotfiles Setup Script
# Installation with dry-run support and cross-platform compatibility

set -euo pipefail

# Configuration
# DOTFILES_DIR may be overridden by callers (e.g. tests/test-templates.sh
# sources this file and redirects at a fixture).
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
DRY_RUN="${DRY_RUN:-false}"
VERBOSE="${VERBOSE:-false}"
FORCE="${FORCE:-false}"
MODE=install

# HOME link -> repo source; install, --uninstall and --restore read this
LINKS=(
    ".zshrc:config/zsh/zshrc"
    ".zshenv:config/zsh/zshenv"
    ".gitconfig:config/git/gitconfig"
    ".gitignore_global:config/git/gitignore_global"
    ".ssh/config:config/ssh/config"
    ".config/nvim:config/nvim"
    ".tmux.conf:config/tmux/tmux.conf"
)
# Linked by earlier versions; --uninstall and --restore still recognize them
LEGACY_LINKS=(
    ".aliases:config/zsh/aliases"
    ".config/mise/config.toml:config/mise/config.toml"
)

# Bash 5.2+ with patsub_replacement on (default) treats `&` in the replacement
# of ${var//pat/repl} as the matched text. Older bash (macOS 3.2, Ubuntu 22.04
# 5.1) has no such handling — `&` is literal. The template substitution below
# conditionalizes on this so a value containing `&` survives on either.
if shopt -q patsub_replacement 2>/dev/null; then
    _PATSUB_BACKREF=1
else
    _PATSUB_BACKREF=0
fi

# Colors are defined in lib/logging.sh

# Source utilities
source "$DOTFILES_DIR/lib/utils.sh"
source "$DOTFILES_DIR/lib/os-detect.sh"
source "$DOTFILES_DIR/lib/logging.sh"

# Usage information
usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Dotfiles setup with dry-run support and template-based configuration.

OPTIONS:
    -d, --dry-run       Show what would be done without making changes
    -v, --verbose       Enable verbose output
    -f, --force         Force overwrite existing files
    -p, --packages      Install prerequisites and packages, set zsh as login shell
    -u, --uninstall     Remove the links install created (make uninstall)
    -r, --restore       Put back files an install replaced (make restore)
    -h, --help          Show this help message

ENVIRONMENT:
    DRY_RUN=true        Same as --dry-run
    VERBOSE=true        Same as --verbose
    FORCE=true          Same as --force

EXAMPLES:
    $0                  # Normal installation
    $0 --dry-run        # Preview changes
    $0 --force          # Overwrite existing files
    $0 --packages       # Install packages only (make packages)
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
            -p | --packages)
                MODE=packages
                shift
                ;;
            -u | --uninstall)
                MODE=uninstall
                shift
                ;;
            -r | --restore)
                MODE=restore
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

    if [[ $DRY_RUN == "true" ]]; then
        log_warn "DRY RUN MODE - No changes will be made"
    fi

    # Detect OS and architecture
    detect_os
    log_info "Detected OS: $OS_NAME ($OS_ARCH)"

    if [[ $MODE == "uninstall" ]]; then
        uninstall_links
        return
    fi

    if [[ $MODE == "restore" ]]; then
        if [[ $DRY_RUN == "true" ]]; then
            log_error "--restore has no dry run"
            exit 1
        fi
        restore_backup
        return
    fi

    if [[ $MODE == "packages" ]]; then
        install_dependencies
        install_packages
        configure_shell
        if ((${PACKAGE_FAILURES:-0} > 0)); then
            log_error "$PACKAGE_FAILURES package commands failed; see the warnings above"
            exit 1
        fi
        log_success "Packages installed"
        return 0
    fi

    if ! command_exists jq; then
        log_error "jq is required to read config.json. Run 'make packages' or install jq, then retry."
        exit 1
    fi

    create_dotfiles_symlink
    process_templates
    setup_symlinks

    log_success "Dotfiles setup complete!"

    if [[ -d $BACKUP_DIR ]]; then
        log_info "Replaced files backed up to: $BACKUP_DIR (make restore)"
    fi
    if [[ $DRY_RUN != "true" ]]; then
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
    if [[ $DRY_RUN != "true" ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # A fresh install is not on PATH yet: /opt/homebrew (Apple Silicon), /usr/local (Intel)
        local brew_bin
        for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
            if [[ -x $brew_bin ]]; then
                eval "$("$brew_bin" shellenv)"
                break
            fi
        done
    else
        log_info "Would install Homebrew"
    fi
}

# Create .dotfiles symlink pointing to this project
create_dotfiles_symlink() {
    log_step "Creating .dotfiles symlink"

    local target_link="$HOME/.dotfiles"

    # ~/.dotfiles already resolves to this repo: the clone itself, or a link to it
    if [[ -d $target_link ]] && [[ "$(cd "$target_link" && pwd -P)" == "$(cd "$DOTFILES_DIR" && pwd -P)" ]]; then
        log_info ".dotfiles already points at this repo"
        return 0
    fi

    # Handle existing file/directory/symlink
    if [[ -e $target_link ]]; then
        if [[ $FORCE == "true" || $DRY_RUN == "true" ]]; then
            run_cmd "mkdir -p \"$BACKUP_DIR\""
            run_cmd "mv \"$target_link\" \"$BACKUP_DIR/.dotfiles\""
            log_info "Backed up existing .dotfiles to $BACKUP_DIR/.dotfiles"
        else
            log_warn ".dotfiles already exists at $target_link"
            log_warn "Use --force to overwrite or remove it manually"
            return 1
        fi
    fi

    # Create the symlink
    run_cmd "ln -sf \"$DOTFILES_DIR\" \"$target_link\""
    log_success "Created .dotfiles symlink: $target_link -> $DOTFILES_DIR"
}

# Setup configuration symlinks
setup_symlinks() {
    log_step "Setting up configuration symlinks"

    local entry src
    for entry in "${LINKS[@]}"; do
        src="${entry#*:}"
        # Dry run has not generated template outputs yet: a template stands in
        if [[ ! -e $DOTFILES_DIR/$src ]] &&
            [[ $DRY_RUN != "true" || ! -e $DOTFILES_DIR/$src.template ]]; then
            log_warn "Not linking ~/${entry%%:*}: $src is missing"
            continue
        fi
        link_config "$src" "${entry%%:*}"
    done
}

# Create initial config.json from example if it doesn't exist
init_config() {
    local config_file="$DOTFILES_DIR/config.json"
    local example_file="$DOTFILES_DIR/config.json.example"

    if [[ ! -f $config_file ]]; then
        if [[ -f $example_file ]]; then
            if [[ $DRY_RUN == "true" ]]; then
                log_info "[DRY RUN] Would copy config.json.example to config.json"
                return 0 # In dry-run, continue without creating file
            else
                cp "$example_file" "$config_file"
                log_success "Created config.json from example template"
                echo
                log_info "Next steps:"
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
                log_info "Key settings to update in config.json:"
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

    if [[ -f $config_file ]]; then
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

    if [[ -f $config_file ]] && command -v jq >/dev/null 2>&1; then
        local value
        value=$(jq -r "$key // \"$default\"" "$config_file" 2>/dev/null)
        if [[ $value != "null" && -n $value ]]; then
            # Normalize leading $HOME (deprecated) or ~/ to absolute path.
            if [[ $value == \$HOME* ]]; then
                log_warn "config.json key '$key' uses \$HOME — prefer '~' (auto-normalized)"
                value="${value/#\$HOME/$HOME}"
            elif [[ $value == \~/* ]]; then
                value="${value/#\~/$HOME}"
            fi
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

    # Load configuration (don't fail if no config exists in dry-run)
    if [[ $DRY_RUN == "true" ]]; then
        load_config || true # Don't fail in dry-run mode
    else
        load_config
    fi

    # Process gitconfig template
    process_gitconfig_template

    # Process SSH config template
    process_ssh_template

    # Process zsh exports template
    process_zsh_exports_template

    log_info "Template processing complete"
}

# Substitute {{KEY}} placeholders in a template with caller-supplied values.
# Values are treated as literal strings — no shell evaluation, no sed
# metacharacter interpretation. Safe against &, |, \1, $(...), backticks, etc.
# Substitution is per-placeholder, not single-pass: a value containing
# {{OTHER_KEY}} will be re-substituted on a later iteration.
# Args: template_file output_file description placeholder1 value1 [placeholder2 value2 ...]
process_template_generic() {
    local template_file="$1"
    local output_file="$2"
    local description="$3"
    shift 3

    if [[ ! -f $template_file ]]; then
        log_warn "$description template not found, skipping"
        return 0
    fi

    log_info "Processing $description..."

    if [[ $DRY_RUN == "true" ]]; then
        log_info "[DRY RUN] Would generate $description from template"
        return 0
    fi

    # Escape `\` and `&` in the value only on bashes where they're special in
    # the replacement string (bash 5.2+ with patsub_replacement on — see top of
    # file). On older bash they're literal, so escaping would double them up.
    local content placeholder value escaped
    content=$(<"$template_file")
    while (($# >= 2)); do
        placeholder="$1"
        value="$2"
        if ((_PATSUB_BACKREF)); then
            escaped="${value//\\/\\\\}" # \ -> \\
            escaped="${escaped//&/\\&}" # & -> \&
        else
            escaped="$value"
        fi
        content="${content//\{\{${placeholder}\}\}/$escaped}"
        shift 2
    done

    # Create output directory if needed
    mkdir -p "$(dirname "$output_file")"

    # $(<file) strips the trailing newline; restore it so appending tools start a new line.
    printf '%s\n' "$content" >"$output_file"
    log_success "Generated $description"
}

# Process gitconfig template with user input
process_gitconfig_template() {
    local template_file="$DOTFILES_DIR/config/git/gitconfig.template"
    local output_file="$DOTFILES_DIR/config/git/gitconfig"

    # Load values from JSON config with fallbacks
    local git_user_name
    local git_user_email
    local git_signing_key
    local editor
    local git_gpg_sign

    git_user_name=$(get_config_value '.user.name' 'Your Name')
    git_user_email=$(get_config_value '.user.email' 'your.email@example.com')
    git_signing_key=$(get_config_value '.git.signing_key' "$HOME/.ssh/id_ed25519.pub")
    editor=$(get_config_value '.user.editor' 'nvim')
    git_gpg_sign=$(get_config_value '.git.gpg_sign' 'false')

    # Detect delta command path
    local delta_command="delta"
    if command -v delta >/dev/null 2>&1; then
        delta_command="$(command -v delta)"
    fi

    # Prompt for user details if using defaults and not in dry run
    if [[ $git_user_name == "Your Name" ]] && [[ $DRY_RUN != "true" ]]; then
        read -rp "Enter your name for Git commits: " git_user_name
        git_user_name="${git_user_name:-Your Name}"
    fi

    if [[ $git_user_email == "your.email@example.com" ]] && [[ $DRY_RUN != "true" ]]; then
        read -rp "Enter your email for Git commits: " git_user_email
        git_user_email="${git_user_email:-your.email@example.com}"
    fi

    # Show preview in dry run mode
    if [[ $DRY_RUN == "true" ]]; then
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
        "GIT_GPG_SIGN" "$git_gpg_sign" \
        "DELTA_COMMAND" "$delta_command"
}

# Process SSH config template
process_ssh_template() {
    local template_file="$DOTFILES_DIR/config/ssh/config.template"
    local output_file="$DOTFILES_DIR/config/ssh/config"

    # Load values from JSON config with fallbacks
    local ssh_github_key
    local ssh_gitlab_key
    local ssh_personal_key
    local ssh_work_key
    local ssh_local_key
    local personal_server_alias
    local personal_server_host
    local personal_server_user
    local personal_server_port
    local work_server_alias
    local work_server_host
    local work_server_user
    local work_server_port

    ssh_github_key=$(get_config_value '.ssh.keys.github' "$HOME/.ssh/id_ed25519")
    ssh_gitlab_key=$(get_config_value '.ssh.keys.gitlab' "$HOME/.ssh/id_ed25519")
    ssh_personal_key=$(get_config_value '.ssh.keys.personal' "$HOME/.ssh/id_ed25519")
    ssh_work_key=$(get_config_value '.ssh.keys.work' "$HOME/.ssh/id_rsa")
    ssh_local_key=$(get_config_value '.ssh.keys.local' "$HOME/.ssh/id_ed25519")

    personal_server_alias=$(get_config_value '.ssh.servers.personal.alias' 'my-server')
    personal_server_host=$(get_config_value '.ssh.servers.personal.host' 'example.com')
    personal_server_user=$(get_config_value '.ssh.servers.personal.user' "${USER:-$(id -un)}")
    personal_server_port=$(get_config_value '.ssh.servers.personal.port' '22')

    work_server_alias=$(get_config_value '.ssh.servers.work.alias' 'work-server')
    work_server_host=$(get_config_value '.ssh.servers.work.host' 'work.example.com')
    work_server_user=$(get_config_value '.ssh.servers.work.user' "${USER:-$(id -un)}")
    work_server_port=$(get_config_value '.ssh.servers.work.port' '22')

    local local_dev_host
    local local_dev_user

    local_dev_host=$(get_config_value '.ssh.servers.local_dev.host' 'localhost')
    local_dev_user=$(get_config_value '.ssh.servers.local_dev.user' "${USER:-$(id -un)}")

    # Show preview in dry run mode
    if [[ $DRY_RUN == "true" ]]; then
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
        "LOCAL_DEV_USER" "$local_dev_user" \
        "COLIMA_SSH_CONFIG" "${COLIMA_HOME:-$HOME/.config/colima}/ssh_config"
}

# Process zsh exports template
process_zsh_exports_template() {
    local template_file="$DOTFILES_DIR/config/zsh/exports.local.template"
    local output_file="$DOTFILES_DIR/config/zsh/exports.local"

    local workspace_dir
    local projects_dir
    local personal_bin_dir

    workspace_dir=$(get_config_value '.environment.workspace_dir' "$HOME/workspace")
    projects_dir=$(get_config_value '.environment.projects_dir' "$HOME/projects")
    personal_bin_dir=$(get_config_value '.environment.personal_bin_dir' "$HOME/.local/bin")

    # Show preview in dry run mode
    if [[ $DRY_RUN == "true" ]]; then
        log_info "[DRY RUN] Would generate local exports with workspace: $workspace_dir"
        return 0
    fi

    process_template_generic "$template_file" "$output_file" "local environment exports" \
        "WORKSPACE_DIR" "$workspace_dir" \
        "PROJECTS_DIR" "$projects_dir" \
        "PERSONAL_BIN_DIR" "$personal_bin_dir"
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

    # Back up anything there that is not install's own link, foreign links included
    if [[ -e $target_path || -L $target_path ]] && ! link_owned "$target_path" "$source"; then
        if [[ $FORCE == "true" || $DRY_RUN == "true" ]]; then
            # Same relative path as in HOME, so make restore can copy it back
            run_cmd "mkdir -p \"$(dirname "$BACKUP_DIR/$target")\""
            run_cmd "mv \"$target_path\" \"$BACKUP_DIR/$target\""
        else
            log_warn "File exists: $target_path. Use --force to overwrite."
            return
        fi
    fi

    # Replace install's own link
    if link_owned "$target_path" "$source"; then
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
    if [[ -f $package_file ]]; then
        # shellcheck disable=SC1090
        source "$package_file"
        install_packages_main
    else
        log_warn "Package installation file not found: $package_file"
    fi
}

# Configure shell
configure_shell() {
    log_step "Configuring shell"

    # Skip shell change in CI environments
    if [[ -n ${CI:-} || -n ${GITHUB_ACTIONS:-} ]]; then
        log_info "CI environment detected, skipping shell change"
        return 0
    fi

    # Change default shell to zsh if not already
    if [[ $SHELL != */zsh ]]; then
        local zsh_path
        zsh_path="$(command -v zsh)"

        if [[ -n $zsh_path ]]; then
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

# Physical path of an existing file or dir
physical_path() {
    if [[ -d $1 ]]; then
        (cd "$1" && pwd -P)
    else
        echo "$(cd "$(dirname "$1")" 2>/dev/null && pwd -P)/$(basename "$1")"
    fi
}

# Clone roots install links from, one per line: this repo (logical and
# physical), ~/.dotfiles, and the target of a ~/.dotfiles link
known_roots() {
    printf '%s\n' "$DOTFILES_DIR" "$HOME/.dotfiles"
    physical_path "$DOTFILES_DIR"
    if [[ -L $HOME/.dotfiles ]]; then
        readlink "$HOME/.dotfiles"
    fi
}

# True when symlink $1 is install's link to repo source $2: it resolves to that
# source, or it dangles into $2 under a known clone root (a moved clone)
link_owned() {
    local target
    [[ -L $1 ]] || return 1
    target="$(readlink "$1")"
    [[ $target == /* ]] || target="$(dirname "$1")/$target"
    if [[ -e $1 ]]; then
        [[ "$(physical_path "$target")" == "$(physical_path "$DOTFILES_DIR/$2")" ]]
    else
        [[ $target == */"$2" ]] &&
            [[ $'\n'"$(known_roots)"$'\n' == *$'\n'"${target%/"$2"}"$'\n'* ]]
    fi
}

# Remove install's links; a link that points elsewhere is reported and kept
uninstall_links() {
    log_step "Removing links"

    local entry link src path target failed=0 removed="Removed"
    local roots=$'\n'
    if [[ $DRY_RUN == "true" ]]; then
        removed="Would remove"
    fi
    for entry in "${LINKS[@]}" "${LEGACY_LINKS[@]}"; do
        link="${entry%%:*}"
        src="${entry#*:}"
        path="$HOME/$link"
        [[ -L $path ]] || continue
        if ! link_owned "$path" "$src"; then
            log_warn "Skipping ~/$link: not install's link"
            continue
        fi
        if [[ ! -e $path ]]; then
            target="$(readlink "$path")"
            roots+="${target%/"$src"}"$'\n'
        fi
        if run_cmd "rm -f \"$path\""; then
            log_info "$removed ~/$link"
        else
            log_error "Could not remove ~/$link"
            failed=1
        fi
    done

    # ~/.dotfiles: a link to this repo, or a dangling link that the dangling
    # links above went through or pointed into
    path="$HOME/.dotfiles"
    if [[ -L $path ]]; then
        target="$(readlink "$path")"
        if { [[ -d $path ]] && [[ "$(physical_path "$path")" == "$(physical_path "$DOTFILES_DIR")" ]]; } ||
            { [[ ! -e $path ]] && [[ $roots == *$'\n'"$target"$'\n'* || $roots == *$'\n'"$path"$'\n'* ]]; }; then
            if run_cmd "rm -f \"$path\""; then
                log_info "$removed ~/.dotfiles"
            else
                log_error "Could not remove ~/.dotfiles"
                failed=1
            fi
        else
            log_warn "Skipping ~/.dotfiles: not install's link"
        fi
    fi

    return "$failed"
}

# Copy managed paths back from an install backup, removing install's links first
restore_backup() {
    local all=() backups=() backup choice entry link src path i restored=0
    local managed=" "

    # Names end in YYYYMMDD-HHMMSS: reverse glob order is newest first
    for backup in "$HOME"/.dotfiles-backup-*; do
        if [[ -d $backup ]]; then
            all+=("$backup")
        fi
    done
    for ((i = ${#all[@]} - 1; i >= 0 && ${#backups[@]} < 5; i--)); do
        backups+=("${all[i]}")
    done
    if ((${#backups[@]} == 0)); then
        log_error "No backups found in ~/.dotfiles-backup-*"
        return 1
    fi

    echo "Available backups:"
    for i in "${!backups[@]}"; do
        printf '%6d  %s\n' "$((i + 1))" "${backups[i]}"
    done
    read -r -p "Enter backup number to restore (or path): " choice || true
    if [[ $choice =~ ^[0-9]+$ ]] && ((choice >= 1 && choice <= ${#backups[@]})); then
        backup="${backups[choice - 1]}"
    else
        backup="$choice"
    fi
    if [[ -z $backup || ! -d $backup ]]; then
        log_error "Backup not found: ${backup:-none given}"
        return 1
    fi

    log_info "Restoring from: $backup"
    for entry in "${LINKS[@]}" "${LEGACY_LINKS[@]}" ".dotfiles:."; do
        link="${entry%%:*}"
        src="${entry#*:}"
        path="$HOME/$link"
        managed+="${link%%/*} "
        [[ -e $backup/$link || -L $backup/$link ]] || continue
        # A backed-up .dotfiles was moved aside by install --force, which then
        # linked ~/.dotfiles; a dangling ~/.dotfiles is that link
        if link_owned "$path" "$src" || [[ $link == .dotfiles && -L $path && ! -e $path ]]; then
            rm -f "$path"
        elif [[ -e $path || -L $path ]]; then
            log_warn "Skipping ~/$link: exists and is not install's link"
            continue
        fi
        if [[ $link == .ssh/* && ! -d $HOME/.ssh ]]; then
            mkdir -m 700 "$HOME/.ssh"
        fi
        mkdir -p "$(dirname "$path")"
        cp -Rp "$backup/$link" "$path"
        log_info "Restored ~/$link"
        restored=$((restored + 1))
    done

    for entry in "$backup"/* "$backup"/.[!.]*; do
        [[ -e $entry || -L $entry ]] || continue
        [[ $managed == *" $(basename "$entry") "* ]] ||
            log_warn "Skipped $entry: not a path install manages; restore it by hand"
    done

    if ((restored == 0)); then
        log_error "Nothing restored from $backup"
        return 1
    fi
    log_success "Restore complete"
}

# Run main only when executed directly (skipped when sourced for testing)
if [[ ${BASH_SOURCE[0]} == "$0" ]]; then
    main "$@"
fi
