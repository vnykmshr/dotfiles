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

# A clean start prints nothing to stderr (repo as a real dir, no ~/.dotfiles link)
clean_home=$(mktemp -d)
startup_err=$(env -i HOME="$clean_home" TERM=xterm PATH=/usr/bin:/bin zsh -c "DOTFILES=$PROJECT_ROOT; source $PROJECT_ROOT/config/zsh/zshrc" 2>&1 >/dev/null) || true
rm -rf "$clean_home"
if [[ -z $startup_err ]]; then
    pass "zshrc start: no stderr"
else
    fail "zshrc start: no stderr: $startup_err"
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

# psg runs (the ps alias must not expand inside it)
if zsh -c "$ZSH_SOURCE 2>/dev/null; eval 'psg zsh'" >/dev/null 2>&1; then
    pass "alias: psg runs"
else
    fail "alias: psg runs"
fi

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

# setup-personal-config creates personal.local with EDITOR unset
pc_dir=$(mktemp -d)
mkdir -p "$pc_dir/config/zsh"
cp "$PROJECT_ROOT/config/zsh/personal.local.template" "$pc_dir/config/zsh/"
if env -u EDITOR DOTFILES="$pc_dir" "$PROJECT_ROOT/bin/setup-personal-config" </dev/null >/dev/null 2>&1 &&
    [[ -f $pc_dir/config/zsh/personal.local ]]; then
    pass "setup-personal-config: works without EDITOR"
else
    fail "setup-personal-config: works without EDITOR"
fi
# Overwrite backs up outside the repo (make clean deletes *.backup.*; repo is public)
pc_home=$(mktemp -d)
echo "mine" >"$pc_dir/config/zsh/personal.local"
printf 'y\n' | env -u EDITOR HOME="$pc_home" DOTFILES="$pc_dir" "$PROJECT_ROOT/bin/setup-personal-config" >/dev/null 2>&1 || true
if [[ $(cat "$pc_home"/.dotfiles-backup-*/personal.local 2>/dev/null) == mine ]] &&
    [[ -z $(find "$pc_dir" -name 'personal.local.backup*') ]]; then
    pass "setup-personal-config: backup outside the repo"
else
    fail "setup-personal-config: backup outside the repo"
fi
rm -rf "$pc_dir" "$pc_home"

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
