# Black Belt: Jujutsu Context Center Design

**Status:** Approved  
**Date:** 2026-07-18  
**Primary hosts:** Codex, Claude Code, Antigravity

## Purpose

Black Belt is one installable plugin containing a focused catalog of Agent
Skills for Jujutsu. Its purpose is to make coding agents treat Jujutsu as their
native version-control system instead of translating every task back into Git.

The plugin combines:

1. A small always-on rule that establishes Jujutsu-first behavior.
2. Task-oriented skills that teach operational judgment.
3. Lazy-loaded references that answer scoped problem-to-solution questions.
4. A repository-only maintenance skill that keeps the catalog compatible with
   current and slightly older Jujutsu releases.

Black Belt is an operational field manual, not a copy of the Jujutsu manual.

## Goals

- Make agents inspect Jujutsu availability and repository state before work.
- Use `jj` for repository state and history reads and writes.
- Prevent silent fallback to Git.
- Require consent before initializing Jujutsu in an existing Git repository.
- Teach high-value engineering workflows rather than documenting commands one
  at a time.
- Keep routine context cost small through Agent Skills progressive disclosure.
- Share one skill source tree across Codex, Claude Code, and Antigravity.
- Support the latest validated Jujutsu release and the previous two minor
  releases.

## Non-goals

- Mirroring the Jujutsu documentation.
- Shipping a complete CLI reference.
- Blocking Git commands through hooks or policy.
- Automatically initializing repositories.
- Adding MCP servers, lifecycle hooks, apps, or runtime dependencies in v1.
- Maintaining separate copies of skills for each host.

## Always-on rule

The canonical rule lives in `rules/jujutsu-agent.md` and is deliberately
self-contained. There is no mandatory `using-jj` skill.

At the beginning of a task, or after compaction or handoff when state may be
stale, the agent checks the environment in this order:

```sh
jj version
jj root
jj status  # only after jj root succeeds
```

Repeating this preflight after compaction is a required behavior to validate on
each host, not an assumption that every host automatically retained or
re-injected the rule.

The rule establishes this contract:

1. In a Jujutsu repository, use `jj` for repository state and history reads and
   writes. Do not default to Git equivalents such as `git status`, `git diff`,
   `git log`, `git commit`, `git branch`, `git rebase`, or `git worktree`.
2. If Jujutsu is unavailable, report that rather than silently switching to
   Git.
3. If `jj root` fails and the current directory is a Git repository, offer
   `jj git init --colocate .` and obtain permission before running it.
4. If neither repository type is present, do not initialize anything without
   being asked.
5. After consequential mutations, verify the result with `jj status` and the
   relevant targeted `jj diff` or `jj log`.

The plugin does not enforce this contract with a command-blocking hook in v1.

## Context and loading model

Every distributed skill follows the strict Agent Skills format:

```text
skills/<skill-name>/
├── SKILL.md
├── references/    # only when needed
├── assets/        # only when needed
└── scripts/       # only when needed
```

Only skill metadata is present during discovery. `SKILL.md` loads when the
skill is invoked. Supporting files are read or executed individually when the
skill tells the agent to use them; merely placing files in these directories
does not load them.

Compaction behavior is host-specific:

- Claude Code re-injects project-root instructions and invoked skill bodies.
  Invoked skills are capped at 5,000 tokens each and 25,000 tokens collectively,
  with the oldest skills dropped first; truncation preserves the beginning of
  each file.
- Codex and Antigravity do not document equivalent skill-specific retention
  guarantees.

Critical invariants therefore appear near the start of `SKILL.md`, workflows
remain reentrant, and the catalog does not assume an invoked skill survived
compaction. When context is uncertain, the agent repeats the state preflight and
re-invokes the relevant skill or reference.

Each `SKILL.md` contains:

- Trigger metadata.
- Stable principles and safety invariants.
- The skill's compact decision process.
- Required inspection and verification.
- A bounded set of frequent reference links.
- A catch-all link such as `references/recipes.md` for all other questions.

`SKILL.md` should remain below the Agent Skills recommendation of approximately
5,000 tokens and 500 lines, with frequently invoked skills kept much smaller.
The reference library may grow without growing the invoked skill body.

## Reference-library organization

A workflow skill may grow into this shape:

```text
skills/jj-stack-editing/
├── SKILL.md
└── references/
    ├── recipes.md
    ├── recipes/
    │   ├── reorder-changes.md
    │   ├── split-a-change.md
    │   └── squash-selected-content.md
    ├── failure-modes/
    │   ├── destination-resolved-wrong.md
    │   └── unexpected-descendants-rebased.md
    └── version-deltas/
        └── <cross-cutting-delta>.md
```

This is an available organization, not mandatory scaffolding. Empty
directories are not created.

`references/recipes.md` is a lazy-loaded phonebook. The main skill links to a
small fixed set of frequent recipes plus this router; adding long-tail recipes
does not make `SKILL.md` grow. Router entries stay to one line. If the router
approaches 100 entries, it is split into focused category indexes while
remaining the single "all other questions" entry point.

A recipe should answer one operational question:

```markdown
# Intent or symptom

## Use when
## Inspect first
## Version-sensitive behavior
## Recipe
## Verify
## If the result is wrong
## Live documentation
```

Most version notes belong in the affected recipe. `version-deltas/` is reserved
for concise compatibility changes that affect several recipes. It does not
contain copied release notes. A cross-cutting delta records affected versions,
a capability probe, the fallback or changed behavior, a removal condition, and
an upstream source.

`assets/` contains static inputs or output payloads, not instructions.
`scripts/` contains tested deterministic operations that eliminate repeated,
error-prone reasoning. Ordinary `jj` commands are not wrapped merely to create
scripts.

## Distributed skill catalog

All distributed skill names use a `jj-` prefix. Plugin namespaces are displayed
differently across hosts, and generic names such as `querying` or `recovery`
would be ambiguous and collision-prone.

| Skill | Trigger | Responsibility |
|---|---|---|
| `jj-change-workflow` | Creating, describing, inspecting, or completing an ordinary local change | Working-copy change model and the inspect-mutate-verify loop for a single change; specialized workflows remain in their own skills |
| `jj-querying` | Finding revisions or files, or producing dependable output | Change IDs versus commit IDs, revsets, filesets, templates, safe target selection |
| `jj-stack-editing` | Manipulating dependent changes | Split, squash, rebase, reorder, insert, duplicate, abandon, and descendant verification |
| `jj-conflicts` | Encountering or intentionally carrying conflicts | First-class conflict behavior, inspection, resolution, and propagation verification |
| `jj-recovery` | A mutation went wrong or work appears lost | Operation log, undo, operation restore, and recovering abandoned or rewritten work |
| `jj-workspaces` | Parallel agents or multiple working directories | Native workspaces, shared repository state, stale workspaces, and avoiding default `git worktree` usage |
| `jj-colocation` | Setting up Jujutsu or interoperating with a colocated Git repository | Detection, initialization consent, colocation, import/export boundaries, external Git tooling |
| `jj-publish` | Synchronizing with remotes or opening a pull request | Bookmarks, tracking, fetch, push, remote safety, and Git-host workflows |
| `jj-docs` | Exact syntax or installed-version behavior is uncertain | Installed help, exact-version documentation, and capability or maturity checks |

The repository-only skill lives at:

```text
.agents/skills/maintaining-jj-catalog/
```

It is available while developing Black Belt but is not included in the
distributed plugin catalog.

## Documentation authority and version compatibility

Black Belt supports a rolling window consisting of the latest validated stable
minor release `N` plus `N-1` and `N-2`.

Stable concepts belong in skills:

- Change IDs versus commit IDs.
- The working-copy commit and `@`.
- Bookmarks as revision pointers.
- Revsets, filesets, and templates as selection and rendering languages.
- Operation history and undoability.
- Inspect, mutate, then verify.

Version-sensitive details are resolved from the installed binary:

- Command or subcommand existence and maturity.
- Flags, aliases, argument positions, defaults, and implicit targets.
- Push, fetch, and bookmark-tracking behavior.
- Revset, fileset, and template functions.
- Configuration keys and values.
- Experimental, stub, or deprecated behavior.

The authority order is:

1. `jj version`.
2. Installed `jj help <command>` and `jj help -k <topic>`.
3. Installed generated surfaces such as `jj util markdown-help` and
   `jj util config-schema`.
4. Exact-version web documentation.
5. `/latest/` documentation for discovery only.

Every recipe states the versions against which it was validated. The default
route for each supported workflow must pass on `N`, `N-1`, and `N-2`.
Version-specific variants may declare a narrower range, but must include a
capability probe and fallback rather than weakening the catalog-wide default.
Unsupported older or newer versions may still use stable principles, but exact
commands must be resolved from installed help and clearly treated as
unvalidated.

## Catalog maintenance

`maintaining-jj-catalog` guides release maintenance without turning Black Belt
into a documentation mirror.

For a new Jujutsu release it:

1. Reviews the upstream changelog and release notes.
2. Compares generated CLI help, configuration schema, and relevant keyword
   help across the supported window.
3. Identifies only affected recipes.
4. Exercises those recipes in disposable repositories.
5. Records concise behavior changes, probes, fallbacks, and upstream links.
6. Removes deprecated spellings from generated guidance while recognizing them
   for as long as the supported window requires.

No version cache or custom compatibility engine is required in v1.

## Cross-host packaging

One source tree is exposed through thin host adapters:

```text
black-belt/
├── .codex-plugin/
│   └── plugin.json
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── .claude/
│   ├── CLAUDE.md
│   └── skills/
│       └── maintaining-jj-catalog -> ../../.agents/skills/maintaining-jj-catalog
├── .agents/
│   ├── plugins/
│   │   └── marketplace.json
│   └── skills/
│       └── maintaining-jj-catalog/
├── plugin.json
├── skills/
├── rules/
│   └── jujutsu-agent.md
├── AGENTS.md
├── README.md
└── LICENSE
```

| Host | Adapter | Global-rule destination |
|---|---|---|
| Codex | `.codex-plugin/plugin.json` and Codex marketplace metadata | Active `$CODEX_HOME/AGENTS.override.md`, or `$CODEX_HOME/AGENTS.md` when no non-empty override exists |
| Claude Code | `.claude-plugin/plugin.json` and marketplace metadata | `~/.claude/CLAUDE.md` |
| Antigravity | Root `plugin.json` | Plugin `rules/jujutsu-agent.md`, loaded automatically |

Every adapter exposes the same root `skills/` directory. Codex and Claude Code
installation has two explicit steps:

1. Install the plugin.
2. Merge the short canonical rule into the host's global instructions.

Antigravity loads the canonical `rules/jujutsu-agent.md` directly from the
enabled plugin, so copying it again into `~/.gemini/GEMINI.md` would duplicate
the rule. A global copy is only useful if the user wants Jujutsu-first behavior
while the plugin is disabled.

The root `AGENTS.md` applies the same rule while this repository is being
developed. `.claude/CLAUDE.md` imports it with `@../AGENTS.md` because Claude
Code does not read `AGENTS.md` directly. Claude's project-skill path contains a
symlink to the canonical `.agents/skills/maintaining-jj-catalog` directory;
Codex and Antigravity discover the canonical path directly. This preserves one
source copy while making the repository-only skill available to all three
primary hosts.

Marketplace source metadata is finalized when the repository has a publishable
remote URL. Manifest publisher and license values must be real, approved values
rather than placeholders.

## Runtime flow

```text
global rule
  → Jujutsu availability and repository-state preflight
  → relevant skill selected from metadata
  → SKILL.md reasoning and safety guidance
  → optional recipe router
  → exactly the needed reference, asset, or script
  → installed help for version-sensitive syntax
  → Jujutsu operation
  → repository-state verification
```

## Failure behavior

Black Belt fails closed. If a recipe is incompatible, a command is uncertain,
or a capability probe does not match, the agent:

1. Reports the installed Jujutsu version and uncertainty.
2. Preserves repository state.
3. Consults installed help and exact-version documentation.
4. Asks before initialization or an uncertain destructive operation.

It does not silently use `/latest/` syntax, switch to Git, or assume consent.

## Validation

Skills are developed one at a time using behavior-first evaluation:

1. Test the always-on rule itself with an isolated control that omits the rule
   and a treatment that adds only the rule.
2. For an individual skill, give both control and treatment agents the approved
   always-on rule. Withhold the target and sibling skills from the control; add
   only the target skill to the treatment. This isolates the skill's value
   instead of allowing generic Git fallback to dominate the baseline.
3. Write the smallest stable body for each approved top-level skill: its scope,
   safety invariants, compact decision process, verification route, and live
   documentation pointer. Add references only when an observed baseline
   failure needs drill-down guidance.
4. Repeat the task in an otherwise equivalent treatment context.
5. Capture the agent's command or tool trace and verify both required actions
   (preflight, consent, and verification where applicable) and forbidden Git
   fallbacks.
6. Verify the resulting change graph and repository state with `jj status`,
   `jj log`, or `jj diff`, rather than grading only the agent's prose.
7. Run versioned scenarios with pinned binaries and assert `jj version` before
   evaluating the result.
8. Exercise a compaction or handoff scenario on each primary host to verify that
   the agent re-establishes current repository state.
9. Add detailed guidance, recipes, routers, and version deltas only when
   another scenario exposes a real gap. A passing control leaves the approved
   top-level skill compact; it does not remove it from the catalog.

Catalog release gates are:

- Agent Skills structural validation passes for every skill.
- Every plugin manifest parses and exposes the shared `skills/` tree.
- Codex, Claude Code, and Antigravity discover the plugin and skills.
- Core-rule scenarios verify state inspection, Jujutsu-first behavior, and
  consent before colocated initialization.
- Every default workflow route passes against pinned `N`, `N-1`, and `N-2`
  binaries; narrower version-specific variants pass across their declared
  ranges.
- Relative reference links resolve and live documentation links are checked.
- Experimental or stub commands are exercised rather than accepted solely
  because their help entry exists.

Existing validators and disposable repositories are sufficient initially. A
catalog-wide test script is added only when repeated validation commands justify
it.

## Alternatives rejected

- **One monolithic Jujutsu skill:** invocation would load unrelated workflows
  and make compaction more expensive.
- **Mandatory `using-jj` router skill:** the always-on rule can establish the
  required behavior with less session context.
- **Copied Jujutsu documentation:** it would drift and obscure the authority of
  installed help.
- **Host-specific skill copies:** they would create synchronization and review
  debt.
- **Automatic initialization:** it changes repository state without consent.
- **Hooks or command blocking in v1:** they add host-specific behavior before
  the instruction-and-skill approach has been evaluated.
- **A Jujutsu MCP server in v1:** the CLI already provides the required
  operations and installed-version help; existing servers do not justify the
  added runtime surface.

## Source references

- [Agent Skills specification](https://agentskills.io/specification)
- [Jujutsu CLI reference](https://docs.jj-vcs.dev/latest/cli-reference/)
- [Jujutsu changelog](https://docs.jj-vcs.dev/latest/changelog/)
- [Codex skills](https://developers.openai.com/codex/skills/)
- [Codex AGENTS.md guidance](https://developers.openai.com/codex/guides/agents-md/)
- [Claude Code skills](https://code.claude.com/docs/en/skills)
- [Claude Code memory](https://code.claude.com/docs/en/memory)
- [Claude Code context-window behavior](https://code.claude.com/docs/en/context-window)
- [Antigravity skills](https://antigravity.google/docs/skills)
- [Antigravity plugins](https://antigravity.google/docs/plugins)
- [Antigravity rules](https://antigravity.google/docs/rules-workflows)
