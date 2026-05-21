#!/usr/bin/env bash

set -eo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(dirname "${BASH_SOURCE[0]}")"

echo "Comprehensive Dotfiles Test Suite"
echo "================================="
echo ""

TESTS_PASSED=0
TESTS_FAILED=0

# Test essential files
files=(
    "config/zsh/zshrc"
    "config/zsh/aliases"
    "config/git/gitignore_global"
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
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo "✗ Required file missing: $file"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
done

echo "Testing syntax..."
# Test setup script
if bash -n "$PROJECT_ROOT/install/setup.sh" 2>/dev/null; then
    echo "✓ Shell syntax valid: setup.sh"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo "✗ Shell syntax invalid: setup.sh"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# Summary of basic tests
echo
echo "Basic Tests Summary"
echo "==================="
echo "Passed: $TESTS_PASSED"
if [[ $TESTS_FAILED -gt 0 ]]; then
    echo "Failed: $TESTS_FAILED"
fi
echo ""

# Run critical path tests
echo "Running Critical Path Tests..."
echo "=============================="
echo ""

SUITE_FAILED=0

if [[ -x "$TEST_DIR/test-critical-path.sh" ]]; then
    "$TEST_DIR/test-critical-path.sh" || SUITE_FAILED=1
else
    echo "Warning: critical path tests not found or not executable"
fi

# Run functionality tests
echo ""
echo "Running Functionality Tests..."
echo "=============================="
echo ""

if [[ -x "$TEST_DIR/test-functionality.sh" ]]; then
    "$TEST_DIR/test-functionality.sh" || SUITE_FAILED=1
else
    echo "Warning: functionality tests not found or not executable"
fi

# Run template processor tests
echo ""
echo "Running Template Processor Tests..."
echo "==================================="
echo ""

if [[ -x "$TEST_DIR/test-templates.sh" ]]; then
    "$TEST_DIR/test-templates.sh" || SUITE_FAILED=1
else
    echo "Warning: template tests not found or not executable"
fi

if [[ $SUITE_FAILED -eq 0 && $TESTS_FAILED -eq 0 ]]; then
    echo ""
    echo "All test suites passed!"
    exit 0
else
    echo ""
    echo "Some tests failed"
    exit 1
fi
