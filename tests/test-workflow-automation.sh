#!/usr/bin/env bash

# Workflow Automation Integration Tests
# Tests that all workflow automation tools work correctly

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

# Test workflow tools exist and are executable
test_workflow_tools_structure() {
    log_info "Testing workflow tools structure..."

    local workflow_dir="$PROJECT_ROOT/config/workflow"

    # Check main directory exists
    assert_test "test -d '$workflow_dir'" "Workflow directory exists"

    # Check workflow tools exist and are executable
    local tools=(
        "test-runner"
        "project-init"
        "git-helpers"
        "dev-server"
        "aliases"
        "init"
    )

    for tool in "${tools[@]}"; do
        local tool_path="$workflow_dir/$tool"
        assert_test "test -f '$tool_path'" "Workflow tool exists: $tool"

        if [[ "$tool" != "aliases" && "$tool" != "init" ]]; then
            assert_test "test -x '$tool_path'" "Workflow tool is executable: $tool"
        fi
    done
}

# Test workflow tools syntax
test_workflow_syntax() {
    log_info "Testing workflow tools syntax..."

    local workflow_dir="$PROJECT_ROOT/config/workflow"

    # Test shell script syntax
    local shell_tools=("test-runner" "project-init" "git-helpers" "dev-server")

    for tool in "${shell_tools[@]}"; do
        local tool_path="$workflow_dir/$tool"
        if [[ -f "$tool_path" ]]; then
            assert_test "bash -n '$tool_path'" "Workflow tool syntax valid: $tool"
        fi
    done

    # Test init files
    local init_files=("aliases" "init")
    for file in "${init_files[@]}"; do
        local file_path="$workflow_dir/$file"
        if [[ -f "$file_path" ]]; then
            assert_test "zsh -n '$file_path'" "Workflow file syntax valid: $file"
        fi
    done
}

# Test test-runner functionality
test_test_runner() {
    log_info "Testing test-runner functionality..."

    local test_runner="$PROJECT_ROOT/config/workflow/test-runner"

    if [[ -x "$test_runner" ]]; then
        # Test help option
        assert_test "'$test_runner' --help >/dev/null" "test-runner shows help"

        # Test info option in current directory
        assert_test "'$test_runner' --info >/dev/null" "test-runner shows project info"

        # Test in a temporary Node.js project
        local temp_dir=$(mktemp -d)
        (
            cd "$temp_dir"
            echo '{"name": "test", "scripts": {"test": "echo test"}}' > package.json

            # Test project detection
            local output
            output=$("$test_runner" --info 2>/dev/null)
            if echo "$output" | grep -q "nodejs"; then
                log_success "test-runner detects Node.js projects"
                ((TESTS_PASSED++))
            else
                log_error "test-runner fails to detect Node.js projects"
                ((TESTS_FAILED++))
            fi
            ((TESTS_RUN++))
        )
        rm -rf "$temp_dir"
    fi
}

# Test project-init functionality
test_project_init() {
    log_info "Testing project-init functionality..."

    local project_init="$PROJECT_ROOT/config/workflow/project-init"

    if [[ -x "$project_init" ]]; then
        # Test help option
        assert_test "'$project_init' --help >/dev/null" "project-init shows help"

        # Test project creation in temp directory
        local temp_dir=$(mktemp -d)
        (
            cd "$temp_dir"

            # Test Node.js project creation (updated for clean version)
            if "$project_init" -t nodejs test-project >/dev/null 2>&1; then
                if [[ -d "test-project" && -f "test-project/package.json" && -f "test-project/index.js" ]]; then
                    log_success "project-init creates Node.js projects"
                    ((TESTS_PASSED++))
                else
                    log_error "project-init creates incomplete Node.js projects"
                    ((TESTS_FAILED++))
                fi
            else
                log_error "project-init fails to create Node.js projects"
                ((TESTS_FAILED++))
            fi
            ((TESTS_RUN++))

            # Test Python project creation
            if "$project_init" -t python test-py-project >/dev/null 2>&1; then
                if [[ -d "test-py-project" && -f "test-py-project/main.py" ]]; then
                    log_success "project-init creates Python projects"
                    ((TESTS_PASSED++))
                else
                    log_error "project-init creates incomplete Python projects"
                    ((TESTS_FAILED++))
                fi
            else
                log_error "project-init fails to create Python projects"
                ((TESTS_FAILED++))
            fi
            ((TESTS_RUN++))
        )
        rm -rf "$temp_dir"
    fi
}

# Test git-helpers functionality
test_git_helpers() {
    log_info "Testing git-helpers functionality..."

    local git_helpers="$PROJECT_ROOT/config/workflow/git-helpers"

    if [[ -x "$git_helpers" ]]; then
        # Test help option
        assert_test "'$git_helpers' --help >/dev/null" "git-helpers shows help"

        # Test in git repository (current project)
        if git rev-parse --git-dir >/dev/null 2>&1; then
            # Test status command
            assert_test "'$git_helpers' status >/dev/null" "git-helpers status works in git repo"

            # Test that it detects git repository correctly
            local output
            output=$("$git_helpers" status 2>/dev/null)
            if echo "$output" | grep -q "Branch:"; then
                log_success "git-helpers shows branch information"
                ((TESTS_PASSED++))
            else
                log_error "git-helpers fails to show branch information"
                ((TESTS_FAILED++))
            fi
            ((TESTS_RUN++))
        fi

        # Test in non-git directory
        local temp_dir=$(mktemp -d)
        (
            cd "$temp_dir"
            if ! "$git_helpers" status >/dev/null 2>&1; then
                log_success "git-helpers properly handles non-git directories"
                ((TESTS_PASSED++))
            else
                log_error "git-helpers should fail in non-git directories"
                ((TESTS_FAILED++))
            fi
            ((TESTS_RUN++))
        )
        rm -rf "$temp_dir"
    fi
}

# Test dev-server functionality
test_dev_server() {
    log_info "Testing dev-server functionality..."

    local dev_server="$PROJECT_ROOT/config/workflow/dev-server"

    if [[ -x "$dev_server" ]]; then
        # Test help option
        assert_test "'$dev_server' --help >/dev/null" "dev-server shows help"

        # Test list option
        assert_test "'$dev_server' --info >/dev/null" "dev-server can show project info"

        # Test dry run functionality
        assert_test "'$dev_server' --dry-run >/dev/null" "dev-server dry run mode works"

        # Test project detection in temporary projects
        local temp_dir=$(mktemp -d)
        (
            cd "$temp_dir"

            # Test Node.js project detection
            echo '{"name": "test", "scripts": {"dev": "echo dev"}}' > package.json
            local output
            output=$("$dev_server" --list 2>/dev/null)
            if echo "$output" | grep -q "npm run dev"; then
                log_success "dev-server detects Node.js dev scripts"
                ((TESTS_PASSED++))
            else
                log_error "dev-server fails to detect Node.js dev scripts"
                ((TESTS_FAILED++))
            fi
            ((TESTS_RUN++))

            # Test static site detection
            rm package.json
            echo "<html><body>Test</body></html>" > index.html
            output=$("$dev_server" --list 2>/dev/null)
            if echo "$output" | grep -q "HTTP server"; then
                log_success "dev-server detects static sites"
                ((TESTS_PASSED++))
            else
                log_error "dev-server fails to detect static sites"
                ((TESTS_FAILED++))
            fi
            ((TESTS_RUN++))
        )
        rm -rf "$temp_dir"
    fi
}

# Test zsh integration
test_zsh_integration() {
    log_info "Testing zsh integration..."

    local zshrc="$PROJECT_ROOT/config/zsh/zshrc"

    if [[ -f "$zshrc" ]]; then
        # Check that workflow tools are loaded
        assert_test "grep -q 'config/workflow/init' '$zshrc'" "zshrc loads workflow configuration"
    fi

    # Test workflow aliases file
    local workflow_aliases="$PROJECT_ROOT/config/workflow/aliases"
    if [[ -f "$workflow_aliases" ]]; then
        # Check for main aliases
        assert_test "grep -q 'alias t=' '$workflow_aliases'" "workflow aliases include test shortcut"
        assert_test "grep -q 'alias dev=' '$workflow_aliases'" "workflow aliases include dev shortcut"
        assert_test "grep -q 'alias pinit=' '$workflow_aliases'" "workflow aliases include project init"
        assert_test "grep -q 'alias gw=' '$workflow_aliases'" "workflow aliases include git workflow"

        # Check for workflow functions
        assert_test "grep -q 'test.*test-runner' '$workflow_aliases'" "workflow includes test alias"
        assert_test "grep -q 'dev.*dev-server' '$workflow_aliases'" "workflow includes dev alias"
    fi
}

# Test workflow initialization
test_workflow_init() {
    log_info "Testing workflow initialization..."

    local workflow_init="$PROJECT_ROOT/config/workflow/init"

    if [[ -f "$workflow_init" ]]; then
        # Test that init file sources aliases
        assert_test "grep -q 'source.*aliases' '$workflow_init'" "workflow init sources aliases"

        # Test that init adds tools to PATH
        assert_test "grep -q 'PATH.*workflow_dir' '$workflow_init'" "workflow init adds tools to PATH"

        # Test workflow check function
        assert_test "grep -q 'workflow_check()' '$workflow_init'" "workflow init defines check function"
    fi
}

# Test error handling and edge cases
test_error_handling() {
    log_info "Testing error handling..."

    local workflow_dir="$PROJECT_ROOT/config/workflow"

    # Test tools with invalid arguments
    for tool in test-runner project-init git-helpers dev-server; do
        local tool_path="$workflow_dir/$tool"
        if [[ -x "$tool_path" ]]; then
            # Test that tools handle invalid options gracefully
            if "$tool_path" --invalid-option >/dev/null 2>&1; then
                log_error "$tool should reject invalid options"
                ((TESTS_FAILED++))
            else
                log_success "$tool properly handles invalid options"
                ((TESTS_PASSED++))
            fi
            ((TESTS_RUN++))
        fi
    done

    # Test project-init with invalid project name
    local project_init="$workflow_dir/project-init"
    if [[ -x "$project_init" ]]; then
        local temp_dir=$(mktemp -d)
        (
            cd "$temp_dir"
            if "$project_init" "invalid name with spaces" >/dev/null 2>&1; then
                log_error "project-init should reject invalid project names"
                ((TESTS_FAILED++))
            else
                log_success "project-init properly validates project names"
                ((TESTS_PASSED++))
            fi
            ((TESTS_RUN++))
        )
        rm -rf "$temp_dir"
    fi
}

# Test documentation and help
test_documentation() {
    log_info "Testing documentation and help..."

    local workflow_dir="$PROJECT_ROOT/config/workflow"

    # Test that all tools provide help
    for tool in test-runner project-init git-helpers dev-server; do
        local tool_path="$workflow_dir/$tool"
        if [[ -x "$tool_path" ]]; then
            # Test help options
            local help_output
            help_output=$("$tool_path" --help 2>/dev/null || "$tool_path" -h 2>/dev/null || echo "")

            if [[ -n "$help_output" ]]; then
                log_success "$tool provides help documentation"
                ((TESTS_PASSED++))

                # Check if help contains usage information
                if echo "$help_output" | grep -qi "usage"; then
                    log_success "$tool help includes usage information"
                    ((TESTS_PASSED++))
                else
                    log_warn "$tool help missing usage information"
                    ((TESTS_FAILED++))
                fi
                ((TESTS_RUN++))
            else
                log_error "$tool fails to provide help"
                ((TESTS_FAILED++))
            fi
            ((TESTS_RUN++))
        fi
    done
}

# Test dry run functionality across all tools
test_dry_run_functionality() {
    log_info "Testing dry run functionality..."

    local workflow_dir="$PROJECT_ROOT/config/workflow"

    # Test test-runner dry run
    if [[ -x "$workflow_dir/test-runner" ]]; then
        assert_test "'$workflow_dir/test-runner' --dry-run >/dev/null 2>&1" "test-runner dry run works"

        local output
        output=$("$workflow_dir/test-runner" --dry-run 2>&1)
        if echo "$output" | grep -q "\[DRY RUN\]"; then
            log_success "test-runner shows proper dry run indicators"
            ((TESTS_PASSED++))
        else
            log_error "test-runner missing dry run indicators"
            ((TESTS_FAILED++))
        fi
        ((TESTS_RUN++))
    fi

    # Note: Clean version of project-init is simplified without dry-run option
    if [[ -x "$workflow_dir/project-init" ]]; then
        local temp_dir=$(mktemp -d)
        (
            cd "$temp_dir"
            # Test that help works for simplified version
            if "$workflow_dir/project-init" --help >/dev/null 2>&1; then
                log_success "project-init help works as expected"
                ((TESTS_PASSED++))
            else
                log_error "project-init help not working"
                ((TESTS_FAILED++))
            fi
            ((TESTS_RUN++))
        )
        rm -rf "$temp_dir"
    fi

    # Test git-helpers (clean version uses simplified commands)
    if [[ -x "$workflow_dir/git-helpers" ]]; then
        if git rev-parse --git-dir >/dev/null 2>&1; then
            assert_test "'$workflow_dir/git-helpers' status >/dev/null 2>&1" "git-helpers status works"
        fi
    fi

    # Test dev-server dry run
    if [[ -x "$workflow_dir/dev-server" ]]; then
        assert_test "'$workflow_dir/dev-server' --dry-run >/dev/null 2>&1" "dev-server dry run works"
    fi
}

# Test performance and resource usage
test_performance() {
    log_info "Testing performance..."

    local workflow_init="$PROJECT_ROOT/config/workflow/init"

    if [[ -f "$workflow_init" ]]; then
        # Test that workflow init loads quickly
        local start_time=$(date +%s%N)
        (
            export DOTFILES="$PROJECT_ROOT"
            source "$workflow_init" >/dev/null 2>&1 || true
        )
        local end_time=$(date +%s%N)
        local duration=$(((end_time - start_time) / 1000000))  # Convert to milliseconds

        if [[ $duration -lt 200 ]]; then
            log_success "Workflow init loads quickly (${duration}ms)"
            ((TESTS_PASSED++))
        else
            log_warn "Workflow init loads slowly (${duration}ms)"
            ((TESTS_FAILED++))
        fi
        ((TESTS_RUN++))
    fi
}

# Print test summary
print_summary() {
    echo ""
    log_info "Workflow Automation Test Summary"
    log_info "==============================="
    log_info "Total tests: $TESTS_RUN"
    log_success "Passed: $TESTS_PASSED"

    if [[ $TESTS_FAILED -gt 0 ]]; then
        log_error "Failed: $TESTS_FAILED"
        echo ""
        log_error "Some workflow automation tests failed. Please review the output above."
        return 1
    else
        echo ""
        log_success "All workflow automation tests passed! 🎉"
        return 0
    fi
}

# Main function
main() {
    log_info "Workflow Automation Integration Tests"
    log_info "====================================="

    # Run all tests
    test_workflow_tools_structure
    test_workflow_syntax
    test_test_runner
    test_project_init
    test_git_helpers
    test_dev_server
    test_zsh_integration
    test_workflow_init
    test_error_handling
    test_documentation
    test_dry_run_functionality
    test_performance

    # Print results
    if print_summary; then
        exit 0
    else
        exit 1
    fi
}

main "$@"