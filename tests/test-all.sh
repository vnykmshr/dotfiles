#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Comprehensive Dotfiles Test Suite"
echo "================================="

TESTS_PASSED=0
TESTS_FAILED=0

# Test essential files
files=(
    "config/zsh/zshrc"
    "config/zsh/aliases"
    "config/git/gitignore_global"
    "config/nvim/init.lua"
    "config/tmux/tmux.conf"
    "install/setup.sh"
    "Makefile"
    "README.md"
    "config/git/gitconfig.template"
    "config/ssh/config.template"
)

echo "Testing file structure..."
for file in "${files[@]}"; do
    if [[ -f "$PROJECT_ROOT/$file" ]]; then
        echo "✓ Required file exists: $file"
        ((TESTS_PASSED++))
    else
        echo "✗ Required file missing: $file"
        ((TESTS_FAILED++))
    fi
done

echo "Testing syntax..."
# Test key shell scripts
if bash -n "$PROJECT_ROOT/install/setup.sh" 2>/dev/null; then
    echo "✓ Shell syntax valid: setup.sh"
    ((TESTS_PASSED++))
else
    echo "✗ Shell syntax invalid: setup.sh"
    ((TESTS_FAILED++))
fi

if bash -n "$PROJECT_ROOT/tests/test-all.sh" 2>/dev/null; then
    echo "✓ Shell syntax valid: test-all.sh"
    ((TESTS_PASSED++))
else
    echo "✗ Shell syntax invalid: test-all.sh"
    ((TESTS_FAILED++))
fi

# Test git template
if grep -q '\[user\]' "$PROJECT_ROOT/config/git/gitconfig.template" 2>/dev/null; then
    echo "✓ Git template has [user] section"
    ((TESTS_PASSED++))
else
    echo "✗ Git template missing [user] section"
    ((TESTS_FAILED++))
fi

# Summary
echo
echo "Test Summary"
echo "============"
echo "Passed: $TESTS_PASSED"

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo "Failed: $TESTS_FAILED"
    exit 1
else
    echo "All tests passed!"
    exit 0
fi