---
name: jj-change-workflow
description: Use when creating, describing, inspecting, or completing an ordinary local change in a Jujutsu repository.
---

# Ordinary Jujutsu changes

The working copy is a change: `@` names the change being edited, not an
untracked staging area. Its change ID remains stable while its commit ID can
change as it is rewritten. `@-` is its parent.

## Single-change loop

1. Follow the repository's Jujutsu preflight, then inspect `jj status` and
   `jj log -r '@ | @-'` before selecting the intended change.
2. Edit only the requested paths. Inspect `jj diff` before describing it.
3. Use `jj describe -m 'concise changeset description'` for the current `@`.
   Pass subsequent `-m` flags for additional lines when the change needs body
   text.
4. If the user says the change is finished, use `jj new` to begin a fresh
   empty working-copy change. Otherwise keep the described `@` active.
5. Verify with `jj status`, `jj log -r '@ | @-'`, and a targeted diff. After
   `jj new`, inspect `@-` to verify the completed change and `@` to verify it
   is empty.

Do not add a bookmark for local completion alone.

## Describe versus commit

`jj describe` names `@` and keeps it active. `jj commit` combines describe
with `jj new`, finalizing `@` and starting a fresh working-copy change, so it
suits a change that is already finished. When `@` has grown past one coherent
change, peel commits off with `jj commit <fileset> -m 'concise changeset
description'`: the named paths are finalized with that description and the
remaining edits stay in the new `@`. Repeat until `@` holds one coherent
change. Splitting a change already in history is stack editing, not this
loop.

## Scope

This is for one ordinary local change. Route stack edits, conflicts, recovery,
workspaces, and publishing to their specialized skills. Use `jj-docs` only
when installed help is needed to resolve version-specific behavior.
