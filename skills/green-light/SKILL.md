---
name: green-light
description: Use when Tom says his standing end-to-end authorization phrase — "if the plan passes an independent agent's review, feel free to take this end-to-end (commit, push and open PR, I'll review and merge or get back to you with review comments)" — or a clear paraphrase ("green light", "take this end-to-end", "go ahead and ship it") — after a plan or spec has just been brainstormed and written. Signals permission to implement, review, commit, push, and open the PR without further check-ins, but never to merge.
---

# Green light

Tom's shorthand for "proceed without checking in with me between steps, through opening the
PR." It authorizes skipping *check-ins*, not skipping *review*, and it never authorizes
merging.

## What it means

1. **Get the plan independently reviewed before writing any implementation code.** Dispatch a
   fresh agent to review whatever planning artifact exists at the moment you're green-lit — a
   written plan if one already exists, or the spec itself if it doesn't. There's no
   "we're still between spec and plan" exception: review the most current artifact, don't skip
   the gate because nothing formal has been written yet.
2. Handle the findings:
   - Clean pass, or only minor/non-blocking notes → proceed.
   - Findings you can resolve by revising the plan → fix the plan accordingly, then proceed.
   - Findings that need a judgment call, conflict with what Tom actually asked for, or you
     can't confidently resolve → **stop and wait for Tom.** Don't guess your way past a review
     comment you don't know how to fix.
3. Implement the (possibly revised) plan.
4. Commit (Conventional Commits, per this repo's `house-rules` skill), push the branch, and
   open the PR.
5. **Stop.** Do not merge the PR, approve it, or take further action on it. Tom's own review
   at this stage is the final gate — he merges or comes back with comments.

## Guardrails this does not relax

- Still branch first; never commit to `master`/`main` directly.
- Still run the project's quality gates before opening the PR.
- Independent review is not optional, and it targets the *plan* — implementing first and
  getting a review only after the fact does not satisfy it.
- Scope is the one plan just discussed. A green light doesn't carry over to unrelated
  follow-up work or a later task — it's said fresh each time.
