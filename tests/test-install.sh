#!/usr/bin/env bash
# Install, reinstall, uninstall and dry-run into a temp HOME.
# Install writes generated configs into the repo, so it runs on a copy of the
# tracked files. Commands with system side effects are stubbed on PATH and
# logged to calls.log.

set -eo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d -t dotfiles-install-test-XXXXXX)"

TESTS_PASSED=0
TESTS_FAILED=0

# shellcheck disable=SC2329
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT

pass() {
    echo "ok $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}
fail() {
    echo "FAIL $1: $2"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

assert_eq() {
    local label="$1" expected="$2" actual="$3"
    if [[ $actual == "$expected" ]]; then
        pass "$label"
    else
        fail "$label" "expected '$expected', got '$actual'"
    fi
}

EXPECTED_LINKS=".config/nvim
.dotfiles
.gitconfig
.gitignore_global
.ssh/config
.tmux.conf
.zshenv
.zshrc"

# Copy tracked and untracked-unignored files that exist on disk.
# A second argument "no-config" skips writing config.json.
copy_repo() {
    local dest="$1" config="${2:-}" f
    local files=()
    mkdir -p "$dest"
    while IFS= read -r -d '' f; do
        [[ -e "$PROJECT_ROOT/$f" || -L "$PROJECT_ROOT/$f" ]] && files+=("$f")
    done < <(git -C "$PROJECT_ROOT" ls-files -z --cached --others --exclude-standard)
    (cd "$PROJECT_ROOT" && tar cf - "${files[@]}") | (cd "$dest" && tar xf -)
    [[ $config == "no-config" ]] && return 0
    jq '.user.name = "Test User" | .user.email = "test@example.com"' \
        "$dest/config.json.example" >"$dest/config.json"
}

STUBS="$WORK/stubs"
CALLS="$WORK/calls.log"
mkdir -p "$STUBS"
for cmd in brew apt apt-get dnf pacman sudo chsh defaults killall curl tmutil; do
    printf '#!/bin/sh\necho "%s $*" >>"%s"\n' "$cmd" "$CALLS" >"$STUBS/$cmd"
    chmod +x "$STUBS/$cmd"
done

# Run a command with the test HOME and the stubs first on PATH. USER is unset:
# minimal containers and cron run without it.
in_home() {
    local home="$1"
    shift
    env -u USER HOME="$home" PATH="$STUBS:$PATH" "$@" </dev/null
}

links_in() { (cd "$1" && find . -type l | sed 's|^\./||' | sort); }
dangling_in() { find "$1" -type l ! -exec test -e {} \; -print; }

# Install
REPO="$WORK/repo"
HOME_DIR="$WORK/home"
copy_repo "$REPO"
mkdir -p "$HOME_DIR"
: >"$CALLS"

if in_home "$HOME_DIR" "$REPO/install/setup.sh" >"$WORK/install1.log" 2>&1; then
    pass "install exits 0"
else
    fail "install exits 0" "see output below"
    cat "$WORK/install1.log"
fi
assert_eq "install: link set" "$EXPECTED_LINKS" "$(links_in "$HOME_DIR")"
assert_eq "install: no dangling links" "" "$(dangling_in "$HOME_DIR")"

gitconfig="$REPO/config/git/gitconfig"
if [[ -f $gitconfig ]]; then
    assert_eq "gitconfig: no leftover placeholder" "0" "$(grep -c '{{' "$gitconfig" || true)"
    assert_eq "gitconfig: user name filled" "1" "$(grep -c 'name = Test User' "$gitconfig" || true)"
    assert_eq "gitconfig: local include is last" \
        "path = ~/.dotfiles/config/git/gitconfig.local" \
        "$(grep -E '^[[:space:]]*path = ' "$gitconfig" | tail -1 | sed 's/^[[:space:]]*//')"
else
    fail "gitconfig generated" "missing $gitconfig"
fi

# Reinstall
if in_home "$HOME_DIR" "$REPO/install/setup.sh" >"$WORK/install2.log" 2>&1; then
    pass "reinstall exits 0"
else
    fail "reinstall exits 0" "see output below"
    cat "$WORK/install2.log"
fi
assert_eq "reinstall: link set unchanged" "$EXPECTED_LINKS" "$(links_in "$HOME_DIR")"
assert_eq "install: no package, shell or system commands" "" "$(cat "$CALLS")"

# Uninstall
if printf 'y\n' | env HOME="$HOME_DIR" make -s -C "$REPO" uninstall >"$WORK/uninstall.log" 2>&1; then
    pass "uninstall exits 0"
else
    fail "uninstall exits 0" "$(cat "$WORK/uninstall.log")"
fi
assert_eq "uninstall: no links left" "" "$(links_in "$HOME_DIR")"

# Forced install over real files, then restore them
RESTORE_REPO="$WORK/restore-repo"
RESTORE_HOME="$WORK/restore-home"
copy_repo "$RESTORE_REPO"
mkdir -p "$RESTORE_HOME/.config/nvim" "$RESTORE_HOME/.ssh"
echo "own zshrc" >"$RESTORE_HOME/.zshrc"
echo "own ssh" >"$RESTORE_HOME/.ssh/config"
echo "own nvim" >"$RESTORE_HOME/.config/nvim/init.lua"
repo_zshrc_before=$(cat "$RESTORE_REPO/config/zsh/zshrc")
in_home "$RESTORE_HOME" env FORCE=true "$RESTORE_REPO/install/setup.sh" >"$WORK/restore-install.log" 2>&1 || true
# A second install must not leave a newer, empty backup in front
in_home "$RESTORE_HOME" "$RESTORE_REPO/install/setup.sh" >/dev/null 2>&1 || true
assert_eq "backup: one per install that replaced files" "1" \
    "$(find "$RESTORE_HOME" -maxdepth 1 -name '.dotfiles-backup-*' | wc -l | tr -d ' ')"
if printf '1\n' | env HOME="$RESTORE_HOME" make -s -C "$RESTORE_REPO" restore >"$WORK/restore.log" 2>&1; then
    pass "restore exits 0"
else
    fail "restore exits 0" "$(cat "$WORK/restore.log")"
fi
assert_eq "restore: ~/.zshrc back" "own zshrc" "$(cat "$RESTORE_HOME/.zshrc" 2>/dev/null)"
assert_eq "restore: ~/.ssh/config back" "own ssh" "$(cat "$RESTORE_HOME/.ssh/config" 2>/dev/null)"
assert_eq "restore: ~/.config/nvim back" "own nvim" "$(cat "$RESTORE_HOME/.config/nvim/init.lua" 2>/dev/null)"
assert_eq "restore: repo files untouched" "$repo_zshrc_before" "$(cat "$RESTORE_REPO/config/zsh/zshrc")"
if printf '99\n' | env HOME="$RESTORE_HOME" make -s -C "$RESTORE_REPO" restore >/dev/null 2>&1; then
    fail "restore: unknown backup fails" "exited 0"
else
    pass "restore: unknown backup fails"
fi

# Dry run
DRY_REPO="$WORK/dry-repo"
DRY_HOME="$WORK/dry-home"
copy_repo "$DRY_REPO"
mkdir -p "$DRY_HOME"
: >"$CALLS"
if in_home "$DRY_HOME" env DRY_RUN=true "$DRY_REPO/install/setup.sh" >"$WORK/dry.log" 2>&1; then
    pass "dry run exits 0"
else
    fail "dry run exits 0" "see output below"
    cat "$WORK/dry.log"
fi
assert_eq "dry run: HOME untouched" "" "$(find "$DRY_HOME" -mindepth 1)"
assert_eq "dry run: no generated files" "" \
    "$(cd "$DRY_REPO" && ls config/git/gitconfig config/ssh/config config/zsh/exports.local 2>/dev/null)"
assert_eq "dry run: no stubbed commands called" "" "$(cat "$CALLS")"

# Repo cloned at ~/.dotfiles (the README layout), plain and forced
CLONE_HOME="$WORK/clone-home"
copy_repo "$CLONE_HOME/.dotfiles"
for mode in plain force; do
    force=false
    [[ $mode == force ]] && force=true
    if in_home "$CLONE_HOME" env FORCE="$force" "$CLONE_HOME/.dotfiles/install/setup.sh" >"$WORK/clone-$mode.log" 2>&1; then
        pass "clone at ~/.dotfiles, $mode: exits 0"
    else
        fail "clone at ~/.dotfiles, $mode: exits 0" "see output below"
        cat "$WORK/clone-$mode.log"
    fi
    assert_eq "clone at ~/.dotfiles, $mode: repo in place" "yes" \
        "$([[ -d $CLONE_HOME/.dotfiles && ! -L $CLONE_HOME/.dotfiles ]] && echo yes)"
    assert_eq "clone at ~/.dotfiles, $mode: link set" "$(grep -v '^\.dotfiles$' <<<"$EXPECTED_LINKS")" "$(links_in "$CLONE_HOME")"
done

# First run without config.json: creates it and stops before linking
NOCFG_REPO="$WORK/nocfg-repo"
NOCFG_HOME="$WORK/nocfg-home"
copy_repo "$NOCFG_REPO" no-config
mkdir -p "$NOCFG_HOME"
if in_home "$NOCFG_HOME" "$NOCFG_REPO/install/setup.sh" >"$WORK/nocfg.log" 2>&1; then
    fail "no config.json: exits non-zero" "exited 0"
else
    pass "no config.json: exits non-zero"
fi
assert_eq "no config.json: config.json created" "yes" "$([[ -f $NOCFG_REPO/config.json ]] && echo yes)"
assert_eq "no config.json: only ~/.dotfiles linked" ".dotfiles" "$(links_in "$NOCFG_HOME")"
assert_eq "no config.json: no dangling links" "" "$(dangling_in "$NOCFG_HOME")"

# Packages dry run: OS detected, nothing written
PKG_HOME="$WORK/pkg-home"
mkdir -p "$PKG_HOME"
if in_home "$PKG_HOME" env DRY_RUN=true "$DRY_REPO/install/setup.sh" --packages >"$WORK/pkg.log" 2>&1; then
    pass "packages dry run exits 0"
else
    fail "packages dry run exits 0" "see output below"
    cat "$WORK/pkg.log"
fi
assert_eq "packages dry run: OS detected" "0" "$(grep -c 'Unknown OS' "$WORK/pkg.log" || true)"
assert_eq "packages dry run: HOME untouched" "" "$(find "$PKG_HOME" -mindepth 1)"

echo
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"
[[ $TESTS_FAILED -eq 0 ]]
