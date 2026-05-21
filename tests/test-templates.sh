#!/usr/bin/env bash
# Template processor regression tests.
# Guards against the bugs documented in docs/decisions/0001-template-processor-hardening.md:
#   - literal $HOME in generated configs (issue #4)
#   - sed metacharacter mishandling (& \1 |)
#   - shell injection via eval over jq output

set -eo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_DIR="$(mktemp -d -t dotfiles-tpl-test-XXXXXX)"
INJECTION_MARKER="$TEST_DIR/PWNED"

TESTS_PASSED=0
TESTS_FAILED=0

# shellcheck disable=SC2317
cleanup() { rm -rf "$TEST_DIR"; }
trap cleanup EXIT

pass() { echo "ok $1"; TESTS_PASSED=$((TESTS_PASSED + 1)); }
fail() { echo "FAIL $1: $2"; TESTS_FAILED=$((TESTS_FAILED + 1)); }

assert_eq() {
    local label="$1" expected="$2" actual="$3"
    if [[ $actual == "$expected" ]]; then
        pass "$label"
    else
        fail "$label" "expected '$expected', got '$actual'"
    fi
}

assert_contains() {
    local label="$1" needle="$2" haystack="$3"
    if [[ $haystack == *"$needle"* ]]; then
        pass "$label"
    else
        fail "$label" "missing '$needle' in output"
    fi
}

assert_not_contains() {
    local label="$1" needle="$2" haystack="$3"
    if [[ $haystack != *"$needle"* ]]; then
        pass "$label"
    else
        fail "$label" "unexpected '$needle' in output"
    fi
}

# Build fixture DOTFILES_DIR mirroring the real layout
mkdir -p "$TEST_DIR/config/ssh" "$TEST_DIR/config/git" "$TEST_DIR/config/zsh"
cp "$PROJECT_ROOT/config/ssh/config.template"        "$TEST_DIR/config/ssh/"
cp "$PROJECT_ROOT/config/git/gitconfig.template"     "$TEST_DIR/config/git/"
cp "$PROJECT_ROOT/config/zsh/exports.local.template" "$TEST_DIR/config/zsh/"

# Adversarial config.json:
# - $HOME prefix to exercise normalization (commit 2)
# - $(touch ...) to detect any surviving shell eval (commit 1)
# - & in name to detect sed backreference mishandling
# - | in path to detect sed delimiter conflict
# - \1 to detect sed backref interpretation
# - ' to detect quote breakage
cat > "$TEST_DIR/config.json" <<JSON
{
  "user": {
    "name": "Tom & Jerry \$(touch $INJECTION_MARKER)",
    "email": "user'with'quote@example.com",
    "editor": "nvim",
    "browser": "open",
    "terminal": "Terminal"
  },
  "git":  { "signing_key": "\$HOME/.ssh/key.pub", "gpg_sign": false },
  "ssh": {
    "keys": {
      "github":   "~/.ssh/id_ed25519",
      "gitlab":   "\$HOME/.ssh/id_ed25519",
      "personal": "/abs/with|pipe/key",
      "work":     "/abs/with\\\\1backref/key",
      "local":    "~/.ssh/id_ed25519"
    },
    "servers": {
      "personal":  { "alias": "my-server",   "host": "ex.com",      "user": "u", "port": 22 },
      "work":      { "alias": "work-server", "host": "work.ex.com", "user": "u", "port": 22 },
      "local_dev": { "host": "localhost",    "user": "u" }
    }
  },
  "environment": {
    "workspace_dir":    "\$HOME/work",
    "projects_dir":     "~/proj",
    "personal_bin_dir": "/abs/bin",
    "pager":            "less"
  },
  "development": {
    "node":   { "npm_prefix": "~/.npm-global" },
    "python": { "path": "" },
    "go":     { "path": "~/go" },
    "rust":   { "cargo_home": "~/.cargo" }
  }
}
JSON

# Source setup.sh — the source-guard prevents main from running. DOTFILES_DIR
# resolves to the real repo at source time (so lib/* are loaded correctly), then
# we point it at the fixture for the function calls that read config.json and
# write generated files.
export SKIP_PACKAGES=true
# shellcheck source=/dev/null
source "$PROJECT_ROOT/install/setup.sh"
# Exported so the sourced functions (get_config_value, process_*_template) pick
# up the fixture path. Shellcheck can't see the cross-source usage.
export DOTFILES_DIR="$TEST_DIR"

# --- get_config_value normalization (commit 2) ---
v=$(get_config_value '.ssh.keys.github' 'DEFAULT')
assert_eq "get_config_value: ~/ normalized to abs" "$HOME/.ssh/id_ed25519" "$v"

v=$(get_config_value '.ssh.keys.gitlab' 'DEFAULT' 2>/dev/null)
assert_eq "get_config_value: \$HOME normalized to abs" "$HOME/.ssh/id_ed25519" "$v"

v=$(get_config_value '.ssh.keys.personal' 'DEFAULT')
assert_eq "get_config_value: absolute path untouched" "/abs/with|pipe/key" "$v"

v=$(get_config_value '.ssh.keys.nonexistent' 'FALLBACK')
assert_eq "get_config_value: fallback for missing key" "FALLBACK" "$v"

# Warning fires on $HOME (route stderr to a temp file to inspect)
warn_capture=$(get_config_value '.git.signing_key' 'DEFAULT' 2>&1 >/dev/null)
assert_contains "log_warn fires on \$HOME" "uses \$HOME" "$warn_capture"

# Warning does NOT fire on ~/
warn_capture=$(get_config_value '.ssh.keys.github' 'DEFAULT' 2>&1 >/dev/null)
assert_not_contains "no warn on ~/" "uses \$HOME" "$warn_capture"

# --- process_template_generic literal-string semantics (commit 1) ---
adv_template="$TEST_DIR/adv.tpl"
adv_output="$TEST_DIR/adv.out"
cat > "$adv_template" <<'TPL'
name = {{NAME}}
path = {{PATH}}
ref  = {{REF}}
TPL

process_template_generic "$adv_template" "$adv_output" "adversarial fixture" \
    "NAME" 'Tom & Jerry' \
    "PATH" '/with|pipe/key' \
    "REF" '\1backref' >/dev/null

out=$(cat "$adv_output")
assert_contains "& preserved verbatim"      "Tom & Jerry"      "$out"
assert_contains "| preserved verbatim"      "/with|pipe/key"   "$out"
assert_contains "\\1 preserved verbatim"    "\\1backref"       "$out"
assert_not_contains "no leftover placeholder" "{{" "$out"

# --- End-to-end process_templates against fixture ---
# process_gitconfig_template prompts interactively if name/email look default.
# Our fixture supplies non-default values so prompts are skipped.
process_ssh_template >/dev/null 2>&1
process_gitconfig_template >/dev/null 2>&1
process_zsh_exports_template >/dev/null 2>&1

ssh_out="$TEST_DIR/config/ssh/config"
git_out="$TEST_DIR/config/git/gitconfig"
zsh_out="$TEST_DIR/config/zsh/exports.local"

if [[ -f $ssh_out ]]; then
    ssh_content=$(cat "$ssh_out")
    assert_not_contains "ssh: no literal \$HOME" '$HOME' "$ssh_content"
    assert_not_contains "ssh: no leftover {{" "{{" "$ssh_content"
    # IdentityFile lines should now be absolute paths starting with /
    if grep -E "^[[:space:]]*IdentityFile[[:space:]]+/" "$ssh_out" >/dev/null; then
        pass "ssh: IdentityFile uses absolute path"
    else
        fail "ssh: IdentityFile not absolute" "$(grep IdentityFile "$ssh_out" | head -1)"
    fi
else
    fail "ssh config generated" "$ssh_out missing"
fi

if [[ -f $git_out ]]; then
    git_content=$(cat "$git_out")
    assert_not_contains "git: no literal \$HOME" '$HOME' "$git_content"
    assert_not_contains "git: no leftover {{" "{{" "$git_content"
    assert_contains    "git: name with & preserved" "Tom & Jerry" "$git_content"
else
    fail "git config generated" "$git_out missing"
fi

if [[ -f $zsh_out ]]; then
    # Comments in exports.local.template intentionally retain {{KEY}} for keys
    # callers don't supply (GITHUB_TOKEN, OPENAI_API_KEY, etc.). Only check
    # uncommented lines for leftover placeholders.
    zsh_active=$(grep -v '^[[:space:]]*#' "$zsh_out" || true)
    assert_not_contains "zsh: no leftover {{ in active lines" "{{" "$zsh_active"
    assert_contains    "zsh: WORKSPACE is absolute" "export WORKSPACE=\"$HOME/work\"" "$(cat "$zsh_out")"
    assert_contains    "zsh: PROJECTS is absolute" "export PROJECTS=\"$HOME/proj\"" "$(cat "$zsh_out")"
else
    fail "zsh exports generated" "$zsh_out missing"
fi

# --- Command injection guard ---
if [[ -e $INJECTION_MARKER ]]; then
    fail "command injection prevented" "marker file $INJECTION_MARKER was created — shell eval still happening"
else
    pass "command injection prevented (no \$() execution)"
fi

echo
echo "Template tests: $TESTS_PASSED passed, $TESTS_FAILED failed"
if (( TESTS_FAILED > 0 )); then
    exit 1
fi
