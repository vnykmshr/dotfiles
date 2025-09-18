#!/usr/bin/env bash

# Setup pre-commit hooks for dotfiles quality assurance
# This script installs and configures pre-commit hooks

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { printf "${BLUE}ℹ %s${NC}\n" "$*" >&2; }
log_success() { printf "${GREEN}✓ %s${NC}\n" "$*" >&2; }
log_warn() { printf "${YELLOW}⚠ %s${NC}\n" "$*" >&2; }
log_error() { printf "${RED}✗ %s${NC}\n" "$*" >&2; }

# Check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log_error "Not a git repository. Pre-commit hooks require git."
        exit 1
    fi
}

# Install pre-commit
install_pre_commit() {
    log_info "Checking for pre-commit installation..."

    if command -v pre-commit >/dev/null 2>&1; then
        log_success "pre-commit is already installed"
        return 0
    fi

    log_info "Installing pre-commit..."

    # Try different installation methods
    if command -v pip3 >/dev/null 2>&1; then
        pip3 install --user pre-commit
    elif command -v brew >/dev/null 2>&1; then
        brew install pre-commit
    elif command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y python3-pip
        pip3 install --user pre-commit
    else
        log_error "Unable to install pre-commit. Please install it manually:"
        log_info "  pip install pre-commit"
        log_info "  brew install pre-commit"
        exit 1
    fi

    # Verify installation
    if command -v pre-commit >/dev/null 2>&1; then
        log_success "pre-commit installed successfully"
    else
        log_error "pre-commit installation failed"
        exit 1
    fi
}

# Install additional tools required by hooks
install_hook_dependencies() {
    log_info "Installing hook dependencies..."

    local missing_tools=()

    # Check for shellcheck
    if ! command -v shellcheck >/dev/null 2>&1; then
        missing_tools+=("shellcheck")
    fi

    # Check for shfmt
    if ! command -v shfmt >/dev/null 2>&1; then
        missing_tools+=("shfmt")
    fi

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_info "Installing missing tools: ${missing_tools[*]}"

        if command -v brew >/dev/null 2>&1; then
            brew install "${missing_tools[@]}"
        elif command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update
            for tool in "${missing_tools[@]}"; do
                case "$tool" in
                    shellcheck)
                        sudo apt-get install -y shellcheck
                        ;;
                    shfmt)
                        # Install shfmt manually for Ubuntu
                        wget -O shfmt https://github.com/mvdan/sh/releases/latest/download/shfmt_v3.7.0_linux_amd64
                        chmod +x shfmt
                        mkdir -p "$HOME/.local/bin"
                        mv shfmt "$HOME/.local/bin/"
                        ;;
                esac
            done
        else
            log_warn "Please install these tools manually: ${missing_tools[*]}"
        fi
    else
        log_success "All hook dependencies are available"
    fi
}

# Setup pre-commit hooks
setup_hooks() {
    log_info "Setting up pre-commit hooks..."

    # Install the git hooks
    if pre-commit install; then
        log_success "Pre-commit hooks installed"
    else
        log_error "Failed to install pre-commit hooks"
        exit 1
    fi

    # Install commit-msg hook for commit message validation
    if pre-commit install --hook-type commit-msg; then
        log_success "Commit message hooks installed"
    else
        log_warn "Failed to install commit message hooks (this is optional)"
    fi

    # Install pre-push hooks
    if pre-commit install --hook-type pre-push; then
        log_success "Pre-push hooks installed"
    else
        log_warn "Failed to install pre-push hooks (this is optional)"
    fi
}

# Test pre-commit hooks
test_hooks() {
    log_info "Testing pre-commit hooks..."

    # Run pre-commit on all files to test
    if pre-commit run --all-files; then
        log_success "All pre-commit hooks passed"
    else
        log_warn "Some pre-commit hooks failed. This is normal for the first run."
        log_info "The hooks will auto-fix many issues. Commit the changes and try again."
    fi
}

# Create git hooks backup
backup_existing_hooks() {
    local git_hooks_dir=".git/hooks"

    if [[ -d $git_hooks_dir ]]; then
        local backup_dir="${git_hooks_dir}.backup.$(date +%Y%m%d-%H%M%S)"

        log_info "Backing up existing git hooks to $backup_dir"
        cp -r "$git_hooks_dir" "$backup_dir"
        log_success "Git hooks backed up"
    fi
}

# Show hook information
show_hook_info() {
    echo ""
    log_info "Pre-commit hooks setup complete!"
    echo ""
    log_info "What happens now:"
    echo "  • Quality checks run automatically before each commit"
    echo "  • Code formatting is applied automatically"
    echo "  • Security checks prevent sensitive data commits"
    echo "  • Configuration validation ensures working dotfiles"
    echo ""
    log_info "Useful commands:"
    echo "  pre-commit run --all-files     # Run all hooks on all files"
    echo "  pre-commit run <hook-name>     # Run specific hook"
    echo "  pre-commit autoupdate          # Update hook versions"
    echo "  git commit --no-verify         # Skip hooks (emergency only)"
    echo ""
    log_info "To disable a specific hook temporarily:"
    echo "  SKIP=<hook-name> git commit"
    echo ""
}

# Main function
main() {
    local skip_test=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-test)
                skip_test=true
                shift
                ;;
            --help | -h)
                echo "Usage: $0 [--skip-test] [--help|-h]"
                echo "  --skip-test  Skip running hooks test at the end"
                echo "  --help, -h   Show this help message"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    log_info "Setting up pre-commit hooks for dotfiles"
    log_info "========================================"

    # Check prerequisites
    check_git_repo

    # Backup existing hooks
    backup_existing_hooks

    # Install pre-commit
    install_pre_commit

    # Install dependencies
    install_hook_dependencies

    # Setup hooks
    setup_hooks

    # Test hooks unless skipped
    if [[ $skip_test == "false" ]]; then
        test_hooks
    fi

    # Show information
    show_hook_info
}

main "$@"
