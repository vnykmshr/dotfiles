#!/usr/bin/env bash

# Shell Script Linting and Validation
# Ensures all shell scripts follow best practices and are error-free

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Counters
TOTAL_FILES=0
PASSED_FILES=0
FAILED_FILES=0

log_info() { printf "${BLUE}ℹ %s${NC}\n" "$*" >&2; }
log_success() { printf "${GREEN}✓ %s${NC}\n" "$*" >&2; }
log_warn() { printf "${YELLOW}⚠ %s${NC}\n" "$*" >&2; }
log_error() { printf "${RED}✗ %s${NC}\n" "$*" >&2; }

# Check if required tools are installed
check_dependencies() {
    local missing_tools=()

    if ! command -v shellcheck >/dev/null 2>&1; then
        missing_tools+=("shellcheck")
    fi

    if ! command -v shfmt >/dev/null 2>&1; then
        missing_tools+=("shfmt")
    fi

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Install with: brew install shellcheck shfmt"
        log_info "Or: sudo apt-get install shellcheck"
        return 1
    fi
}

# Lint a single shell script
lint_script() {
    local script_path="$1"
    local filename
    filename="$(basename "$script_path")"

    log_info "Linting: $filename"

    local errors=0

    # Check if file is executable when it should be
    if [[ "$script_path" =~ \.(sh)$ ]] || [[ -f "$script_path" && $(head -1 "$script_path") =~ ^#!/ ]]; then
        if [[ ! -x "$script_path" ]]; then
            log_warn "$filename: Should be executable (chmod +x)"
            ((errors++))
        fi
    fi

    # Run shellcheck
    if ! shellcheck \
        --severity=warning \
        --exclude=SC1090,SC1091 \
        --format=gcc \
        "$script_path" 2>/dev/null; then
        log_error "$filename: Failed shellcheck"
        ((errors++))
    fi

    # Check shell formatting
    if ! shfmt -d -i 4 -ci "$script_path" >/dev/null 2>&1; then
        log_warn "$filename: Formatting issues (run: shfmt -w -i 4 -ci $script_path)"
        ((errors++))
    fi

    # Check for common issues
    check_common_issues "$script_path" "$filename"
    local common_issues=$?
    ((errors += common_issues))

    if [[ $errors -eq 0 ]]; then
        log_success "$filename: All checks passed"
        ((PASSED_FILES++))
    else
        log_error "$filename: $errors issues found"
        ((FAILED_FILES++))
    fi

    ((TOTAL_FILES++))
}

# Check for common shell script issues
check_common_issues() {
    local script_path="$1"
    local filename="$2"
    local issues=0

    # Check for missing shebang
    if ! head -1 "$script_path" | grep -q '^#!'; then
        log_warn "$filename: Missing shebang"
        ((issues++))
    fi

    # Check for 'set -e' or 'set -euo pipefail'
    if ! grep -q 'set -[euo]' "$script_path"; then
        log_warn "$filename: Consider adding 'set -euo pipefail' for better error handling"
        ((issues++))
    fi

    # Check for hardcoded paths
    if grep -q '/usr/local/bin\|/opt/homebrew' "$script_path" 2>/dev/null; then
        log_warn "$filename: Contains hardcoded paths that might not be portable"
        ((issues++))
    fi

    # Check for unquoted variables
    if grep -E '\$[A-Za-z_][A-Za-z0-9_]*[^"]' "$script_path" >/dev/null 2>&1; then
        log_warn "$filename: Potentially unquoted variables found"
        ((issues++))
    fi

    return $issues
}

# Find all shell scripts
find_shell_scripts() {
    find "$PROJECT_ROOT" \
        -type f \
        \( -name "*.sh" \
        -o -name "*.bash" \
        -o -name "*.zsh" \
        -o -executable \) \
        -not -path "*/.*" \
        -not -path "*/node_modules/*" \
        -not -path "*/build/*" \
        -not -path "*/dist/*" \
        | while read -r file; do
        # Check if it's actually a shell script
        if [[ "$file" =~ \.(sh|bash|zsh)$ ]] || [[ -f "$file" && $(head -1 "$file" 2>/dev/null) =~ ^#!/.*sh ]]; then
            echo "$file"
        fi
    done
}

# Auto-fix formatting issues
fix_formatting() {
    log_info "Auto-fixing shell script formatting..."

    find_shell_scripts | while read -r script; do
        if [[ -f "$script" ]]; then
            log_info "Formatting: $(basename "$script")"
            shfmt -w -i 4 -ci "$script"
        fi
    done

    log_success "Formatting complete"
}

# Main function
main() {
    local fix_format=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --fix|-f)
                fix_format=true
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [--fix|-f] [--help|-h]"
                echo "  --fix, -f    Auto-fix formatting issues"
                echo "  --help, -h   Show this help message"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    log_info "Shell Script Linting and Validation"
    log_info "====================================="

    # Check dependencies
    if ! check_dependencies; then
        exit 1
    fi

    # Fix formatting if requested
    if [[ "$fix_format" == "true" ]]; then
        fix_formatting
        log_info ""
    fi

    # Find and lint all shell scripts
    log_info "Scanning for shell scripts..."

    local scripts
    mapfile -t scripts < <(find_shell_scripts)

    if [[ ${#scripts[@]} -eq 0 ]]; then
        log_warn "No shell scripts found"
        exit 0
    fi

    log_info "Found ${#scripts[@]} shell scripts"
    echo ""

    # Lint each script
    for script in "${scripts[@]}"; do
        lint_script "$script"
    done

    # Summary
    echo ""
    log_info "Summary"
    log_info "======="
    log_info "Total files: $TOTAL_FILES"
    log_success "Passed: $PASSED_FILES"

    if [[ $FAILED_FILES -gt 0 ]]; then
        log_error "Failed: $FAILED_FILES"
        echo ""
        log_info "To fix formatting issues, run: $0 --fix"
        exit 1
    else
        log_success "All shell scripts passed validation!"
    fi
}

main "$@"