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

# Bash syntax for every tracked bash script
echo ""
echo "Shell script syntax..."
while IFS= read -r -d '' rel; do
    f="$PROJECT_ROOT/$rel"
    [[ -f $f ]] || continue
    [[ $rel == *.sh ]] || head -1 "$f" | grep -qE '^#!.*[/ ]bash$' || continue
    if bash -n "$f" 2>/dev/null; then
        pass "syntax: $rel"
    else
        fail "syntax: $rel"
    fi
done < <(git -C "$PROJECT_ROOT" ls-files -z)

# Zsh config loads without error
# Set DOTFILES so zshrc can find modules (no ~/.dotfiles symlink in CI)
echo ""
echo "Config loading..."
ZSH_SOURCE="DOTFILES=$PROJECT_ROOT source $PROJECT_ROOT/config/zsh/zshrc"
# Allow non-zero exit from warnings (e.g., missing ~/.dotfiles symlink)
# but verify aliases/functions loaded (tested below)
if zsh -c "$ZSH_SOURCE; type load_config" 2>/dev/null | grep -q function; then
    pass "zshrc loads"
else
    fail "zshrc loads"
fi

# Key aliases exist after loading
echo ""
echo "Alias checks..."
for alias_check in "gs:git status" "..:"; do
    name="${alias_check%%:*}"
    expected="${alias_check#*:}"
    if zsh -c "$ZSH_SOURCE 2>/dev/null; alias $name" 2>/dev/null | grep -q "$expected"; then
        pass "alias: $name"
    else
        fail "alias: $name"
    fi
done

# Key functions exist
echo ""
echo "Function checks..."
for func in mkcd extract gsl reload; do
    if zsh -c "$ZSH_SOURCE 2>/dev/null; type $func" 2>/dev/null | grep -q function; then
        pass "function: $func"
    else
        fail "function: $func"
    fi
done

# bin/* scripts are reachable: no alias or function shadows one
echo ""
echo "bin/ shadowing checks..."
bin_names=()
for f in "$PROJECT_ROOT"/bin/*; do
    [[ -f $f ]] && bin_names+=("$(basename "$f")")
done
shadowed=$(zsh -c "$ZSH_SOURCE 2>/dev/null; for n in \"\$@\"; do whence -w \"\$n\"; done" zsh "${bin_names[@]}" 2>/dev/null | grep -E ': (alias|function)$' || true)
if [[ -z $shadowed ]]; then
    pass "bin/ names not shadowed (${#bin_names[@]} scripts)"
else
    fail "bin/ names shadowed: $shadowed"
fi

# Module keybindings survive into the final keymap
echo ""
echo "Keybinding checks..."
if [[ $OSTYPE == darwin* ]]; then word_left='^[[1;3D'; else word_left='^[[1;5D'; fi
if EDITOR=nvim zsh -c "$ZSH_SOURCE 2>/dev/null; bindkey '$word_left'" 2>/dev/null | grep -q backward-word; then
    pass "keybinding: word left"
else
    fail "keybinding: word left"
fi

# No hardcoded user home paths in tracked files
echo ""
echo "Portability checks..."
user_paths=$(git -C "$PROJECT_ROOT" grep -nE '/(Users|home)/[A-Za-z0-9._-]+' || true)
if [[ -z $user_paths ]]; then
    pass "no hardcoded user paths"
else
    fail "hardcoded user paths: $user_paths"
fi

# Summary
echo ""
echo "Results: $PASSED passed, $FAILED failed"
[ "$FAILED" -eq 0 ]
