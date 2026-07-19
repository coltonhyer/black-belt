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

## Enable the core rule

Plugin installation exposes skills; it does not overwrite global instructions.
Merge—not replace—[`rules/jujutsu-agent.md`](rules/jujutsu-agent.md) into the
active instruction file:

- Codex: use `$CODEX_HOME/AGENTS.override.md` when it exists and is non-empty;
  otherwise use `$CODEX_HOME/AGENTS.md`.
- Claude Code: use `~/.claude/CLAUDE.md`.
- Antigravity: the enabled plugin is expected to discover
  `rules/jujutsu-agent.md`, but automatic always-on activation remains pending
  Task 13 verification. Merge it into `~/.gemini/GEMINI.md` when you need the
  guarantee before that verification lands.

The rule makes the agent prefer Jujutsu for repository state and history. It
does not fall back to Git, and it never initializes a repository on its own:
the agent offers `jj git init --colocate .` and asks before running it.

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

v0.1 has no MCP servers, hooks, or apps. It provides instructions and skills
only.

## License

[MIT](LICENSE)
