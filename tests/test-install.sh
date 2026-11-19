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
copy_repo() {
    local dest="$1" f
    local files=()
    mkdir -p "$dest"
    while IFS= read -r -d '' f; do
        [[ -e "$PROJECT_ROOT/$f" || -L "$PROJECT_ROOT/$f" ]] && files+=("$f")
    done < <(git -C "$PROJECT_ROOT" ls-files -z --cached --others --exclude-standard)
    (cd "$PROJECT_ROOT" && tar cf - "${files[@]}") | (cd "$dest" && tar xf -)
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

# Run a command with the test HOME and the stubs first on PATH.
in_home() {
    local home="$1"
    shift
    env HOME="$home" PATH="$STUBS:$PATH" CI=1 SKIP_PACKAGES=true "$@" </dev/null
}

links_in() { (cd "$1" && find . -type l | sed 's|^\./||' | sort); }
dangling_in() { find "$1" -type l ! -exec test -e {} \; -print; }

# Install
REPO="$WORK/repo"
HOME_DIR="$WORK/home"
copy_repo "$REPO"
mkdir -p "$HOME_DIR"

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

# Uninstall
if printf 'y\n' | env HOME="$HOME_DIR" make -s -C "$REPO" uninstall >"$WORK/uninstall.log" 2>&1; then
    pass "uninstall exits 0"
else
    fail "uninstall exits 0" "$(cat "$WORK/uninstall.log")"
fi
assert_eq "uninstall: no links left" "" "$(links_in "$HOME_DIR")"

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

echo
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"
[[ $TESTS_FAILED -eq 0 ]]
