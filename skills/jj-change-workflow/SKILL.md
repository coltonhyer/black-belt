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
3. Use `jj describe -m 'meaningful description'` for the current `@`.
4. If the user says the change is finished, use `jj new` to begin a fresh
   empty working-copy change. Otherwise keep the described `@` active.
5. Verify with `jj status`, `jj log -r '@ | @-'`, and a targeted diff. After
   `jj new`, inspect `@-` to verify the completed change and `@` to verify it
   is empty.

Do not add a bookmark for local completion alone.

## Merge changes

A change can have several parents. `jj new <a> <b>` creates a merge with both
as parents; there is no separate merge command and no merge-in-progress state
to finish. Inspect every parent before creating one, and verify the resulting
parent set afterward with `jj log -r '@ | parents(@)'`. Conflicts that result
are ordinary first-class conflicts — route them to `jj-conflicts`.

## Scope

This is for one ordinary local change. Route stack edits, conflicts, recovery,
workspaces, and publishing to their specialized skills. Every command
snapshots the working copy first, so route generated files, ignore rules, and
tracking to `jj-working-copy` before running a build or test suite. Use
`jj-docs` only when installed help is needed to resolve version-specific
behavior.
