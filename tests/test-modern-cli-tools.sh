#!/usr/bin/env bash

# Modern CLI Tools Integration Tests
# Tests that all modern CLI tools are properly configured and functional

set -uo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

log_info() { printf "${BLUE}ℹ %s${NC}\\n" "$*" >&2; }
log_success() { printf "${GREEN}✓ %s${NC}\\n" "$*" >&2; }
log_warn() { printf "${YELLOW}⚠ %s${NC}\\n" "$*" >&2; }
log_error() { printf "${RED}✗ %s${NC}\\n" "$*" >&2; }

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

# Test modern CLI tools availability in mise config
test_mise_tools_config() {
    log_info "Testing mise configuration for modern tools..."

    local mise_config="$PROJECT_ROOT/config/mise/config.toml"

    if [[ -f "$mise_config" ]]; then
        local modern_tools=("eza" "bat" "ripgrep" "fd" "delta" "zoxide")

        for tool in "${modern_tools[@]}"; do
            assert_test "grep -q '$tool.*latest' '$mise_config'" "mise config includes $tool"
        done
    else
        log_error "mise config file not found"
        ((TESTS_FAILED++))
    fi
}

# Test CLI tools directory structure
test_cli_tools_structure() {
    log_info "Testing CLI tools directory structure..."

    local cli_tools_dir="$PROJECT_ROOT/config/cli-tools"

    # Check main directory exists
    assert_test "test -d '$cli_tools_dir'" "CLI tools directory exists"

    # Check configuration files exist
    local config_files=(
        "aliases"
        "eza.conf"
        "bat.conf"
        "ripgrep.conf"
        "fd.conf"
        "delta.conf"
        "zoxide.conf"
        "init"
    )

    for config_file in "${config_files[@]}"; do
        assert_test "test -f '$cli_tools_dir/$config_file'" "CLI tools config exists: $config_file"
    done
}

# Test zsh integration
test_zsh_integration() {
    log_info "Testing zsh integration..."

    local zshrc="$PROJECT_ROOT/config/zsh/zshrc"

    if [[ -f "$zshrc" ]]; then
        # Check that CLI tools are loaded
        assert_test "grep -q 'config/cli-tools/init' '$zshrc'" "zshrc loads CLI tools configuration"

        # Check that duplicate zoxide init is removed
        assert_test "! grep -q 'zoxide init zsh' '$zshrc'" "zshrc doesn't have duplicate zoxide init"
    fi
}

# Test git configuration for delta
test_git_delta_config() {
    log_info "Testing git delta configuration..."

    local git_template="$PROJECT_ROOT/config/git/gitconfig.template"

    if [[ -f "$git_template" ]]; then
        # Check delta configuration sections
        assert_test "grep -q '\\[delta\\]' '$git_template'" "git template has delta section"
        assert_test "grep -q 'external.*delta' '$git_template'" "git template configures delta as external diff"
        assert_test "grep -q 'diffFilter.*delta' '$git_template'" "git template configures delta diff filter"
        assert_test "grep -q 'side-by-side' '$git_template'" "git template has delta side-by-side config"
        assert_test "grep -q 'line-numbers' '$git_template'" "git template has delta line numbers config"
    fi
}

# Test configuration file syntax
test_config_syntax() {
    log_info "Testing configuration file syntax..."

    local cli_tools_dir="$PROJECT_ROOT/config/cli-tools"

    # Test that init script can be sourced (basic syntax check)
    assert_test "zsh -n '$cli_tools_dir/init'" "CLI tools init script has valid syntax"

    # Test configuration files for basic shell syntax
    for conf_file in "$cli_tools_dir"/*.conf; do
        if [[ -f "$conf_file" ]]; then
            local filename="$(basename "$conf_file")"
            assert_test "bash -n '$conf_file'" "Configuration syntax valid: $filename"
        fi
    done
}

# Test alias definitions
test_aliases() {
    log_info "Testing alias definitions..."

    local aliases_file="$PROJECT_ROOT/config/cli-tools/aliases"

    if [[ -f "$aliases_file" ]]; then
        # Check for proper alias syntax and tool availability checks
        assert_test "grep -q 'command -v eza' '$aliases_file'" "eza aliases have availability check"
        assert_test "grep -q 'command -v bat' '$aliases_file'" "bat aliases have availability check"
        assert_test "grep -q 'command -v rg' '$aliases_file'" "ripgrep aliases have availability check"
        assert_test "grep -q 'command -v fd' '$aliases_file'" "fd aliases have availability check"
        assert_test "grep -q 'command -v zoxide' '$aliases_file'" "zoxide aliases have availability check"

        # Check for fallback aliases
        assert_test "grep -q 'alias ll=' '$aliases_file'" "fallback aliases defined"
    fi
}

# Test tool-specific configurations
test_tool_configurations() {
    log_info "Testing tool-specific configurations..."

    local cli_tools_dir="$PROJECT_ROOT/config/cli-tools"

    # Test eza configuration
    local eza_conf="$cli_tools_dir/eza.conf"
    if [[ -f "$eza_conf" ]]; then
        assert_test "grep -q 'EZA_COLORS' '$eza_conf'" "eza has color configuration"
        assert_test "grep -q 'group-directories-first' '$eza_conf'" "eza has directory grouping"
        assert_test "grep -q 'icons' '$eza_conf'" "eza has icon support"
    fi

    # Test bat configuration
    local bat_conf="$cli_tools_dir/bat.conf"
    if [[ -f "$bat_conf" ]]; then
        assert_test "grep -q 'BAT_THEME' '$bat_conf'" "bat has theme configuration"
        assert_test "grep -q 'BAT_STYLE' '$bat_conf'" "bat has style configuration"
        assert_test "grep -q 'bat_light\\|bat_dark' '$bat_conf'" "bat has theme switching functions"
    fi

    # Test zoxide configuration
    local zoxide_conf="$cli_tools_dir/zoxide.conf"
    if [[ -f "$zoxide_conf" ]]; then
        assert_test "grep -q '_ZO_ECHO' '$zoxide_conf'" "zoxide has echo configuration"
        assert_test "grep -q 'zoxide_stats' '$zoxide_conf'" "zoxide has utility functions"
        assert_test "grep -q 'project()' '$zoxide_conf'" "zoxide has project navigation function"
    fi
}

# Test for integration conflicts
test_integration_conflicts() {
    log_info "Testing for integration conflicts..."

    # Check that we don't have conflicting alias definitions
    local zsh_aliases="$PROJECT_ROOT/config/zsh/aliases"
    local cli_aliases="$PROJECT_ROOT/config/cli-tools/aliases"

    if [[ -f "$zsh_aliases" && -f "$cli_aliases" ]]; then
        # Check for potential conflicts in common aliases
        local common_aliases=("ls" "ll" "cat" "grep" "find")

        for alias_name in "${common_aliases[@]}"; do
            local zsh_has_alias=false
            local cli_has_alias=false

            if grep -q "^alias $alias_name=" "$zsh_aliases" 2>/dev/null; then
                zsh_has_alias=true
            fi

            if grep -q "alias $alias_name=" "$cli_aliases" 2>/dev/null; then
                cli_has_alias=true
            fi

            if [[ "$zsh_has_alias" == "true" && "$cli_has_alias" == "true" ]]; then
                log_warn "Potential alias conflict for '$alias_name' between zsh/aliases and cli-tools/aliases"
            fi
        done
    fi

    # This is informational, so we consider it passed
    log_success "Integration conflict check completed"
    ((TESTS_PASSED++))
    ((TESTS_RUN++))
}

# Test performance impact
test_performance() {
    log_info "Testing performance impact..."

    local init_script="$PROJECT_ROOT/config/cli-tools/init"

    if [[ -f "$init_script" ]]; then
        # Test that the init script loads quickly (under 500ms - more realistic)
        local start_time=$(date +%s%N)
        (
            # Run in subshell to avoid affecting current environment
            export DOTFILES="$PROJECT_ROOT"
            source "$init_script" >/dev/null 2>&1 || true
        )
        local end_time=$(date +%s%N)
        local duration=$(((end_time - start_time) / 1000000))  # Convert to milliseconds

        if [[ $duration -lt 500 ]]; then
            log_success "CLI tools init loads quickly (${duration}ms)"
            ((TESTS_PASSED++))
        else
            log_warn "CLI tools init loads slowly (${duration}ms)"
            ((TESTS_FAILED++))
        fi
        ((TESTS_RUN++))
    fi
}

# Print test summary
print_summary() {
    echo ""
    log_info "Modern CLI Tools Test Summary"
    log_info "============================="
    log_info "Total tests: $TESTS_RUN"
    log_success "Passed: $TESTS_PASSED"

    if [[ $TESTS_FAILED -gt 0 ]]; then
        log_error "Failed: $TESTS_FAILED"
        echo ""
        log_error "Some CLI tools tests failed. Please review the output above."
        return 1
    else
        echo ""
        log_success "All CLI tools tests passed! 🚀"
        return 0
    fi
}

# Main function
main() {
    log_info "Modern CLI Tools Integration Tests"
    log_info "=================================="

    # Run all tests
    test_mise_tools_config
    test_cli_tools_structure
    test_zsh_integration
    test_git_delta_config
    test_config_syntax
    test_aliases
    test_tool_configurations
    test_integration_conflicts
    test_performance

    # Print results
    if print_summary; then
        exit 0
    else
        exit 1
    fi
}

main "$@"