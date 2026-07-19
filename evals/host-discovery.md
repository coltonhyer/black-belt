# Host discovery

## Versions and structural gates

| Host | Version | Disposable-home result |
| --- | --- | --- |
| Codex CLI | `0.144.6` | Marketplace install and two runtime probes completed. |
| Claude Code | `2.1.214` | Marketplace install completed; runtime is logged out. |
| Antigravity | `1.0.10` | Local plugin install completed; noninteractive runtime exited 1 without output. |

All ten skill validators and the Codex, Claude, and Antigravity manifest
validators exited zero. The public catalog contained exactly the nine approved
skills; the root `skills/` directory did not contain `maintaining-jj-catalog`.

## Codex

In fresh disposable homes, `codex plugin marketplace add`, `codex plugin add`,
and `codex plugin list` accepted the repository-root marketplace. The inventory
run at `/private/tmp/black-belt-codex-inventory.yZbaGL` returned exactly:

`jj-change-workflow`, `jj-colocation`, `jj-conflicts`, `jj-docs`,
`jj-publish`, `jj-querying`, `jj-recovery`, `jj-stack-editing`, and
`jj-workspaces`.

It did not name the maintenance skill. Its trace contained no command that
read a skill body or reference. The explicit `jj-docs` run at
`/private/tmp/black-belt-codex-jj-docs.lAKAQC` read only
`skills/jj-docs/SKILL.md`, returned the documented five-step authority order,
and did not read a sibling or a reference.

The repository-root run at
`/private/tmp/black-belt-codex-maintenance.eyfwuT` resolved
`.agents/skills/maintaining-jj-catalog/SKILL.md` without a distributed plugin.
It then read the linked release workflow because the prompt asked for the
first maintenance action, and reported the `N/N-1/N-2` window. The sandbox
denied Jujutsu's import/export lock during its read-only `jj status` check.
Every Codex disposable credential copy was removed and then checked absent.

## Claude Code

At `/private/tmp/black-belt-claude-discovery.y2rskd`, marketplace add, plugin
install, and plugin details all exited zero. Plugin details reported the same
nine public skills and no maintenance skill. `claude auth status` exited 1 and
reported `loggedIn: false`, `authMethod: none`. No credentials were copied, so
Claude runtime inventory, invocation, repository-only discovery, progressive
disclosure, and state refresh remain untested.

## Antigravity

At `/private/tmp/black-belt-agy-discovery.5hWlge`, local plugin install and
list both exited zero. Installation validated nine skills; the list showed an
enabled `black-belt` import with only the `skills` component. Bounded
noninteractive inventory and `jj-docs` probes exited 1 without stdout or
stderr; the separate bounded runtime at
`/private/tmp/black-belt-agy-runtime.1795` had the same result. A no-plugin
diagnostic in the restricted runner then showed that Antigravity could not
create its local language-server port (`bind: operation not permitted`). An
elevated disposable retry was not run because it could export local plugin or
workspace content to a third-party runtime without explicit user approval.
Rule activation, runtime inventory, progressive disclosure, repository-only
discovery, and state refresh are therefore untested. This is an unavailable
runtime, not evidence that `rules/jujutsu-agent.md` failed to activate.
