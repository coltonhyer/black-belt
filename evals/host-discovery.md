# Host discovery

## Versions and structural gates

| Host | Version | Fixture result |
| --- | --- | --- |
| Codex CLI | `0.144.6` | Marketplace install and two runtime probes completed. |
| Claude Code | `2.1.214` | Session-only plugin run and two-session state refresh passed. |
| Antigravity | `1.0.10` | Authenticated core-rule read passed; skill and state-refresh runs hit host timeouts. |

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
nine public skills and no maintenance skill. A later authenticated,
session-only `--plugin-dir` fixture ran the canonical SessionStart hook; its
first Bash command was `jj version && jj root && jj status`, then it invoked
`black-belt:jj-change-workflow`. A fresh second session passed the full state
refresh oracle. No credential was copied and no persistent plugin setting was
changed.

## Antigravity

At `/private/tmp/black-belt-agy-discovery.5hWlge`, local plugin install and
list both exited zero. Installation validated nine skills; the list showed an
enabled `black-belt` import with only the `skills` component. The validator
does not report rules, but an isolated install staged
`rules/jujutsu-agent.md` byte-for-byte. Bounded noninteractive inventory and
`jj-docs` probes exited 1 without stdout or stderr; the separate bounded
runtime at `/private/tmp/black-belt-agy-runtime.1795` had the same result. A
no-plugin diagnostic in the restricted runner then showed that Antigravity
could not create its local language-server port (`bind: operation not
permitted`).

With the existing authenticated session and a temporary local install, a
one-line control prompt passed. A focused core-rule run reported a preflight
before reading `state.txt`, then made no mutation. Antigravity's command tool
starts in a host scratch directory, so the agent first used workspace
discovery that did not read a repository file. A skill-invocation probe timed
out in directory exploration, and the fresh state-refresh attempt hit an
Antigravity invalid tool-call signature before any fixture mutation. The
temporary `black-belt`
install is removed after evaluation. These are host-runtime limitations, not
evidence that the staged rule failed to load.
