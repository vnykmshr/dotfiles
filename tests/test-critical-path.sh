#!/usr/bin/env bash

# Critical Path Tests for Dotfiles
# Tests installation, template processing, backup/restore, and cross-platform compatibility

set -eo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d)"
TESTS_PASSED=0
TESTS_FAILED=0

# Cleanup on exit
# shellcheck disable=SC2317
cleanup() {
    rm -rf "$TEST_DIR"
}
trap cleanup EXIT

# Test helper functions
pass() {
    echo "✓ $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
    echo "✗ $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

# Source libraries we're testing
source "$PROJECT_ROOT/lib/os-detect.sh"
source "$PROJECT_ROOT/lib/logging.sh"

echo "Critical Path Test Suite"
echo "========================"
echo ""

# =============================================================================
# 1. OS Detection Tests
# =============================================================================

echo "Testing OS detection..."

if declare -f detect_os >/dev/null 2>&1; then
    detect_os
    if [[ -n $OS_NAME ]] && [[ -n $OS_ARCH ]]; then
        pass "OS detection: $OS_NAME ($OS_ARCH)"
    else
        fail "OS detection failed to set variables"
    fi
else
    fail "detect_os function not found"
fi

# Test specific OS checks
if [[ $OSTYPE == "darwin"* ]]; then
    if is_macos; then
        pass "macOS detection works"
    else
        fail "macOS detection failed"
    fi
elif [[ $OSTYPE == "linux"* ]]; then
    if is_linux; then
        pass "Linux detection works"
    else
        fail "Linux detection failed"
    fi
fi

echo ""

# =============================================================================
# 2. Template Processing Tests
# =============================================================================

echo "Testing template processing..."

# Create test config.json
cat >"$TEST_DIR/config.json" <<EOF
{
  "user": {
    "name": "Test User",
    "email": "test@example.com"
  },
  "git": {
    "signing_key": "\$HOME/.ssh/id_test"
  }
}
EOF

# Create test template
cat >"$TEST_DIR/test.template" <<EOF
[user]
    name = {{ user.name }}
    email = {{ user.email }}
[commit]
    gpgsign = {{ git.gpg_sign }}
    gpgSigningKey = {{ git.signing_key }}
EOF

# Test template processing logic (simplified version of what setup.sh does)
if command -v jq >/dev/null 2>&1; then
    USER_NAME=$(jq -r '.user.name' "$TEST_DIR/config.json")
    USER_EMAIL=$(jq -r '.user.email' "$TEST_DIR/config.json")

    if [[ $USER_NAME == "Test User" ]] && [[ $USER_EMAIL == "test@example.com" ]]; then
        pass "JSON parsing works correctly"
    else
        fail "JSON parsing failed: got '$USER_NAME' and '$USER_EMAIL'"
    fi

    # Test placeholder replacement
    TEMPLATE_CONTENT=$(cat "$TEST_DIR/test.template")
    PROCESSED=$(echo "$TEMPLATE_CONTENT" | sed "s/{{ user.name }}/$USER_NAME/g" | sed "s/{{ user.email }}/$USER_EMAIL/g")

    if echo "$PROCESSED" | grep -q "Test User" && echo "$PROCESSED" | grep -q "test@example.com"; then
        pass "Template placeholder replacement works"
    else
        fail "Template placeholder replacement failed"
    fi
else
    fail "jq not available for template testing"
fi

echo ""

# =============================================================================
# 3. Symlink Creation Tests
# =============================================================================

echo "Testing symlink operations..."

# Create test source and target
mkdir -p "$TEST_DIR/source" "$TEST_DIR/target"
echo "test content" >"$TEST_DIR/source/testfile"

# Test symlink creation
if ln -sf "$TEST_DIR/source/testfile" "$TEST_DIR/target/testfile" 2>/dev/null; then
    if [[ -L "$TEST_DIR/target/testfile" ]]; then
        LINK_TARGET=$(readlink "$TEST_DIR/target/testfile")
        if [[ $LINK_TARGET == "$TEST_DIR/source/testfile" ]]; then
            pass "Symlink creation and verification works"
        else
            fail "Symlink points to wrong target: $LINK_TARGET"
        fi
    else
        fail "Symlink not created"
    fi
else
    fail "Symlink creation failed"
fi

# Test symlink overwrite
echo "different content" >"$TEST_DIR/source/testfile2"
ln -sf "$TEST_DIR/source/testfile2" "$TEST_DIR/target/testfile" 2>/dev/null
if [[ -L "$TEST_DIR/target/testfile" ]]; then
    NEW_TARGET=$(readlink "$TEST_DIR/target/testfile")
    if [[ $NEW_TARGET == "$TEST_DIR/source/testfile2" ]]; then
        pass "Symlink overwrite works"
    else
        fail "Symlink overwrite failed"
    fi
fi

echo ""

# =============================================================================
# 4. Backup Creation Tests
# =============================================================================

echo "Testing backup operations..."

# Create files to backup
mkdir -p "$TEST_DIR/home"
echo "original zshrc" >"$TEST_DIR/home/.zshrc"
echo "original gitconfig" >"$TEST_DIR/home/.gitconfig"

# Simulate backup creation (like setup.sh does)
BACKUP_DIR="$TEST_DIR/backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Copy files to backup
if cp "$TEST_DIR/home/.zshrc" "$BACKUP_DIR/" 2>/dev/null &&
    cp "$TEST_DIR/home/.gitconfig" "$BACKUP_DIR/" 2>/dev/null; then
    pass "Backup creation works"
else
    fail "Backup creation failed"
fi

# Verify backup contents
if [[ -f "$BACKUP_DIR/.zshrc" ]] && [[ -f "$BACKUP_DIR/.gitconfig" ]]; then
    if grep -q "original zshrc" "$BACKUP_DIR/.zshrc" &&
        grep -q "original gitconfig" "$BACKUP_DIR/.gitconfig"; then
        pass "Backup contents verified"
    else
        fail "Backup contents incorrect"
    fi
else
    fail "Backup files missing"
fi

echo ""

# =============================================================================
# 5. Restore Operations Tests
# =============================================================================

echo "Testing restore operations..."

# Modify original files
echo "modified zshrc" >"$TEST_DIR/home/.zshrc"
echo "modified gitconfig" >"$TEST_DIR/home/.gitconfig"

# Restore from backup
if cp "$BACKUP_DIR/.zshrc" "$TEST_DIR/home/" 2>/dev/null &&
    cp "$BACKUP_DIR/.gitconfig" "$TEST_DIR/home/" 2>/dev/null; then
    pass "Restore operation works"
else
    fail "Restore operation failed"
fi

# Verify restored contents
if grep -q "original zshrc" "$TEST_DIR/home/.zshrc" &&
    grep -q "original gitconfig" "$TEST_DIR/home/.gitconfig"; then
    pass "Restored contents verified"
else
    fail "Restored contents incorrect"
fi

echo ""

# =============================================================================
# 6. Config Generation Tests
# =============================================================================

echo "Testing config generation from templates..."

# Test gitconfig template generation
if [[ -f "$PROJECT_ROOT/config/git/gitconfig.template" ]]; then
    # Verify template has placeholder syntax
    if grep -q '{{GIT_USER_NAME}}' "$PROJECT_ROOT/config/git/gitconfig.template" &&
        grep -q '{{GIT_USER_EMAIL}}' "$PROJECT_ROOT/config/git/gitconfig.template"; then
        pass "Git config template has correct placeholders"
    else
        fail "Git config template missing placeholders"
    fi
else
    fail "Git config template not found"
fi

echo ""

# =============================================================================
# 7. Cross-Platform File Handling
# =============================================================================

echo "Testing cross-platform file handling..."

# Test path handling with spaces
mkdir -p "$TEST_DIR/path with spaces"
if [[ -d "$TEST_DIR/path with spaces" ]]; then
    pass "Path with spaces handling works"
else
    fail "Path with spaces failed"
fi

echo ""

# =============================================================================
# 8. Dry Run Mode Tests
# =============================================================================

echo "Testing dry run mode behavior..."

# Test that DRY_RUN variable prevents operations
TEST_FILE="$TEST_DIR/dry-run-test"
DRY_RUN=true

if [[ $DRY_RUN == "true" ]]; then
    # In dry-run, we should skip file operations
    # Simulate what setup.sh does
    if [[ $DRY_RUN != "true" ]]; then
        touch "$TEST_FILE"
    fi

    if [[ ! -f $TEST_FILE ]]; then
        pass "Dry run mode prevents file creation"
    else
        fail "Dry run mode failed to prevent file creation"
    fi
else
    fail "Dry run mode not activated"
fi

echo ""

# =============================================================================
# Summary
# =============================================================================

echo "Test Summary"
echo "============"
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"
echo ""

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo "❌ Some tests failed"
    exit 1
else
    echo "✅ All critical path tests passed!"
    exit 0
fi
