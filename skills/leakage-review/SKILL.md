---
name: leakage-review
description: Review the current diff for "conversation leakage" in comments and docstrings — text that narrates the task/chat/tickets, justifies a change to the requester, or only makes sense mid-development, instead of serving a future contributor (comments) or a future consumer (docstrings). Also flags prescriptive/editorializing text in comments, docstrings, and outward-facing string literals (error/log/config messages) that tells the operator what to do instead of stating the contract. Use when asked to check a diff/PR/branch for comment or docstring leakage, chat-leak, audience-mismatched docs, prescriptive/moralizing strings, or to vet comments before a commit or PR.
---

# Leakage review

Hunt for comments and docstrings that leaked the development conversation into the codebase.

## The rule being enforced

- **Comments are for contributors** (people editing the file later): explain *why* a non-obvious choice was made — a hidden constraint, a workaround, a subtle invariant. Not *what* the code does.
- **Docstrings/published docs are for consumers** (people using the API): document the contract — inputs, outputs, errors, invariants.
- **Leakage** = text that would make little or no sense to a reader who never saw this development session. Red flags:
  - Narrates the task or chat: "as requested", "we now…", "this task adds…", "per your feedback".
  - References tickets/plans/PRs as the *content* of a code comment rather than the code's behavior.
  - Justifies a change to the requester/reviewer ("rather than shipping X now").
  - Describes future/unwritten work in a way only meaningful at this point in the project ("the later X goes here").
  - Status/progress narration in docstrings or module headers ("this is the skeleton; logic lands later").
  - **Prescribes or moralizes to the operator** — tells ops/users what they *should* do, or judges their choices, instead of stating the contract and the mechanism. This applies to comments and docstrings **and to outward-facing string literals** (error messages, log messages, config-field descriptions). The neutral form gives the fact and the lever and lets the reader decide.

    Example to search for — an error/description that editorializes about intended use:

    ```
    # leak (prescribes intended use + moralizes):
    "OIDC issuer is not https (set BACKEND_OIDC_ALLOW_INSECURE_HTTP for local dev; never in prod)"
    # neutral (states the fact + the lever):
    "OIDC issuer does not use https; set BACKEND_OIDC_ALLOW_INSECURE_HTTP to allow a non-https issuer"
    ```

    Tell-tale phrases in added lines: `for local dev`, `never enable`, `in prod`, `you should`, `we recommend`, `only enable …`.

A comment that documents a genuine, durable design invariant for contributors is **fine** — flag only true leakage, audience mismatch, or prescription.

## How to run it

1. **Determine the diff scope** (in this priority):
   - If the user named a base ref, PR, or paths, use that.
   - Else if there are uncommitted changes (`git status --porcelain` non-empty), review `git diff HEAD`.
   - Else review the branch against its base: `git diff $(git merge-base HEAD origin/HEAD)...HEAD` (fall back to the repo's default branch, e.g. `main`/`master`, if `origin/HEAD` is unset).
2. **Prefer delegating** to the `pr-review-toolkit:comment-analyzer` agent if it is available in this environment — dispatch it with the diff scope and the criteria above, instructing it to also confirm which comments/docstrings are good so the signal is clear. If that agent is not available, do the analysis yourself by reading the changed files directly.
3. **Report** each finding with: the quoted comment/docstring, `file:line`, why it reads as leakage or audience-mismatch, and a concrete rewrite or deletion. List the comments/docstrings that are correct, too. Do **not** edit files unless the user asks — this is a review.

## Notes

- Honour the repo's own rule if it has one (e.g. a `GUARDRAILS.md` "comments vs docstrings" section); it overrides this skill's phrasing.
- Keep scope to comments, docstrings, and outward-facing string literals (error/log/config messages) — this is not a general code review. The prescription check is the only reason to look at string literals; logic, naming, and behaviour are out of scope.
