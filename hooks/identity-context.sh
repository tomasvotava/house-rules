#!/usr/bin/env bash
# SessionStart hook: state which git/GitHub identity this session writes under.
#
# Agents that discover a bot author line mid-task tend to read it as a bug and
# derail; stating it up front is cheaper than correcting it after the fact.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=identity-state.sh
. "${SCRIPT_DIR}/identity-state.sh"

who="$(agentic_identity_who)"
hint="$(agentic_identity_hint)"

case "$(agentic_identity_state)" in
assumed)
    read -r -d '' message <<EOF || true
Git and GitHub identity for this session: ${who}

This identity is yours. It was provisioned deliberately so that agent work is attributed to the
agent and the human operator reviews it as someone else's pull request. Commits you author, pull
requests you open, and review comments you post all carry this name by design.

It is not the operator's account, it is not an impersonation, and it is not a misconfiguration.
Seeing it on your own work is the expected result: do not report it as a problem, do not try to
correct it, and do not pause work over it.
EOF
    ;;
allowed)
    read -r -d '' message <<EOF || true
Git and GitHub identity for this session: ${who}

The dedicated agent identity is not active, and this session is explicitly permitted to run
without it (AGENTIC_IDENTITY_ALLOW_MISSING=1) — typically because this repository's remote does
not accept the agent account. Whatever identity is shown above is the operator's deliberate
choice for this repository, and your work is attributed to it on purpose.

That is the expected result here: do not report it as a problem and do not pause work over it.
EOF
    ;;
missing)
    read -r -d '' message <<EOF || true
AGENTIC IDENTITY NOT ACTIVE.

No agent identity was assumed for this session, so nothing guarantees your work is attributed
to the agent — git would currently stamp ${who}, by accident rather than by choice. Committing
under the operator's own account makes them the author of code they are meant to review, which
defeats the review entirely.

Git and GitHub write commands are blocked for the rest of this session. Reads still work.

Tell the operator this in your FIRST response, before anything else:

  This session has no agent identity. ${hint}
  If this repository should use their own account instead, re-run with
  AGENTIC_IDENTITY_ALLOW_MISSING=1.

Do not work around the block. Do not export the identity variables yourself, do not pass
--author or -c user.name=, and do not reach for another credential. A blocked action is a stop
signal, not an obstacle: wrong attribution cannot be undone by the reviewer.
EOF
    ;;
esac

# Claude Code reads the context out of JSON, so the message has to survive as a
# single string literal.
escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' \
    "$(escape_for_json "$message")"

exit 0
