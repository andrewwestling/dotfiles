#!/usr/bin/env zsh
# Regression check: install.sh seeds the skill lock but never overwrites it.
# Runs the real copy_if_absent and step 12 from install.sh, with HOME and the
# repo baseline in temp dirs. Stops short of `npx skills update`, so nothing is
# downloaded. Run: zsh tests/skill-lock.test.zsh
set -euo pipefail

INSTALLER="${0:A:h}/../install.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export HOME="$TMP/home"
DOTFILES_DIR="$TMP/repo"
BASELINE="$DOTFILES_DIR/agents/skill-lock.json"
LOCAL="$HOME/.agents/.skill-lock.json"
mkdir -p "$HOME" "${BASELINE:h}"

fail() { echo "FAIL: $1" >&2; exit 1; }

helper="$(sed -n '/^copy_if_absent() {/,/^}/p' "$INSTALLER")"
step="$(sed -n '/^# 12\. Agent skills/,/^if command -v npx/p' "$INSTALLER")"
# Without this end marker, the extract would run to the end of the installer.
[[ -n "$helper" && "${step##*$'\n'}" == "if command -v npx"* ]] \
  || fail "couldn't find the lock step in install.sh"
step="${step%$'\n'*}"

run_lock_step() {
  ( CHANGED=(); SKIPPED=(); eval "$helper"; eval "$step" ) >/dev/null
}

print -r -- '{"baseline":1}' > "$BASELINE"
run_lock_step
[[ -f "$LOCAL" ]] || fail "absent lock wasn't seeded"
cmp -s "$BASELINE" "$LOCAL" || fail "seeded lock differs from the baseline"
echo "ok: absent lock is seeded from the baseline"

print -r -- '{"local":"edited"}' > "$LOCAL"
print -r -- '{"baseline":2}' > "$BASELINE"
run_lock_step
[[ "$(<"$LOCAL")" == '{"local":"edited"}' ]] || fail "existing lock was overwritten"
echo "ok: existing lock is unchanged after the baseline changes"
