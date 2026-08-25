#!/usr/bin/env bash
# Exercises identity-guard.sh's command classification. Run: bash hooks/identity-guard.test.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GUARD="${SCRIPT_DIR}/identity-guard.sh"

failures=0

expect() {
    local want="$1" command="$2" got
    got="$(printf '{"tool_name":"Bash","tool_input":{"command":"%s"},"cwd":"/repo"}' "$command" \
        | env -u AGENTIC_IDENTITY_ASSUMED -u AGENTIC_IDENTITY_ALLOW_MISSING "$GUARD" >/dev/null 2>&1; printf '%s' "$?")"
    if [ "$got" != "$want" ]; then
        printf 'FAIL: expected exit %s, got %s for: %s\n' "$want" "$got" "$command" >&2
        failures=$((failures + 1))
    fi
}

expect_state() {
    local var="$1" want="$2" command="$3" got
    got="$(printf '{"tool_name":"Bash","tool_input":{"command":"%s"},"cwd":"/repo"}' "$command" \
        | env -u AGENTIC_IDENTITY_ASSUMED -u AGENTIC_IDENTITY_ALLOW_MISSING "$var=1" "$GUARD" >/dev/null 2>&1; printf '%s' "$?")"
    if [ "$got" != "$want" ]; then
        printf 'FAIL: with %s=1 expected exit %s, got %s for: %s\n' "$var" "$want" "$got" "$command" >&2
        failures=$((failures + 1))
    fi
}

# Blocked: writes that stamp or publish an author line.
expect 2 'git commit -m \"feat: x\"'
expect 2 'git push'
expect 2 'git push --force-with-lease origin HEAD'
expect 2 'cd sub && git commit --amend --no-edit'
expect 2 'git -C /other/repo push'
expect 2 'git -c user.name=someone commit -m x'
expect 2 'git tag -a v1.0.0 -m release'
expect 2 'git rebase master'
expect 2 'git cherry-pick abc1234'
expect 2 'gh pr create --fill'
expect 2 'gh pr comment 12 --body hi'
expect 2 'gh pr review 12 --approve'
expect 2 'gh issue create --title x'
expect 2 'gh release create v1.0.0'
expect 2 'gh workflow run ci.yml'
expect 2 'gh secret set TOKEN'
expect 2 'gh api -X POST /repos/o/r/issues'
expect 2 'gh api --method DELETE /repos/o/r/labels/bug'
expect 2 'gh api /repos/o/r/issues -f title=x'

# Allowed: reads, and local commands that touch no identity.
expect 0 'git status'
expect 0 'git log --oneline -20'
expect 0 'git diff HEAD~1'
expect 0 'git branch --show-current'
expect 0 'git checkout -b feat/x'
expect 0 'gh pr view 12'
expect 0 'gh pr list --state open'
expect 0 'gh run view 99 --log'
expect 0 'gh api /repos/o/r/pulls'
expect 0 'ls -la'
expect 0 'npm run build'

# Either identity variable lifts the block entirely.
expect_state AGENTIC_IDENTITY_ASSUMED 0 'git push'
expect_state AGENTIC_IDENTITY_ALLOW_MISSING 0 'git push'

if [ "$failures" -eq 0 ]; then
    printf 'identity-guard: all checks passed\n'
    exit 0
fi
printf 'identity-guard: %s check(s) failed\n' "$failures" >&2
exit 1
