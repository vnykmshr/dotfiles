#!/usr/bin/env bash

# Configuration Validation Tests
# Tests configuration files for syntax and functionality

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

log_info() { printf "${BLUE}ℹ %s${NC}\n" "$*" >&2; }
log_success() { printf "${GREEN}✓ %s${NC}\n" "$*" >&2; }
log_warn() { printf "${YELLOW}⚠ %s${NC}\n" "$*" >&2; }
log_error() { printf "${RED}✗ %s${NC}\n" "$*" >&2; }

# Test assertion function
assert_test() {
    local test_command="$1"
    local description="$2"

    ((TESTS_RUN++))

    if eval "$test_command" >/dev/null 2>&1; then
        log_success "$description"
        ((TESTS_PASSED++))
        return 0
    else
        log_error "$description"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Test zsh configuration syntax
test_zsh_configs() {
    log_info "Testing Zsh configuration syntax..."

    local zsh_files=(
        "$PROJECT_ROOT/config/zsh/zshrc"
        "$PROJECT_ROOT/config/zsh/aliases"
        "$PROJECT_ROOT/config/zsh/functions"
        "$PROJECT_ROOT/config/zsh/exports"
        "$PROJECT_ROOT/config/zsh/personal-aliases"
        "$PROJECT_ROOT/config/zsh/personal-functions"
        "$PROJECT_ROOT/config/zsh/completions"
    )

    for file in "${zsh_files[@]}"; do
        if [[ -f "$file" ]]; then
            local filename
            filename="$(basename "$file")"
            assert_test "zsh -n '$file'" "Zsh syntax valid: $filename"
        fi
    done
}

# Test shell script syntax
test_shell_scripts() {
    log_info "Testing shell script syntax..."

    # Find all shell scripts
    find "$PROJECT_ROOT" -name "*.sh" -type f | while read -r script; do
        local filename
        filename="$(basename "$script")"

        # Skip if not a shell script
        if head -1 "$script" | grep -q '^#!/.*sh'; then
            assert_test "bash -n '$script'" "Shell syntax valid: $filename"
        fi
    done
}

# Test git configuration
test_git_config() {
    log_info "Testing Git configuration..."

    local git_config="$PROJECT_ROOT/config/git/gitconfig"

    if [[ -f "$git_config" ]]; then
        # Test git config syntax
        assert_test "git config --file='$git_config' --list >/dev/null" "Git config syntax valid"

        # Test for required sections
        assert_test "grep -q '\\[user\\]' '$git_config'" "Git config has [user] section"
        assert_test "grep -q '\\[core\\]' '$git_config'" "Git config has [core] section"
        assert_test "grep -q '\\[alias\\]' '$git_config'" "Git config has [alias] section"

        # Test for important aliases
        local important_aliases=("st" "ll" "lg" "aa" "cm")
        for alias_name in "${important_aliases[@]}"; do
            assert_test "grep -q '$alias_name = ' '$git_config'" "Git alias '$alias_name' defined"
        done
    fi
}

# Test Neovim configuration
test_neovim_config() {
    log_info "Testing Neovim configuration..."

    local nvim_config="$PROJECT_ROOT/config/nvim/init.lua"

    if [[ -f "$nvim_config" ]]; then
        # Test Lua syntax
        if command -v lua >/dev/null 2>&1; then
            assert_test "lua -e 'dofile(\"$nvim_config\")'" "Neovim Lua syntax valid"
        else
            log_warn "Lua not available, skipping Neovim syntax check"
        fi

        # Test for essential configurations
        assert_test "grep -q 'number.*=.*true' '$nvim_config'" "Neovim has line numbers config"
        assert_test "grep -q 'mapleader' '$nvim_config'" "Neovim has leader key config"
        assert_test "grep -q 'require.*lazy' '$nvim_config'" "Neovim uses lazy.nvim plugin manager"
    fi
}

# Test tmux configuration
test_tmux_config() {
    log_info "Testing tmux configuration..."

    local tmux_config="$PROJECT_ROOT/config/tmux/tmux.conf"

    if [[ -f "$tmux_config" ]]; then
        # Test tmux config syntax
        if command -v tmux >/dev/null 2>&1; then
            assert_test "tmux -f '$tmux_config' -C 'show-options'" "tmux config syntax valid"
        else
            log_warn "tmux not available, skipping syntax check"
        fi

        # Test for essential configurations
        assert_test "grep -q 'set.*prefix' '$tmux_config'" "tmux has prefix key config"
        assert_test "grep -q 'set.*mouse' '$tmux_config'" "tmux has mouse support config"
        assert_test "grep -q 'bind.*split-window' '$tmux_config'" "tmux has split window bindings"
    fi
}

# Test Makefile
test_makefile() {
    log_info "Testing Makefile..."

    local makefile="$PROJECT_ROOT/Makefile"

    if [[ -f "$makefile" ]]; then
        # Test Makefile syntax
        assert_test "make -f '$makefile' -n help >/dev/null" "Makefile syntax valid"

        # Test for essential targets
        local essential_targets=("help" "install" "test" "validate" "clean")
        for target in "${essential_targets[@]}"; do
            assert_test "grep -q '^$target:' '$makefile'" "Makefile has '$target' target"
        done

        # Test that help target lists other targets
        assert_test "make -f '$makefile' help 2>/dev/null | grep -q install" "Makefile help shows install target"
    fi
}

# Test utility scripts
test_utility_scripts() {
    log_info "Testing utility scripts..."

    local scripts=(
        "$PROJECT_ROOT/bin/dotfiles"
        "$PROJECT_ROOT/bin/workflow-helper"
        "$PROJECT_ROOT/install/setup.sh"
        "$PROJECT_ROOT/install/install-packages"
    )

    for script in "${scripts[@]}"; do
        if [[ -f "$script" ]]; then
            local filename
            filename="$(basename "$script")"

            # Test executable
            assert_test "test -x '$script'" "$filename is executable"

            # Test shows help
            if [[ "$filename" != "install-packages" ]]; then # install-packages doesn't have --help
                assert_test "'$script' --help >/dev/null || '$script' -h >/dev/null" "$filename shows help"
            fi

            # Test has shebang
            assert_test "head -1 '$script' | grep -q '^#!'" "$filename has shebang"
        fi
    done
}

# Test configuration file structure
test_config_structure() {
    log_info "Testing configuration file structure..."

    # Check for required configuration files
    local required_configs=(
        "config/zsh/zshrc"
        "config/zsh/aliases"
        "config/git/gitconfig"
        "config/git/gitignore_global"
        "config/nvim/init.lua"
        "config/tmux/tmux.conf"
    )

    for config in "${required_configs[@]}"; do
        local full_path="$PROJECT_ROOT/$config"
        assert_test "test -f '$full_path'" "Required config exists: $config"
    done

    # Check for personal configurations
    local personal_configs=(
        "config/zsh/personal-aliases"
        "config/zsh/personal-functions"
        "config/zsh/completions"
        "config/zsh/exports"
    )

    for config in "${personal_configs[@]}"; do
        local full_path="$PROJECT_ROOT/$config"
        assert_test "test -f '$full_path'" "Personal config exists: $config"
    done
}

# Test aliases and functions for common issues
test_aliases_functions() {
    log_info "Testing aliases and functions..."

    local alias_files=(
        "$PROJECT_ROOT/config/zsh/aliases"
        "$PROJECT_ROOT/config/zsh/personal-aliases"
    )

    for file in "${alias_files[@]}"; do
        if [[ -f "$file" ]]; then
            local filename
            filename="$(basename "$file")"

            # Check for proper alias syntax
            assert_test "! grep -E '^alias [^=]*[^=]$' '$file'" "$filename: No aliases without values"

            # Check aliases don't have spaces around =
            assert_test "! grep -E '^alias [^=]* = ' '$file'" "$filename: No spaces around = in aliases"
        fi
    done

    local function_files=(
        "$PROJECT_ROOT/config/zsh/functions"
        "$PROJECT_ROOT/config/zsh/personal-functions"
    )

    for file in "${function_files[@]}"; do
        if [[ -f "$file" ]]; then
            local filename
            filename="$(basename "$file")"

            # Check function syntax
            assert_test "! grep -E '^[a-zA-Z_][a-zA-Z0-9_]*\\(\\).*\\{.*\\}$' '$file'" "$filename: Functions use proper multi-line format"
        fi
    done
}

# Test for security issues
test_security() {
    log_info "Testing for security issues..."

    # Check for hardcoded credentials or sensitive data (more specific patterns)
    local sensitive_patterns=(
        "password.*="
        "secret.*="
        "token.*="
        "api_key.*="
        "private_key.*="
    )

    for pattern in "${sensitive_patterns[@]}"; do
        if ! grep -ri "$pattern" "$PROJECT_ROOT" --exclude-dir=.git --exclude="*.md" --exclude-dir=tests >/dev/null 2>&1; then
            log_success "No obvious credentials found for pattern: $pattern"
            ((TESTS_PASSED++))
        else
            log_warn "Potential sensitive data found for pattern: $pattern"
            ((TESTS_FAILED++))
        fi
        ((TESTS_RUN++))
    done

    # Check file permissions for executable scripts (exclude library files)
    find "$PROJECT_ROOT" -type f \( -name "*.sh" -o -name "dotfiles" -o -name "workflow-helper" \) \
         ! -path "$PROJECT_ROOT/lib/*" \
         ! -name "utils.sh" \
         ! -name "logging.sh" \
         ! -name "os-detect.sh" | while read -r script; do
        if [[ -x "$script" ]]; then
            log_success "Script is executable: $(basename "$script")"
            ((TESTS_PASSED++))
        else
            log_error "Script should be executable: $(basename "$script")"
            ((TESTS_FAILED++))
        fi
        ((TESTS_RUN++))
    done
}

# Print test summary
print_summary() {
    echo ""
    log_info "Configuration Test Summary"
    log_info "=========================="
    log_info "Total tests: $TESTS_RUN"
    log_success "Passed: $TESTS_PASSED"

    if [[ $TESTS_FAILED -gt 0 ]]; then
        log_error "Failed: $TESTS_FAILED"
        echo ""
        log_error "Some configuration tests failed. Please review the output above."
        return 1
    else
        echo ""
        log_success "All configuration tests passed! 🎉"
        return 0
    fi
}

# Main function
main() {
    log_info "Configuration Validation Tests"
    log_info "============================="

    # Debug info for CI
    if [[ -n "${CI:-}" || -n "${GITHUB_ACTIONS:-}" ]]; then
        log_info "CI Environment Debug Info:"
        log_info "Working directory: $(pwd)"
        log_info "Files in current dir: $(ls -la | head -5 | tail -4)"
        log_info "Zsh location: $(command -v zsh || echo 'zsh not found')"
        log_info "Shell: $SHELL"
    fi

    # Run all tests
    test_config_structure
    test_zsh_configs
    test_shell_scripts
    test_git_config
    test_neovim_config
    test_tmux_config
    test_makefile
    test_utility_scripts
    test_aliases_functions
    test_security

    # Print results
    if print_summary; then
        exit 0
    else
        exit 1
    fi
}

main "$@"
