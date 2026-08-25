---
name: house-rules
description: Tom's personal, cross-repo standing engineering guardrails — git/PR discipline (never push master, rebase-only, conventional commits), code-quality gates, comments-vs-docstrings, ask-don't-assume, no-shortcuts, sub-agent dispatch safety. Use when starting work in any repo, before committing or opening a PR, before dispatching any sub-agent, or when unsure of the working rules. (A repo with its own committed house-rules skill takes precedence there.)
---

# House rules

Standing engineering guardrails for any repo. These OVERRIDE default behavior — follow them
exactly. When a rule here conflicts with a convenience, the rule wins.

If the repo has its own `GUARDRAILS.md`, `docs/ARCHITECTURE.md`, `docs/GOTCHAS.md`, or
`docs/CONVENTIONS.md`, read those too before editing — they refine and may tighten what's below.

## 0. Posture: ask, don't assume; no shortcuts

- **When you're unsure, ask — don't guess and proceed.** Approval given in one context does
  not extend to the next. If a decision changes what you build, surface it instead of
  picking silently.
- **No shortcuts.** Don't silence a check, stub a test, hardcode a value, or fake a result
  to get to "done" faster. If the right path is blocked, say so and stop.
- **Recurring-class problems get a portable fix, not a point patch.** When a problem will
  plausibly recur in other places or projects, propose a robust convention (and record it as
  an ADR) rather than a one-off hack that hopes it never happens again.
- **Report outcomes faithfully.** If tests fail, say so with the output. If you skipped a
  step, say that. Don't claim verified-and-done without having actually run the verification.

## 1. Don't touch the developer's machine

**Never run a command that changes anything outside this repository's working tree unless
the user explicitly asked for that exact action in the current turn.**

Off-limits without an explicit yes:

- Installing/uninstalling system packages, language runtimes, or global CLIs (`apt`, `brew`,
  `pip install -g`, `npm i -g`, `cargo install`, `pipx`, `uv tool install`, `pyenv install`,
  `nvm install`, `rustup`, …).
- Switching the active runtime version in the shell (`nvm use`, `pyenv shell/global`).
- Modifying global config (`~/.gitconfig`, `git config --global`, `~/.npmrc`, shell rc files).
- Starting/stopping/installing services or daemons.
- Writing anything outside the repo, except files the user asked for.

Project-local actions are always fine: dependency installs scoped to the project, syncing the
lockfile, local hook installation, file edits inside the repo.

If a tool is missing, **ask with the exact command you'd run** ("X isn't installed. Want me to
run `…`?") and wait for a yes for that specific action. Agents share workstations with humans
whose dotfiles, PATH, and runtime versions are load-bearing; silent installs break unrelated work.

## 2. Files agents must not edit unsupervised

- A repo's `CLAUDE.md` and `GUARDRAILS.md` (governance changes land in their own PR, not bundled with feature work).
- `CODEOWNERS`, `LICENSE`, and proprietary/license notices.
- Anything under `.github/workflows/` or other CI/security config — needs explicit review.
- Lockfiles — only update them as a side-effect of the canonical install/sync command; never hand-edit.
- ADRs marked `Status: Accepted` — supersede with a new ADR, don't rewrite history.

## 3. Git & PR discipline

- **Never push to `master`/`main`, and never commit directly to it.** Branch first. The branch
  name carries the tracking key when there is one (e.g. `ABC-123-short-slug`).
- **Never offer or perform a local merge to `master`/`main`.** All integration goes through a
  GitHub Pull Request — every change must have a GitHub paper trail. When finishing a branch, the
  only integration option to present is push + open a PR; do not offer "merge back locally". If
  there is no remote yet, stop and let the user set one up rather than merging locally.
- **Commit/push only when the user asks.** Don't volunteer commits or pushes.
- **Conventional Commits for every commit, not just the PR title.** `feat:`, `fix:`, `chore:`,
  `refactor:`, `docs:`, `test:`, … Scope is the project/module name when applicable:
  `feat(api): add positions endpoint`. Reference the tracking key in the body when useful.
- **Merges are rebase, never squash.** Assume there is no squash-and-merge: **every commit lands
  on the trunk as-is**, so every commit message must stand on its own and the history must be
  clean. Curate before opening the PR — `git rebase -i` to fix message typos, drop "wip"
  commits, and fixup mistakes into their parent. The history that lands is the history you craft.
- **No merge commits, ever — locally or on the trunk.** Update a branch against trunk with
  `git rebase`, not `git merge`. History stays linear; a merge commit is grounds to redo the
  update as a rebase before the PR opens.
- **PRs are small, incremental, and single-concern.** One bounded change end-to-end. Refactor
  *or* feature, not both. Style cleanup *or* logic, not both. If making your change work
  requires rewriting core functionality, that's two PRs.
- **Open–closed posture.** Prefer adding a module that plugs in over editing a shared core
  type. When you must modify shared code, justify it in the PR description.
- Interactive git flags (`git rebase -i`, `git add -i`) may be unavailable in the agent
  environment — script the equivalent non-interactively or ask the user to run it.

## 4. Code quality (hard gates)

Every change must leave each touched project clean on its full toolchain — typically:
format check, lint with zero warnings, strict type-check, and tests passing. Don't open a PR
that regresses any of these.

Silencing a rule is allowed **only** with an inline justification that names a real constraint:

```
# noqa: <code> — names the constraint, not "to satisfy the linter"
// eslint-disable-next-line <rule> — names the constraint
```

A justification that doesn't name a constraint is grounds to remove the silence.

## 5. Code style

- **Comments and docstrings serve different audiences — don't conflate them.**
  - **Comments are for the next contributor.** Write one only to explain *why* a non-obvious
    choice was made (a hidden constraint, a workaround, a subtle invariant). Don't narrate
    *what* the code does — well-named identifiers are the documentation.
  - **Docstrings / published docs are for consumers.** Document the contract: inputs, outputs,
    errors, invariants. Don't use a docstring to talk to a contributor about implementation.
  - **Explanations to the person you're chatting with go in the chat, not the file.**
    A comment that addresses "you" or justifies a change to the requester is a chat message
    that leaked into the repo. Strip it before saving.
- **Naming follows language idiom** (`snake_case` / `camelCase` / `PascalCase` as appropriate).
- **No dead code, no commented-out code, no `TODO` without a tracked issue link.**
- **Soft size targets**: files under ~500 lines, functions under ~50. Going over is fine when
  splitting would hurt cohesion — justify it in the PR.
- **Model the domain with real types** at boundaries rather than passing primitives around
  (e.g. filesystem paths as a path type, not strings; convert at the edge).
- Cross-project imports absolute; within-project imports relative.

## 6. Architecture & design

- **Non-trivial work needs a plan first** — anything that touches more than one project,
  changes a public interface, or introduces a new architectural concept. Plan goes through
  review before code lands.
- **Architectural decisions ship with an ADR** under `docs/adr/`, and update the ADR index in
  `docs/ARCHITECTURE.md`. Record the decision when you make it; don't leave it implicit.
- **DDD as a guideline, not a religion.** Push business rules into the domain layer, keep the
  domain free of infrastructure/interface imports, keep aggregates small. But don't build a
  hexagonal cathedral around a 100-line CRUD endpoint or a hello-world app — deviate when the
  ceremony would obscure intent, and note the deliberate deviation in the project's README.
- **Ports and adapters at the boundary.** Define the domain's dependencies as interfaces
  (ports) it owns; infrastructure (DB, HTTP clients, queues, third-party SDKs) implements them
  as adapters plugged in from outside. The domain never imports a concrete adapter.
- **Separation of concerns is the default, not an afterthought.** Domain logic, orchestration,
  and I/O are distinct layers even in a small project — don't let a handler both parse a
  request and decide business rules. Scale the ceremony to the project's size, not the
  separation itself.
- **Don't mock the domain in tests** — test it directly; mock at the infrastructure boundary
  (i.e., at the port).

## 7. Generation over authoring

- If something is generated (scaffolding, lockfiles, accessors, client stubs), **regenerate it
  — never hand-author the output.** CI may fail when generated artefacts drift from source.
- Add dependencies via the package manager's command, not by hand-editing the manifest.
- Add a new project/module via the documented procedure or generator, not by hand-creating
  directories. If no procedure exists yet for what you're adding, **propose the procedure doc
  first**; if one exists, follow it exactly.

## 8. Testing

- **Test our glue and logic, not a third-party library's promised behavior.** Don't write tests
  that merely re-assert a dependency's documented feature works.
- Prefer constructor/config overrides for fixtures over monkeypatching internals.

## 9. Docs

- **Tone is instructional: what + how, imperative.** No pep talk, no marketing prose, no
  restating why the thing is great. READMEs, CONTRIBUTING, and procedures tell a reader what to
  do and how.
- **A project's own docs describe its standalone contract** (what it does, how to use it).
  Deployment topology and cross-project/monorepo specifics belong in ADRs / ARCHITECTURE, not
  in a leaf project's README.
- **Design specs and implementation plans are working artefacts, not committed history.**
  Brainstorming specs and plans (e.g. under `docs/superpowers/`) stay local — git-ignore that
  path rather than committing them. The durable decision record is the ADR; the spec/plan is
  scaffolding for getting there.

## 10. Definition of done

Before claiming a piece of work is complete:

1. The hard gates in §4 pass for every touched project — run them, don't assume.
2. Route the completed diff through an independent code-review pass.
3. Run a leakage review on comments/docstrings (see §5) — strip anything that narrates the
   task, the chat, or a ticket instead of serving a future contributor/consumer.

Only then say it's done — plainly, without hedging, and noting anything skipped or still failing.

## 11. Dispatching sub-agents

A sub-agent should never be put in a position where it has to choose between following an
instruction and respecting a guardrail — that choice belongs to you, made before dispatch, not
to it, made under pressure to complete the task.

- **Never dispatch a sub-agent while the working tree is on `master`/`main`.** Create/checkout
  the feature branch yourself first — or create the worktree, if this repo's workflow uses
  worktrees — *before* handing off any task that will touch files or run git commands. Don't
  dispatch onto trunk and trust the sub-agent's instructions to keep it off trunk; §3's
  never-commit-to-master rule applies to the dispatcher's setup step, not just the sub-agent's
  behavior.
- **Give every sub-agent explicit, absolute-path context**: the exact working directory to
  operate from (`Work from: <absolute path>`, not a relative one), the branch it should already
  be on, and an instruction to verify both as its *first* action (`git rev-parse
  --show-toplevel`, `git branch --show-current`) and stop if either doesn't match — before
  touching any files. Sub-agent cwd/branch can silently drift from what you intended; treat a
  mismatch as a hard stop for it to report, not something for it to reconcile and proceed anyway.
- **After every sub-agent task returns, verify from your side too** — `git status --porcelain`
  and `git log -1`, in both the target worktree/branch and the main checkout. Don't rely solely
  on the sub-agent's self-report that it stayed in bounds.
- **Sub-agents must never touch `.claude/settings.json`, `.claude/settings.local.json`, or any
  other permission/hook config** — not to self-grant a denied permission, not to "unblock"
  themselves, not for any reason, ever. Say this explicitly in the dispatch instructions; don't
  assume it's implied.
- **A permission prompt, denial, or blocked action is a stop signal, not an obstacle.** Every
  sub-agent dispatch must instruct: on hitting a blocked action, stop and report **BLOCKED**
  with what it was trying to do and why — never retry with escalated permissions, loosen the
  gate, or find an alternate path to the same effect. This applies to every guardrail in this
  document, not only the git/branch ones.

## 12. Git and GitHub identity

Agent sessions may run under a dedicated bot account rather than the operator's own, so that the
operator reviews the agent's pull requests instead of their own code. When that identity is
active, `AGENTIC_IDENTITY_ASSUMED=1` is exported in the session environment.

- **The active identity is yours.** Commits you author, PRs you open, and comments you post are
  attributed to the bot by design. That is the intended outcome — not a misconfiguration, not an
  impersonation of the operator. Never report it as a problem, never try to correct it, never
  pause work over it.
- **Never write to git or GitHub when neither `AGENTIC_IDENTITY_ASSUMED=1` nor
  `AGENTIC_IDENTITY_ALLOW_MISSING=1` is set.** Stop and tell the operator to restart the session
  with the identity active. Reads are fine.
- **Never assume an identity yourself.** Don't export the variables, don't pass `--author` or
  `-c user.name=`, don't reach for another credential. A missing identity is a stop signal
  (§11), not an obstacle — and wrong attribution is not something the reviewer can undo.
- `AGENTIC_IDENTITY_ALLOW_MISSING=1` means the operator deliberately chose a different account
  for this repository, typically a remote the bot cannot push to. Work normally.

---

## If this project is a monorepo

- **Run tooling through the monorepo's task runner**, scoped to affected projects rather than
  the whole tree (e.g. an `affected -t lint/typecheck/test` style command). The rebase-only,
  conventional-commit discipline in §3 is what lets the affected-graph and changelog tooling
  work — don't break it.
- **Each deployable carries the cross-cutting requirements** the repo standardizes (e.g.
  observability/metrics endpoint, structured logging via the shared lib, env-var-based config
  with no committed per-environment files, auth gating for user-facing surfaces). Reviewers
  reject PRs that ship a service violating these. Check the repo's ADRs for the current list.
- **No committed per-environment config**; `.env` files are local-dev only and git-ignored.
- If a **bootstrap/baseline gate** exists (don't add feature projects until a reference
  implementation lands), respect it and coordinate with the repo owner.
