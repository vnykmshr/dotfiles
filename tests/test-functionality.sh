#!/usr/bin/env bash
# Functionality tests for dotfiles
# Validates that key features work after installation

set -eo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

PASSED=0
FAILED=0

pass() {
    echo "ok $1"
    PASSED=$((PASSED + 1))
}
fail() {
    echo "FAIL $1"
    FAILED=$((FAILED + 1))
}

# Zsh syntax validation for all config files
echo "Zsh config syntax..."
for f in "$PROJECT_ROOT"/config/zsh/*; do
    [ -f "$f" ] || continue
    name=$(basename "$f")
    # Skip templates and local files
    [[ $name == *.template ]] && continue
    [[ $name == *.local ]] && continue
    [[ $name == exports.local ]] && continue
    if zsh -n "$f" 2>/dev/null; then
        pass "syntax: $name"
    else
        fail "syntax: $name"
    fi
done

# CLI tools init syntax
if zsh -n "$PROJECT_ROOT/config/cli-tools/init" 2>/dev/null; then
    pass "syntax: cli-tools/init"
else
    fail "syntax: cli-tools/init"
fi

# Shell script syntax
echo ""
echo "Shell script syntax..."
for f in "$PROJECT_ROOT"/bin/*; do
    [ -f "$f" ] || continue
    name=$(basename "$f")
    if bash -n "$f" 2>/dev/null; then
        pass "syntax: bin/$name"
    else
        fail "syntax: bin/$name"
    fi
done

# Workflow scripts
if bash -n "$PROJECT_ROOT/config/workflow/git-helpers" 2>/dev/null; then
    pass "syntax: workflow/git-helpers"
else
    fail "syntax: workflow/git-helpers"
fi

# Zsh config loads without error
echo ""
echo "Config loading..."
if zsh -c "source $PROJECT_ROOT/config/zsh/zshrc" 2>/dev/null; then
    pass "zshrc loads"
else
    fail "zshrc loads"
fi

# Key aliases exist after loading
echo ""
echo "Alias checks..."
for alias_check in "gs:git status" "rm:rm -i" "..:"; do
    name="${alias_check%%:*}"
    expected="${alias_check#*:}"
    if zsh -c "source $PROJECT_ROOT/config/zsh/zshrc 2>/dev/null; alias $name" 2>/dev/null | grep -q "$expected"; then
        pass "alias: $name"
    else
        fail "alias: $name"
    fi
done

# Key functions exist
echo ""
echo "Function checks..."
for func in mkcd backup extract gitlog gsl reload status; do
    if zsh -c "source $PROJECT_ROOT/config/zsh/zshrc 2>/dev/null; type $func" 2>/dev/null | grep -q function; then
        pass "function: $func"
    else
        fail "function: $func"
    fi
done

# No hardcoded user paths in tracked config
echo ""
echo "Portability checks..."
if grep -r '/Users/vmx\|/home/vmx' "$PROJECT_ROOT/config/zsh/" --include="*" -l 2>/dev/null | grep -v '.local$' | grep -v '.local.template$'; then
    fail "hardcoded user paths in tracked files"
else
    pass "no hardcoded user paths"
fi

# Summary
echo ""
echo "Results: $PASSED passed, $FAILED failed"
[ "$FAILED" -eq 0 ]
