# Host state-refresh evaluation

## Codex

The first bounded fixture,
`/private/tmp/black-belt-codex-refresh.gdvV5g`, exposed an ordering failure:
it read `jj-change-workflow` and `jj-colocation` before the Jujutsu preflight,
then timed out at the 15-second cap. This led to the explicit pre-skill
ordering rule recorded in `evals/core-rule.md`.

The source-rule treatment used `jj 0.42.0`, a fresh colocated repository, and
a disposable Codex home at
`/private/tmp/black-belt-codex-refresh-source.kzgXDn`. It showed that the
source wording produces the right ordering when explicitly loaded, but it
also exposed that an installed plugin does not automatically load its packaged
`AGENTS.md` before skill selection.

The repaired installed-plugin fixture at
`/private/tmp/black-belt-codex-refresh-hooked.nQ8lSq` used the bundled
SessionStart hook, a fresh colocated repository, and a disposable Codex home.
Its first session preflighted before reading `jj-change-workflow`, observed
`before`, and made no change. The harness changed the parent revision and file
content to `after`, then created a fresh empty continuation change.

The fresh continuation session again preflighted before reading its skill,
observed `after`, appended `continued`, described the completed change exactly
`Continue after refresh`, and created a fresh empty `@`. The final oracle was
`true` for `@` being empty; `@-` had the required description; its
`state.txt` contained `after` then `continued`; and `jj diff -r @- --name-only`
reported only `state.txt`. Neither session used a Git command. Both temporary
credential copies were removed and checked absent. The fixture used Codex's
hook-trust bypass only because it was disposable; normal installs must trust
the reviewed hook. On 0.42.0, the fileset form for a targeted `jj file show`
is `root:"state.txt"`, not bare `state.txt`.

## Claude Code and Antigravity

Claude state refresh was not attempted because its disposable home is logged
out. Antigravity state refresh was not attempted because its fresh disposable
home requires interactive Google authentication. Neither host has a
state-refresh runtime pass recorded.
