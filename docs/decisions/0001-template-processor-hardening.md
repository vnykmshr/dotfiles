# 0001. Template Processor Hardening

**Status:** Accepted
**Date:** 2026-05-22
**Issue:** [#4](https://github.com/vnykmshr/dotfiles/issues/4)

## Context

`install/setup.sh` generates personalized config files (SSH, gitconfig, zsh exports) by substituting `{{PLACEHOLDER}}` tokens in template files with values read from `config.json`. The original implementation used `jq -r` to read values, then built and `eval`'d a `sed` command:

```bash
sed_cmd+="-e 's|{{${placeholder}}}|${value}|g' "
eval "sed $sed_cmd '$template_file' > '$output_file'"
```

This approach had three problems:

1. **Reported in #4:** `jq -r` returns values verbatim, so a config like `"ssh.keys.github": "$HOME/.ssh/id_ed25519"` produced literal `$HOME` in the generated SSH config. SSH does not expand `$HOME`, causing key-loading failures.

2. **Sed metacharacter mishandling.** Values containing `&` (sed substitution backreference), `\1`–`\9` (capture-group references), or `|` (the chosen delimiter) would be misinterpreted. A `user.name` of `"Tom & Jerry"` produces garbled output in the gitconfig.

3. **Latent shell-injection surface.** Because the sed command is constructed by string concatenation and passed to `eval`, a value containing `$(…)` or backticks executes as a shell command during template processing. The trust boundary becomes "anyone who can write to `config.json` runs arbitrary code as the user during setup." Practically low risk for a single-user dotfiles repo, but a sharp foot-gun.

## Decision

Three layered changes plus a regression test:

### 1. Replace `eval`+`sed` with pure-bash substitution

`process_template_generic` reads the template into a variable and uses bash parameter expansion (`${content//pattern/value}`) to substitute placeholders. No shell evaluation. No sed metacharacter interpretation.

### 2. Normalize `$HOME` and `~` prefixes in `get_config_value`

After `jq -r` returns a value, the function normalizes a leading `$HOME` or `~` to the absolute path. When `$HOME` normalization happens, a warning fires once per affected value to nudge users toward `~` syntax.

### 3. Use `~/…` in shipped example configs

`config.json.example` and `docs/templates/config.json.template` use `~/…` paths. New users never write `$HOME`; existing users see the warning above until they migrate.

### Regression test

A fixture-based test (`tests/test-templates.sh`) feeds an adversarial config containing `$HOME`, `&`, `|`, `\1`, `'`, and `$(touch …)` through `process_templates`, and diffs the outputs against expected content. The marker file written by `$(…)` must not exist post-run, proving no shell evaluation.

## Considered alternatives

- **JSON schema validator rejecting `$HOME`:** more code, doesn't address sed metachars or injection.
- **`envsubst` / `gomplate`:** new dependency for a tool that handles four templates.
- **Mutating user's `config.json` on disk to canonicalize paths:** rewrites user files without consent — bad UX.
- **Only fixing example files (no processor change):** leaves the injection surface and metachar bugs in place; doesn't help users with existing configs.

## Consequences

**Positive:**

- No `eval`, no shell-injection surface from `config.json` values.
- Tolerates any character a user might put in their name, email, or paths.
- Test-backed: regression fires on every `make test`.

**Negative:**

- Template is read fully into memory. Non-issue at <2KB per template.
- `install/setup.sh` grows a one-line guard around its `main` invocation so the regression test can source it. Standard pattern, low risk.

## References

- Plan: [`plan/template-processor-hardening.md`](../../plan/template-processor-hardening.md)
- Source thinking: `/pb-think` and `/pb-huddle` outputs (this PR's review thread)
