# Host state-refresh evaluation

## Codex

The first bounded fixture,
`/private/tmp/black-belt-codex-refresh.gdvV5g`, exposed an ordering failure:
it read `jj-change-workflow` and `jj-colocation` before the Jujutsu preflight,
then timed out at the 15-second cap. This led to the explicit pre-skill
ordering rule recorded in `evals/core-rule.md`.

The source-rule treatment used `jj 0.42.0`, a fresh colocated repository, a
disposable Codex home, and a locally installed plugin at
`/private/tmp/black-belt-codex-refresh-source.kzgXDn`. Its first session ran
`jj version`, `jj root`, and `jj status` before reading a skill, observed
`before`, and made no change. The harness then changed the parent revision and
file content to `after`.

The fresh continuation session again preflighted before reading a skill,
observed `after`, and appended `continued`. Its Jujutsu sandbox then denied
writes to `.git/objects`, so it correctly did not substitute Git or force a
checkpoint. The pre-repair oracle was therefore `false`, description
`fixture: changed after first turn`, two file lines `after` and `continued`,
and one changed path `state.txt`; the requested `Continue after refresh`
description and fresh empty change are not claimed. Both temporary credential
copies were removed and checked absent. On 0.42.0, the fileset form for a
targeted `jj file show` is `root:"state.txt"`, not bare `state.txt`.

## Claude Code and Antigravity

Claude state refresh was not attempted because its disposable home is logged
out. Antigravity state refresh was not attempted because its bounded
noninteractive runtime exits 1 without output. Neither host has a state-refresh
or core-rule re-injection pass recorded.
