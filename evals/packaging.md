# Packaging evaluation

## Red and green structure

Before Task 3, the four manifests, `LICENSE`, `README.md`, and the repository
marketplace file were absent. The final structural check validates the created
manifests and confirms the root `skills/` directory contains exactly the nine
public skills listed in the README.

## Codex local-source spike

On 2026-07-19, a fresh unauthenticated `CODEX_HOME` accepted the repository
root as a local marketplace source. These all exited zero:

```sh
codex plugin marketplace add /Users/colton/Code/black-belt --json
codex plugin list --marketplace black-belt --available --json
codex plugin add black-belt@black-belt --json
codex plugin list --json
```

The available result named `black-belt@black-belt` at version `0.1.0`; the
installed result named the same plugin as enabled with local source
`/Users/colton/Code/black-belt`. No user credential or real host state was
used. The disposable artifact is retained at
`/private/tmp/black-belt-codex-marketplace.TII6Sn`.

## Host validators

All five JSON documents parsed with `python3 -m json.tool`. In the disposable
home `/private/tmp/black-belt-host-validate.IAWGE5`, these all exited zero:

```sh
claude plugin validate --strict .
agy plugin validate .
uv run --with pyyaml python \
  /Users/colton/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py .
```

Claude reported `Validation passed`; Antigravity reported nine processed
skills and no MCP servers or hooks; the Codex validator reported `Plugin
validation passed`. These are structural checks; authenticated runtime evidence
is recorded separately in `evals/host-discovery.md` and
`evals/host-state-refresh.md`.

## Core-rule hook packaging

The later core-rule repair adds `hooks/hooks.json` and
`hooks/jujutsu-context.mjs`. Codex discovers that default hook path without a
manifest field, which preserves compatibility with the strict local Codex
manifest validator. Claude Code registers the same file through
`.claude-plugin/plugin.json`. The final checks passed:

```sh
claude plugin validate .claude-plugin/plugin.json
uv run --with pyyaml python \
  /Users/colton/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py .
node --check hooks/jujutsu-context.mjs
```

Antigravity intentionally has no root `hooks.json`: its documented plugin
`rules/` component carries the canonical rule instead.
