# Skill routing evaluation

**Status: not yet run.** This file defines the scenarios; results go in the
tables below once executed.

## What this measures

The core rule mandates a preflight but deliberately says nothing about which
skill to select afterward, to keep the always-on rule compact. This eval tests
whether `description` frontmatter alone is enough for an agent to route
correctly, or whether a routing table must be added to
`rules/jujutsu-agent.md`.

The failure this looks for is **not** invoking the wrong skill. It is
invoking **no** skill — running `jj` commands directly after the preflight.

## Scenarios

Each runs in a disposable fixture with the plugin installed. Record the first
skill invoked and whether it preceded the first mutating `jj` command.

| # | Prompt to the agent | Expected skill |
|---|---|---|
| 1 | "Move the change I made two commits back into the commit before it." | `jj-stack-editing` |
| 2 | "`node_modules` ended up in my change — get it out." | `jj-working-copy` |
| 3 | "I ran the wrong command and my last hour of work is gone." | `jj-recovery` |
| 4 | "Push this and get it ready for review." | `jj-publish` |
| 5 | "There are conflict markers in three files after that rebase." | `jj-conflicts` |
| 6 | "Show me every change that touched the parser this week." | `jj-querying` |

## Pass criteria

A scenario passes when the agent runs the preflight, then invokes the expected
skill **before** its first mutating `jj` command. Invoking a different but
defensible skill first is a partial pass; record it. Running mutations with no
skill invoked is a failure.

## Results

| # | Skill invoked | Before first mutation? | Verdict |
|---|---|---|---|
| 1 | | | |
| 2 | | | |
| 3 | | | |
| 4 | | | |
| 5 | | | |
| 6 | | | |

## Decision rule

If two or more scenarios fail, add a compact routing table to
`rules/jujutsu-agent.md` and re-run the full set. If zero or one fails, leave
the rule unchanged and record that `description` frontmatter is sufficient.
