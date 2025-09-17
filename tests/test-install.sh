#!/usr/bin/env bash

# Comprehensive Dotfiles Installation Testing
# Tests installation, configuration, and functionality

set -euo pipefail

# Configuration
TEST_USER="test-dotfiles"
TEST_HOME="/tmp/dotfiles-test-$$"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

log_info() { printf "${BLUE}ℹ %s${NC}\n" "$*" >&2; }
log_success() { printf "${GREEN}✓ %s${NC}\n" "$*" >&2; }
log_warn() { printf "${YELLOW}⚠ %s${NC}\n" "$*" >&2; }
log_error() { printf "${RED}✗ %s${NC}\n" "$*" >&2; }

# Test assertion functions
assert_success() {
    local command="$1"
    local description="${2:-$command}"

    ((TESTS_RUN++))

    if eval "$command" >/dev/null 2>&1; then
        log_success "$description"
        ((TESTS_PASSED++))
        return 0
    else
        log_error "$description"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local description="${2:-File exists: $file}"

    assert_success "test -f '$file'" "$description"
}

assert_dir_exists() {
    local dir="$1"
    local description="${2:-Directory exists: $dir}"

    assert_success "test -d '$dir'" "$description"
}

assert_executable() {
    local file="$1"
    local description="${2:-File is executable: $file}"

    assert_success "test -x '$file'" "$description"
}

assert_symlink() {
    local file="$1"
    local target="$2"
    local description="${3:-Symlink correct: $file -> $target}"

    ((TESTS_RUN++))

    if [[ -L "$file" && "$(readlink "$file")" == "$target" ]]; then
        log_success "$description"
        ((TESTS_PASSED++))
        return 0
    else
        log_error "$description"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_command_available() {
    local command="$1"
    local description="${2:-Command available: $command}"

    assert_success "command -v '$command'" "$description"
}

assert_alias_exists() {
    local alias_name="$1"
    local description="${2:-Alias exists: $alias_name}"

    ((TESTS_RUN++))

    if HOME="$TEST_HOME" zsh -c "source '$TEST_HOME/.zshrc' && alias '$alias_name'" >/dev/null 2>&1; then
        log_success "$description"
        ((TESTS_PASSED++))
        return 0
    else
        log_error "$description"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Setup test environment
setup_test_environment() {
    log_info "Setting up test environment..."

    # Create test directory
    mkdir -p "$TEST_HOME"
    export HOME="$TEST_HOME"

    # Copy dotfiles to test location
    cp -r "$DOTFILES_DIR" "$TEST_HOME/.dotfiles"

    log_success "Test environment created: $TEST_HOME"
}

# Cleanup test environment
cleanup_test_environment() {
    log_info "Cleaning up test environment..."

    if [[ -d "$TEST_HOME" ]]; then
        rm -rf "$TEST_HOME"
        log_success "Test environment cleaned up"
    fi
}

# Test dotfiles structure
test_structure() {
    log_info "Testing dotfiles structure..."

    assert_dir_exists "$TEST_HOME/.dotfiles" "Dotfiles directory exists"
    assert_dir_exists "$TEST_HOME/.dotfiles/install" "Install directory exists"
    assert_dir_exists "$TEST_HOME/.dotfiles/config" "Config directory exists"
    assert_dir_exists "$TEST_HOME/.dotfiles/bin" "Bin directory exists"
    assert_dir_exists "$TEST_HOME/.dotfiles/lib" "Lib directory exists"

    # Essential files
    assert_file_exists "$TEST_HOME/.dotfiles/install/setup.sh" "Setup script exists"
    assert_executable "$TEST_HOME/.dotfiles/install/setup.sh" "Setup script is executable"

    assert_file_exists "$TEST_HOME/.dotfiles/Makefile" "Makefile exists"
    assert_file_exists "$TEST_HOME/.dotfiles/README.md" "README exists"

    # Configuration files
    assert_file_exists "$TEST_HOME/.dotfiles/config/zsh/zshrc" "Zsh config exists"
    assert_file_exists "$TEST_HOME/.dotfiles/config/git/gitconfig" "Git config exists"
    assert_file_exists "$TEST_HOME/.dotfiles/config/nvim/init.lua" "Neovim config exists"
}

# Test dry-run installation
test_dry_run_install() {
    log_info "Testing dry-run installation..."

    # Test dry-run mode
    if HOME="$TEST_HOME" DRY_RUN=true "$TEST_HOME/.dotfiles/install/setup.sh" >/dev/null 2>&1; then
        log_success "Dry-run installation completed without errors"
        ((TESTS_PASSED++))
    else
        log_error "Dry-run installation failed"
        ((TESTS_FAILED++))
    fi

    ((TESTS_RUN++))

    # Ensure no files were actually created in dry-run
    if [[ ! -f "$TEST_HOME/.zshrc" ]]; then
        log_success "Dry-run didn't create actual files"
        ((TESTS_PASSED++))
    else
        log_error "Dry-run created files when it shouldn't have"
        ((TESTS_FAILED++))
    fi

    ((TESTS_RUN++))
}

# Test actual installation
test_installation() {
    log_info "Testing actual installation..."

    # Run installation
    if HOME="$TEST_HOME" FORCE=true "$TEST_HOME/.dotfiles/install/setup.sh" >/dev/null 2>&1; then
        log_success "Installation completed without errors"
        ((TESTS_PASSED++))
    else
        log_error "Installation failed"
        ((TESTS_FAILED++))
        return 1
    fi

    ((TESTS_RUN++))

    # Check symlinks were created
    assert_symlink "$TEST_HOME/.zshrc" "$TEST_HOME/.dotfiles/config/zsh/zshrc"
    assert_symlink "$TEST_HOME/.gitconfig" "$TEST_HOME/.dotfiles/config/git/gitconfig"

    # Check directories were created
    assert_dir_exists "$TEST_HOME/.config" ".config directory created"

    if [[ -L "$TEST_HOME/.config/nvim" ]]; then
        assert_symlink "$TEST_HOME/.config/nvim" "$TEST_HOME/.dotfiles/config/nvim"
    fi
}

# Test configuration loading
test_configuration_loading() {
    log_info "Testing configuration loading..."

    # Test zsh configuration loads without errors
    if HOME="$TEST_HOME" zsh -c "source '$TEST_HOME/.zshrc'; echo 'Config loaded'" >/dev/null 2>&1; then
        log_success "Zsh configuration loads without errors"
        ((TESTS_PASSED++))
    else
        log_error "Zsh configuration failed to load"
        ((TESTS_FAILED++))
    fi

    ((TESTS_RUN++))

    # Test that personal aliases are loaded
    assert_alias_exists "md" "Personal alias 'md' loaded"
    assert_alias_exists "acp" "Personal alias 'acp' loaded"
    assert_alias_exists "gst" "Git alias 'gst' loaded"
}

# Test utility scripts
test_utility_scripts() {
    log_info "Testing utility scripts..."

    # Test workflow helper
    assert_executable "$TEST_HOME/.dotfiles/bin/workflow-helper" "Workflow helper is executable"
    assert_executable "$TEST_HOME/.dotfiles/bin/dotfiles" "Dotfiles manager is executable"

    # Test scripts run without errors
    if HOME="$TEST_HOME" "$TEST_HOME/.dotfiles/bin/workflow-helper" --help >/dev/null 2>&1; then
        log_success "Workflow helper shows help without errors"
        ((TESTS_PASSED++))
    else
        log_error "Workflow helper failed to show help"
        ((TESTS_FAILED++))
    fi

    ((TESTS_RUN++))

    if HOME="$TEST_HOME" "$TEST_HOME/.dotfiles/bin/dotfiles" --help >/dev/null 2>&1; then
        log_success "Dotfiles manager shows help without errors"
        ((TESTS_PASSED++))
    else
        log_error "Dotfiles manager failed to show help"
        ((TESTS_FAILED++))
    fi

    ((TESTS_RUN++))
}

# Test git configuration
test_git_configuration() {
    log_info "Testing git configuration..."

    # Test git config is valid
    if HOME="$TEST_HOME" git config --list >/dev/null 2>&1; then
        log_success "Git configuration is valid"
        ((TESTS_PASSED++))
    else
        log_error "Git configuration is invalid"
        ((TESTS_FAILED++))
    fi

    ((TESTS_RUN++))

    # Test aliases are defined
    local git_aliases=("st" "ll" "lg" "aa" "cm")
    for alias_name in "${git_aliases[@]}"; do
        if HOME="$TEST_HOME" git config "alias.$alias_name" >/dev/null 2>&1; then
            log_success "Git alias '$alias_name' is defined"
            ((TESTS_PASSED++))
        else
            log_error "Git alias '$alias_name' is not defined"
            ((TESTS_FAILED++))
        fi
        ((TESTS_RUN++))
    done
}

# Test Makefile targets
test_makefile_targets() {
    log_info "Testing Makefile targets..."

    local targets=("help" "install" "validate" "test" "status")

    for target in "${targets[@]}"; do
        if HOME="$TEST_HOME" make -C "$TEST_HOME/.dotfiles" "$target" >/dev/null 2>&1; then
            log_success "Makefile target '$target' works"
            ((TESTS_PASSED++))
        else
            log_error "Makefile target '$target' failed"
            ((TESTS_FAILED++))
        fi
        ((TESTS_RUN++))
    done
}

# Test validation script
test_validation() {
    log_info "Testing validation script..."

    if HOME="$TEST_HOME" make -C "$TEST_HOME/.dotfiles" validate >/dev/null 2>&1; then
        log_success "Validation script passes"
        ((TESTS_PASSED++))
    else
        log_error "Validation script failed"
        ((TESTS_FAILED++))
    fi

    ((TESTS_RUN++))
}

# Test backup functionality
test_backup_functionality() {
    log_info "Testing backup functionality..."

    # Create a fake existing file
    echo "existing content" >"$TEST_HOME/.zshrc"

    # Run installation which should backup the file
    if HOME="$TEST_HOME" FORCE=true "$TEST_HOME/.dotfiles/install/setup.sh" >/dev/null 2>&1; then
        # Check if backup was created
        if find "$TEST_HOME" -name "*.backup.*" -type f | grep -q .; then
            log_success "Backup functionality works"
            ((TESTS_PASSED++))
        else
            log_error "Backup was not created"
            ((TESTS_FAILED++))
        fi
    else
        log_error "Installation with backup failed"
        ((TESTS_FAILED++))
    fi

    ((TESTS_RUN++))
}

# Print test summary
print_summary() {
    echo ""
    log_info "Test Summary"
    log_info "============"
    log_info "Total tests: $TESTS_RUN"
    log_success "Passed: $TESTS_PASSED"

    if [[ $TESTS_FAILED -gt 0 ]]; then
        log_error "Failed: $TESTS_FAILED"
        echo ""
        log_error "Some tests failed. Please review the output above."
        return 1
    else
        echo ""
        log_success "All tests passed! 🎉"
        return 0
    fi
}

# Main test function
main() {
    local skip_cleanup=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --keep-test-env)
                skip_cleanup=true
                shift
                ;;
            --help | -h)
                echo "Usage: $0 [--keep-test-env] [--help|-h]"
                echo "  --keep-test-env  Don't cleanup test environment after running"
                echo "  --help, -h       Show this help message"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    log_info "Dotfiles Installation Testing"
    log_info "============================="

    # Setup test environment
    setup_test_environment

    # Ensure cleanup happens on exit (unless --keep-test-env is specified)
    if [[ "$skip_cleanup" == "false" ]]; then
        trap cleanup_test_environment EXIT
    fi

    # Run tests
    test_structure
    test_dry_run_install
    test_installation
    test_configuration_loading
    test_utility_scripts
    test_git_configuration
    test_makefile_targets
    test_validation
    test_backup_functionality

    # Print results
    if print_summary; then
        exit 0
    else
        exit 1
    fi
}

main "$@"
