#!/usr/bin/env bash

# Code Formatting and Style Check
# Ensures consistent formatting across all files

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
TOTAL_FILES=0
PASSED_FILES=0
FAILED_FILES=0

log_info() { printf "${BLUE}ℹ %s${NC}\n" "$*" >&2; }
log_success() { printf "${GREEN}✓ %s${NC}\n" "$*" >&2; }
log_warn() { printf "${YELLOW}⚠ %s${NC}\n" "$*" >&2; }
log_error() { printf "${RED}✗ %s${NC}\n" "$*" >&2; }

# Check dependencies
check_dependencies() {
    local missing_tools=()

    if ! command -v shfmt >/dev/null 2>&1; then
        missing_tools+=("shfmt")
    fi

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Install with: brew install shfmt"
        return 1
    fi
}

# Check file formatting
check_file_format() {
    local file="$1"
    local filename
    filename="$(basename "$file")"
    local issues=0

    log_info "Checking format: $filename"

    # Check for trailing whitespace
    if grep -q '[[:space:]]$' "$file" 2>/dev/null; then
        log_warn "$filename: Has trailing whitespace"
        ((issues++))
    fi

    # Check for missing final newline
    if [[ -s "$file" && $(tail -c1 "$file" | wc -l) -eq 0 ]]; then
        log_warn "$filename: Missing final newline"
        ((issues++))
    fi

    # Check for mixed line endings
    if file "$file" | grep -q CRLF; then
        log_warn "$filename: Has Windows line endings (CRLF)"
        ((issues++))
    fi

    # Check for tabs in files that should use spaces
    if [[ "$file" != *"Makefile"* && "$file" != *".make" && "$file" != *".mk" ]]; then
        if grep -q $'\t' "$file" 2>/dev/null; then
            log_warn "$filename: Contains tabs (should use spaces)"
            ((issues++))
        fi
    fi

    return $issues
}

# Check shell script formatting
check_shell_format() {
    local file="$1"
    local filename
    filename="$(basename "$file")"

    log_info "Checking shell format: $filename"

    # Check shfmt formatting
    if ! shfmt -d -i 4 -ci "$file" >/dev/null 2>&1; then
        log_warn "$filename: Shell formatting issues"
        return 1
    fi

    return 0
}

# Check markdown formatting
check_markdown_format() {
    local file="$1"
    local filename
    filename="$(basename "$file")"
    local issues=0

    log_info "Checking markdown format: $filename"

    # Check for long lines (except for links and code blocks)
    local long_lines
    long_lines=$(grep -n '.\{100,\}' "$file" | grep -v -E '^\d+:\s*\[.*\]\(.*\)' | grep -v -E '^\d+:\s*```' | grep -v -E '^\d+:\s*\|' || true)

    if [[ -n "$long_lines" ]]; then
        log_warn "$filename: Has lines longer than 100 characters"
        ((issues++))
    fi

    # Check for inconsistent list formatting
    if grep -q '^- ' "$file" && grep -q '^\* ' "$file"; then
        log_warn "$filename: Mixed list bullet styles (- and *)"
        ((issues++))
    fi

    return $issues
}

# Check JSON formatting
check_json_format() {
    local file="$1"
    local filename
    filename="$(basename "$file")"

    log_info "Checking JSON format: $filename"

    # Check JSON syntax
    if ! jq empty "$file" >/dev/null 2>&1; then
        log_error "$filename: Invalid JSON syntax"
        return 1
    fi

    # Check if formatted
    local formatted
    formatted="$(jq --indent 2 . "$file" 2>/dev/null)"
    if [[ "$formatted" != "$(cat "$file")" ]]; then
        log_warn "$filename: JSON not properly formatted"
        return 1
    fi

    return 0
}

# Check YAML formatting
check_yaml_format() {
    local file="$1"
    local filename
    filename="$(basename "$file")"

    log_info "Checking YAML format: $filename"

    # Check for tabs (YAML should use spaces)
    if grep -q $'\t' "$file" 2>/dev/null; then
        log_error "$filename: YAML contains tabs (should use spaces only)"
        return 1
    fi

    # Check indentation consistency (should be 2 spaces)
    if grep -E '^[[:space:]]{3}[^[:space:]]|^[[:space:]]{5}[^[:space:]]|^[[:space:]]{7}[^[:space:]]' "$file" >/dev/null 2>&1; then
        log_warn "$filename: Inconsistent YAML indentation (should be 2 spaces)"
        return 1
    fi

    return 0
}

# Format files automatically
format_files() {
    log_info "Auto-formatting files..."

    # Format shell scripts
    find "$PROJECT_ROOT" -name "*.sh" -o -name "*.bash" -o -name "*.zsh" | while read -r script; do
        if [[ -f "$script" ]]; then
            log_info "Formatting shell script: $(basename "$script")"
            shfmt -w -i 4 -ci "$script"
        fi
    done

    # Fix common issues in all text files
    find "$PROJECT_ROOT" -type f \
        -name "*.sh" -o -name "*.bash" -o -name "*.zsh" \
        -o -name "*.md" -o -name "*.lua" -o -name "*.json" \
        -o -name "*.yml" -o -name "*.yaml" -o -name "*.conf" \
        | while read -r file; do
        if [[ -f "$file" && ! "$file" =~ \.git/ ]]; then
            # Remove trailing whitespace
            sed -i '' 's/[[:space:]]*$//' "$file"

            # Ensure final newline
            if [[ -s "$file" && $(tail -c1 "$file" | wc -l) -eq 0 ]]; then
                echo "" >> "$file"
            fi
        fi
    done

    log_success "Auto-formatting complete"
}

# Check all files
check_all_files() {
    log_info "Scanning for files to check..."

    # Find all relevant files
    local files
    mapfile -t files < <(find "$PROJECT_ROOT" -type f \
        -name "*.sh" -o -name "*.bash" -o -name "*.zsh" \
        -o -name "*.md" -o -name "*.lua" -o -name "*.json" \
        -o -name "*.yml" -o -name "*.yaml" -o -name "*.conf" \
        -o -name "Makefile" -o -name "*.make" -o -name "*.mk" \
        | grep -v -E '\.(git|node_modules|build|dist)/')

    if [[ ${#files[@]} -eq 0 ]]; then
        log_warn "No files found to check"
        exit 0
    fi

    log_info "Found ${#files[@]} files to check"
    echo ""

    # Check each file
    for file in "${files[@]}"; do
        local filename
        filename="$(basename "$file")"
        local file_issues=0

        ((TOTAL_FILES++))

        # General format checks
        check_file_format "$file"
        local general_issues=$?
        ((file_issues += general_issues))

        # Specific format checks based on file type
        case "$file" in
            *.sh|*.bash|*.zsh)
                check_shell_format "$file"
                local shell_issues=$?
                ((file_issues += shell_issues))
                ;;
            *.md)
                check_markdown_format "$file"
                local md_issues=$?
                ((file_issues += md_issues))
                ;;
            *.json)
                check_json_format "$file"
                local json_issues=$?
                ((file_issues += json_issues))
                ;;
            *.yml|*.yaml)
                check_yaml_format "$file"
                local yaml_issues=$?
                ((file_issues += yaml_issues))
                ;;
        esac

        if [[ $file_issues -eq 0 ]]; then
            log_success "$filename: All format checks passed"
            ((PASSED_FILES++))
        else
            log_error "$filename: $file_issues formatting issues found"
            ((FAILED_FILES++))
        fi

        echo ""
    done
}

# Print summary
print_summary() {
    log_info "Format Check Summary"
    log_info "==================="
    log_info "Total files: $TOTAL_FILES"
    log_success "Passed: $PASSED_FILES"

    if [[ $FAILED_FILES -gt 0 ]]; then
        log_error "Failed: $FAILED_FILES"
        echo ""
        log_info "To auto-fix many issues, run: $0 --fix"
        return 1
    else
        log_success "All files passed format checks!"
        return 0
    fi
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

    log_info "Code Formatting and Style Check"
    log_info "==============================="

    # Check dependencies
    if ! check_dependencies; then
        exit 1
    fi

    # Fix formatting if requested
    if [[ "$fix_format" == "true" ]]; then
        format_files
        log_info ""
    fi

    # Check all files
    check_all_files

    # Print results
    if print_summary; then
        exit 0
    else
        exit 1
    fi
}

main "$@"