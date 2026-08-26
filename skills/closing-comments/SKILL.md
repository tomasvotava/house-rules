---
name: closing-comments
description: Use when Tom says his standing post-merge finalization phrase — "I reviewed and merged the PR, feel free to leave any closing comments on the issues you've worked or any other downstream issues" — or a clear paraphrase ("leave closing comments", "wrap up the issues", "PR's merged, close it out"). Runs the finalization pass on the tracker — Jira, plain GitHub issues, or GitHub Projects: comment on the worked and downstream issues, transition the ticket, file follow-ups for deferred work, record what was learned.
---

# Closing comments

Tom's shorthand for "the PR is merged — now finalize the tracker." It is not a request for one
comment. It is the whole finalization pass, and it is the last chance to put what happened
somewhere a person or agent who never saw this session can find it.

The PR is merged and closed. From here, the ticket is the surface that outlives the work.

## 0. Establish the tracker before writing anything

Tom mixes Jira, plain GitHub issues, and GitHub Projects across repositories. The mechanics differ
per tracker and a wrong guess writes to the wrong place.

Normally the tracker and the issue key are already in session context — the issue was pulled from
it to do the work. Use that.

**If that context is gone — compaction, or the phrase said in a fresh session — ask which tracker
and which issue.** Don't infer it from the branch name, the PR body, or which MCP server happens
to be connected. Ask, and wait.

## 1. Decide what is worth saying

For each candidate issue, answer one question:

> What would someone starting related work tomorrow, who never saw this session, need to know?

Substance that clears the bar:

- An interface, schema, config key, or contract that changed shape.
- An assumption another ticket is built on that no longer holds.
- A decision made here that constrains a downstream choice — a pattern adopted, a library
  rejected, a boundary drawn.
- Something deliberately **not** done, and where it went instead (see §4).
- A gotcha found the hard way that the code does not make obvious.

**Redundant is fine; silent is not.** When it is unclear whether a comment helps, post it. The cost
of one extra comment is a scroll; the cost of a missing one is someone rediscovering a constraint
by breaking it.

Skip an issue only when there is genuinely nothing for its reader — not merely because the
connection feels loose.

## 2. Where to comment

Three passes, in order:

1. **The worked issue.** Always. What landed, where it landed (PR link and merge commit), and what
   a reader must now do differently.
2. **Everything explicitly linked.** Blocks / is-blocked-by, depends-on, relates-to, the parent
   epic or story. Comment where the link means the change reaches them.
3. **One search for unlinked neighbours.** Query open issues for the components, files, modules, or
   keywords this change touched. One pass — not a full-project sweep. Comment on what it surfaces.

## 3. Transition the issue

**Move it to Done by default.** State the transition and the state it landed in.

Two carve-outs:

- Tom said not to transition it. Then don't.
- The workflow has an intermediate gate — QA, Verify, Awaiting release, Ready for deploy — that is
  plainly not satisfied by a merged PR. Then move it to that state instead, and say which and why.

Set the surrounding fields the workflow actually uses, not just the status:

- **GitHub Projects** — move the board's **Status** field. Closing the issue alone leaves the card
  parked in its old column.
- **Jira** — set the resolution if the workflow requires one; clear or update sprint fields if the
  board relies on them.

## 4. File follow-ups for deferred work

Anything consciously deferred during the work becomes a ticket in the same tracker, linked to the
one just closed: a split-out second PR, a known gap accepted for now, a `TODO` left in the code, a
cleanup the review deemed out of scope.

Deferred work that exists only in a merged PR's conversation is lost work. The follow-up ticket is
where it survives.

## 5. Record what was learned

Write a memory for anything non-obvious this work turned up — a constraint, a gotcha, a decision
and its reason — **unless the repository already records it.** Code structure, git history, and
what `CLAUDE.md` already says are not memories.

An architectural decision belongs in an ADR in the repository, not only in a memory. If one is
owed, say so — that is a follow-up ticket (§4), not something to slip into this pass.

## Guardrails

- **Comments are for a future reader, not a status report to Tom.** The `leakage-review` audience
  rule applies to tracker comments exactly as it applies to code comments: no "as requested", no
  "per your feedback", no narrating the diff or the session. State what is true of the system now.
- **No code changes.** This pass writes to the tracker only. Work discovered here becomes a ticket.
- **Touch only the issues this work actually reached.** Don't close issues nobody worked, don't
  tidy the backlog, don't reopen anything.
- **Don't act on other pull requests.** The merged one is finished; others are not this pass.
- Tracker comments and transitions are outward-facing writes under the agent identity — house
  rules §12 applies.

## Mechanics per tracker

| Tracker | Comment | Transition |
| --- | --- | --- |
| Jira | `addCommentToJiraIssue` | `getTransitionsForJiraIssue` first — the available transitions name the workflow's real states — then `transitionJiraIssue`. `editJiraIssue` for resolution and sprint fields. |
| GitHub issues | `gh issue comment <n> --body ...` | `gh issue close <n> --reason completed` |
| GitHub Projects | `gh issue comment` on the backing issue | `gh project item-edit` to set the **Status** field, in addition to closing the issue |

Search for unlinked neighbours (§2.3) with `searchJiraIssuesUsingJql` on Jira, or
`gh issue list --search` on GitHub.
