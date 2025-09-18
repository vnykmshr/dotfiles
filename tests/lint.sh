#!/usr/bin/env bash

# Simple Shell Script Linting
# Basic syntax checking and style validation

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'; NC='\033[0m'

log_info() { printf "${BLUE}ℹ %s${NC}\n" "$*"; }
log_success() { printf "${GREEN}✓ %s${NC}\n" "$*"; }
log_error() { printf "${RED}✗ %s${NC}\n" "$*"; }

PASSED=0; FAILED=0

check_file() {
    local file="$1"
    if bash -n "$file" 2>/dev/null; then
        log_success "$(basename "$file")"
        ((PASSED++))
    else
        log_error "$(basename "$file")"
        ((FAILED++))
    fi
}

main() {
    log_info "Shell Script Linting"
    log_info "===================="

    while IFS= read -r -d '' file; do
        check_file "$file"
    done < <(find "$PROJECT_ROOT" -name "*.sh" -type f -print0)

    echo
    log_info "Results: $PASSED passed, $FAILED failed"
    [[ $FAILED -eq 0 ]] && log_success "All scripts valid!" || exit 1
}

main "$@"