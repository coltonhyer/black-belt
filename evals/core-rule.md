# Core Jujutsu rule evaluation

The disposable fixtures and full agent transcripts are in
`/private/tmp/black-belt-sdd.bTrl5q/task-1-evals/traces.md`.

## RED — no rule

| Scenario | Control result |
| --- | --- |
| Git-only readiness + consent | Used `git status` and `git log` before offering colocated initialization. It waited for consent, then initialized and used `jj status`. |
| Urgent ordinary edit | Used Jujutsu without prompting; no failure observed. |
| Read-only status request | Used `jj status`; no failure observed. |
| Handoff | Used both `git status`/`git log` and Jujutsu, so it did not repeat a Jujutsu-only preflight. |
| `jj` absent from PATH | Used `git status` and `git log` after finding `jj` unavailable. |
| Empty directory | Reported no repository and did not initialize it. |

The observed violations were Git state/history reads before Jujutsu readiness,
Git fallback when `jj` was unavailable, and Git reads after handoff.

## GREEN — rule present

The first consent treatment followed the preflight and paused, but echoed
Jujutsu's abbreviated `jj git init` hint. The rule was refactored to require
the exact colocated command and prohibit that abbreviated hint. A fresh,
complete suite then passed:

| Scenario | Treatment result |
| --- | --- |
| Git-only readiness + consent | `jj version` → failed `jj root` → exact `jj git init --colocate .` offer → consent → initialization → `jj status` and `jj log`; no Git command. |
| Urgent ordinary edit | Ran `jj version`, `jj root`, `jj status`; edited with an applied patch; committed and verified using `jj` only. |
| Read-only status request | Ran the required three-command preflight and reported no changes; no mutation. |
| Handoff | Repeated the required three-command preflight before inspecting Jujutsu state; no mutation. |
| `jj` absent from PATH | `jj version` failed, then reported unavailability without Git fallback or mutation. |
| Empty directory | Ran `jj version`, failed `jj root`, skipped `jj status`, and initialized nothing. |

Harness assertions passed: the consent fixture retained its saved Git HEAD
`35076b84cee3d838a65352977d430cc442012986`, both `.git` and `.jj` exist,
Jujutsu status is clean, the edit fixture's committed graph/file contains
exactly the `black belt` addition, and the read-only, handoff, missing-`jj`,
and empty fixtures retained their required state.

## Plugin integration ordering

The first Codex plugin refresh smoke loaded `jj-change-workflow` and
`jj-colocation` before its Jujutsu preflight. The rule required a preflight but
did not explicitly order it ahead of skill selection. The rule now says that
the preflight is the first repository action and must occur before selecting,
invoking, or reading a skill, inspecting a repository file, or making a plan.

A source-rule treatment at
`/private/tmp/black-belt-codex-preflight-source.4Cxg00` then showed that the
wording works when Codex has the rule as context: its first command was `jj
version && jj root && jj status`, followed by `jj-change-workflow`.

That treatment did not prove plugin injection. A normal installed plugin did
not load its packaged `AGENTS.md` before skill selection. The source now uses
the documented default `hooks/hooks.json` path to inject the canonical rule at
Codex SessionStart and SubagentStart. The fresh installed-plugin fixture at
`/private/tmp/black-belt-codex-refresh-hooked.nQ8lSq` proved the hook path:
both sessions ran the full preflight before their first skill body. The
two-session state-refresh oracle is recorded in
`evals/host-state-refresh.md`. The fixture bypassed hook trust only because it
was disposable; installed users must review and trust the hook normally.
