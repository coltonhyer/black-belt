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
