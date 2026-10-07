#!/bin/sh
# Git clean/smudge filter for agents/claude/settings.json (see .gitattributes).
#
# autoMode.environment describes private org infrastructure, but Claude Code
# only reads autoMode from ~/.claude/settings.json, which is symlinked into
# this public repo. So the live file keeps the block, and git never sees it:
#   clean:  strip it on the way into git, saving a copy to $PRIVATE
#   smudge: restore it from $PRIVATE on checkout, so pulls don't drop it
set -eu

PRIVATE="${CLAUDE_AUTOMODE_ENV_FILE:-$HOME/.claude/automode-environment.json}"
input="$(cat)"

case "${1-}" in
  clean)
    env_json="$(printf '%s\n' "$input" | jq '.autoMode.environment // empty')"
    if [ -n "$env_json" ]; then
      printf '%s\n' "$env_json" > "$PRIVATE.tmp" && mv "$PRIVATE.tmp" "$PRIVATE"
    fi
    printf '%s\n' "$input" | jq 'del(.autoMode.environment)'
    ;;
  smudge)
    if [ -s "$PRIVATE" ]; then
      printf '%s\n' "$input" | jq --slurpfile env "$PRIVATE" '.autoMode.environment = $env[0]'
    else
      printf '%s\n' "$input"
    fi
    ;;
  *)
    echo "usage: $0 clean|smudge" >&2
    exit 2
    ;;
esac
