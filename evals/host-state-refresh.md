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

The authenticated Claude fixture at
`/private/tmp/black-belt-claude-runtime.1zA3YG` used the session-only plugin
path. Its first and fresh continuation sessions each preflighted before
`black-belt:jj-change-workflow`; the continuation appended `continued`,
described the change exactly `Continue after refresh`, and created an empty
`@`. The Jujutsu oracle passed and neither trace contained a Git command.

The authenticated Antigravity fixture reported preflight before a read, but
did not complete state refresh. Its model emitted an invalid command-tool
signature and the host timed out before any fixture mutation. The final
fixture therefore remained an empty `@` over the externally prepared `after`
parent; this is recorded as a host-runtime block, not a catalog pass.
