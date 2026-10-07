#!/bin/sh
# Git clean/smudge filter for agents/claude/settings.json (see .gitattributes).
#
# ~/.claude/settings.json is symlinked into this public repo, but some of it
# doesn't belong in git:
#   - autoMode.environment: private org details. Claude Code only reads
#     autoMode from this user-level file, so it can't live anywhere else.
#   - Orca's hooks + statusLine: machine-generated, and Orca rewrites them on
#     every launch, so tracking them is pure noise.
# The live file keeps both; git never sees them:
#   clean:  strip them on the way into git, saving a copy to $PRIVATE
#   smudge: restore them from $PRIVATE on checkout, so pulls don't drop them
set -eu

PRIVATE="${CLAUDE_SETTINGS_PRIVATE_FILE:-$HOME/.claude/settings.private.json}"
input="$(cat)"

# Matches commands Orca manages (see createManagedCommandMatcher in Orca).
ORCA='def orca: tostring | test("agent-hooks/claude-(hook|statusline)");
def orca_def: any(.hooks[]?; .command | orca);'

case "${1-}" in
  clean)
    private="$(printf '%s\n' "$input" | jq "$ORCA"'
      {
        environment: .autoMode.environment,
        hooks: ((.hooks // {}) | map_values(map(select(orca_def))) | with_entries(select(.value != []))),
        statusLine: ((.statusLine | select(.command | orca)) // null)
      } | with_entries(select(.value != null and .value != {}))')"
    if [ -n "$private" ] && [ "$private" != "{}" ]; then
      printf '%s\n' "$private" > "$PRIVATE.tmp" && mv "$PRIVATE.tmp" "$PRIVATE"
    fi
    printf '%s\n' "$input" | jq "$ORCA"'
      del(.autoMode.environment)
      | if .hooks then
          .hooks |= (map_values(map(select(orca_def | not))) | with_entries(select(.value != [])))
          | if .hooks == {} then del(.hooks) else . end
        else . end
      | if (.statusLine.command // "" | orca) then del(.statusLine) else . end'
    ;;
  smudge)
    if [ -s "$PRIVATE" ]; then
      printf '%s\n' "$input" | jq --slurpfile p "$PRIVATE" '
        $p[0] as $p
        | if $p.environment then .autoMode.environment = $p.environment else . end
        | reduce (($p.hooks // {}) | to_entries[]) as $e (.; .hooks[$e.key] = (.hooks[$e.key] // []) + $e.value)
        | if $p.statusLine then .statusLine = $p.statusLine else . end'
    else
      printf '%s\n' "$input"
    fi
    ;;
  *)
    echo "usage: $0 clean|smudge" >&2
    exit 2
    ;;
esac
