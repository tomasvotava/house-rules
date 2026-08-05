# Tom's House Rules

A Claude Code plugin carrying the standing engineering guardrails Tom's repositories expect
contributors' agents to follow.

## Skills

| Skill | Purpose |
| --- | --- |
| `house-rules` | Cross-repo guardrails: git and PR discipline, code-quality gates, comments-vs-docstrings, architecture and testing defaults. |
| `leakage-review` | Review a diff for comments, docstrings, and outward-facing strings that leaked the development conversation into the codebase. |
| `green-light` | Recognize Tom's standing end-to-end authorization phrase: implement, independently review, commit, push, and open the PR without further check-ins — never merge. |

Both are model-invoked: Claude reads each skill's description and decides when to load it. The
plugin makes the rules available and prompts their use; it does not block any action.

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
