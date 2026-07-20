# Black Belt

Black Belt is a Jujutsu-first skill catalog for coding agents. It supports
Jujutsu 0.43, 0.42, and 0.41.

## Install

For a local checkout in Codex:

```sh
codex plugin marketplace add /path/to/black-belt
codex plugin add black-belt@black-belt
```

For Claude Code:

```sh
claude plugin marketplace add /path/to/black-belt --scope user
claude plugin install black-belt@black-belt --scope user
```

For Antigravity:

```sh
agy plugin install /path/to/black-belt
```

## Core rule

Black Belt ships a compact rule declaring the agent a Jujutsu agent. It starts
repository work with `jj version`, `jj root`, and `jj status` when applicable;
uses Jujutsu rather than Git; and offers—but never assumes—`jj git init
--colocate .`.

Each host injects this rule through a bundled hook: Codex and Claude Code use
the SessionStart and SubagentStart hook, and Antigravity uses a root
`hooks.json` PreInvocation hook. Review and trust that hook after installing
the plugin: it only reads [`rules/jujutsu-agent.md`](rules/jujutsu-agent.md)
from the installed plugin and returns it as agent context.

If a host cannot run the bundled hook or rule, merge—not replace—the canonical
rule into that host's global guidance. The catalog checkout's
[`AGENTS.md`](AGENTS.md) already contains the same rule for work in this
repository.

## Public skills

| Skill | Use it for |
|---|---|
| `jj-change-workflow` | Ordinary local changes |
| `jj-querying` | Revsets, filesets, and templates |
| `jj-stack-editing` | Dependent change stacks |
| `jj-conflicts` | Conflict inspection and resolution |
| `jj-recovery` | Undoing or recovering repository state |
| `jj-workspaces` | Shared-repository workspaces |
| `jj-colocation` | Jujutsu repositories colocated with Git |
| `jj-publish` | Bookmarks, fetch, push, and PR preparation |
| `jj-docs` | Exact syntax and version-aware behavior |

Each invoked skill starts compact and links to `references/` only when a
specific recipe needs more context. `maintaining-jj-catalog` is a repository
maintenance skill, not part of the distributed plugin.

## Scope

Black Belt bundles skills and compact core-rule hooks for Codex, Claude Code,
and Antigravity. It does not bundle an MCP server or app.

## License

[MIT](LICENSE)
