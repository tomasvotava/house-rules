#!/usr/bin/env bash
# Shared state detection for the agentic identity hooks.
# Sourced by identity-context.sh and identity-guard.sh; not executable on its own.

# Echoes exactly one of: assumed | allowed | missing
agentic_identity_state() {
    if [ "${AGENTIC_IDENTITY_ASSUMED:-}" = "1" ]; then
        printf 'assumed'
    elif [ "${AGENTIC_IDENTITY_ALLOW_MISSING:-}" = "1" ]; then
        printf 'allowed'
    else
        printf 'missing'
    fi
}

# Echoes the identity git would stamp on a commit right now, as "Name <email>".
agentic_identity_who() {
    local name email
    name="$(git config --get user.name 2>/dev/null || true)"
    email="$(git config --get user.email 2>/dev/null || true)"
    printf '%s <%s>' "${name:-unset}" "${email:-unset}"
}

# Echoes the operator's own recovery instruction, or a generic one. The command
# that provisions an identity is site-specific, so the operator supplies it via
# AGENTIC_IDENTITY_HINT rather than this plugin guessing at a name.
agentic_identity_hint() {
    printf '%s' "${AGENTIC_IDENTITY_HINT:-Exit, export AGENTIC_IDENTITY_ASSUMED=1 along with whatever provisions the identity, and start claude again.}"
}
