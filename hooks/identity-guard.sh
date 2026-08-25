#!/usr/bin/env bash
# PreToolUse(Bash) hook: refuse git and GitHub writes when no identity was assumed.
#
# The SessionStart message already tells the agent to stop; this is the net for
# when it doesn't. Attribution is unrecoverable once a commit is pushed, so the
# patterns below deliberately over-match rather than risk letting a write through.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=identity-state.sh
. "${SCRIPT_DIR}/identity-state.sh"

[ "$(agentic_identity_state)" = "missing" ] || exit 0

# The hook payload is JSON, but deciding whether a write verb appears anywhere in
# it needs no parsing — and scanning the raw text keeps this dependency-free on
# machines without jq or python. Dropping `-c cfg` and `-C path` pairs first lets
# the git pattern below assume only option tokens sit between git and its verb.
payload="$(cat)"
scan="$(printf '%s' "$payload" | sed -E 's/(^|[[:space:]])-[cC][[:space:]]+[^[:space:]]+//g')"

GIT_WRITE='(^|[^[:alnum:]_./-])git([[:space:]]+-[^[:space:]]+)*[[:space:]]+(commit|commit-tree|push|tag|merge|rebase|cherry-pick|revert|am|notes)([^[:alnum:]_-]|$)'
GH_WRITE='(^|[^[:alnum:]_./-])gh([[:space:]]+-[^[:space:]]+)*[[:space:]]+[a-z-]+([[:space:]]+-[^[:space:]]+)*[[:space:]]+(create|edit|comment|review|merge|close|reopen|ready|delete|rename|sync|fork|transfer|archive|lock|unlock|pin|unpin|set|remove|add|run|upload|develop|resolve)([^[:alnum:]_-]|$)'
GH_API_WRITE='(^|[^[:alnum:]_./-])gh[[:space:]]+api[^|;&]*[[:space:]](-X|--method)[[:space:]=]*(POST|PUT|PATCH|DELETE)'
GH_API_FIELD='(^|[^[:alnum:]_./-])gh[[:space:]]+api[^|;&]*[[:space:]](-f|-F|--field|--raw-field)[[:space:]=]'

for pattern in "$GIT_WRITE" "$GH_WRITE" "$GH_API_WRITE" "$GH_API_FIELD"; do
    if printf '%s' "$scan" | grep -Eq "$pattern"; then
        cat >&2 <<EOF
BLOCKED: no agent identity is active, so this write would most likely be attributed to the
operator's own account — making them the author of code they are meant to review.

Stop and tell the operator: $(agentic_identity_hint) If this repository should use their own
account instead, they can re-run with AGENTIC_IDENTITY_ALLOW_MISSING=1.

Do not work around this. Do not export the identity variables, do not pass --author or
-c user.name=, and do not reach for another credential. Read-only git and gh commands still
work; use them while you wait.
EOF
        exit 2
    fi
done

exit 0
