# Tom's House Rules

A Claude Code plugin carrying the standing engineering guardrails Tom's repositories expect
contributors' agents to follow.

## Skills

| Skill | Purpose |
| --- | --- |
| `house-rules` | Cross-repo guardrails: git and PR discipline, code-quality gates, comments-vs-docstrings, architecture and testing defaults. |
| `leakage-review` | Review a diff for comments, docstrings, and outward-facing strings that leaked the development conversation into the codebase. |
| `green-light` | Recognize Tom's standing end-to-end authorization phrase: implement, independently review, commit, push, and open the PR without further check-ins — never merge. |
| `closing-comments` | Recognize Tom's standing post-merge finalization phrase: comment on the worked and downstream issues, transition the ticket, file follow-ups for deferred work. Covers Jira, GitHub issues, and GitHub Projects. |

The skills are model-invoked: Claude reads each description and decides when to load it. They
make the rules available and prompt their use; they do not block any action.

## Hooks

Two hooks enforce the agent's git and GitHub identity. They require `bash`.

| Hook | Event | Behaviour |
| --- | --- | --- |
| `identity-context.sh` | `SessionStart` | States which identity the session writes under, so a bot author line reads as intended rather than as a bug to report. |
| `identity-guard.sh` | `PreToolUse` (`Bash`) | Blocks git and GitHub write commands when no identity was assumed. Reads are untouched. |

Both read two environment variables:

| Variable | Meaning |
| --- | --- |
| `AGENTIC_IDENTITY_ASSUMED=1` | A dedicated agent identity is active. Attribution to it is intended. |
| `AGENTIC_IDENTITY_ALLOW_MISSING=1` | No agent identity, and that is a deliberate choice — a remote the agent account cannot push to, for instance. Writes are allowed. |
| `AGENTIC_IDENTITY_HINT` | Optional. The recovery instruction quoted back when an identity is missing, e.g. ``Exit, run `start_agentic_mode`, and start claude again.`` Defaults to a generic instruction. |

With neither set, git and GitHub writes are blocked for the whole session.

Export the variables in the environment that launches `claude`, alongside whatever provisions the
identity itself (`GIT_CONFIG_GLOBAL`, a `gh` credential helper, a PATH shim). The hooks read the
environment Claude Code was started in, so exporting them from inside a session has no effect —
restart instead.

## Use it in a repository

Commit this to the repository's `.claude/settings.json`. Contributors are prompted to trust the
marketplace the first time they open a session there.

```json
{
  "extraKnownMarketplaces": {
    "tomasvotava": {
      "source": { "source": "github", "repo": "tomasvotava/house-rules" }
    }
  },
  "enabledPlugins": {
    "house-rules@tomasvotava": true
  }
}
```

The `extraKnownMarketplaces` key must match the `name` field in `.claude-plugin/marketplace.json` —
Claude Code rejects the entry otherwise.

To tighten the rules for one repository, add a `GUARDRAILS.md`, `docs/ARCHITECTURE.md`,
`docs/GOTCHAS.md`, or `docs/CONVENTIONS.md`; the `house-rules` skill reads them and treats them as
refinements. A repository that commits its own `house-rules` skill takes precedence there.

## Install it for yourself

```sh
claude plugin marketplace add tomasvotava/house-rules
claude plugin install house-rules@tomasvotava
```

Verify the skills loaded:

```sh
claude plugin details house-rules
```

## Develop

Validate the manifests after editing either one:

```sh
claude plugin validate .
```

Bump `version` in `.claude-plugin/plugin.json` for every released change, then tag it:

```sh
claude plugin tag .
```

## License

MIT — see [LICENSE](LICENSE).
