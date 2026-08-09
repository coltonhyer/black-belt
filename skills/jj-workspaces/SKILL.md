---
name: jj-workspaces
description: Use when multiple agents or working directories need to share one Jujutsu repository, or a workspace is stale.
---

# Jujutsu workspaces

Workspaces share repository history, but each owns a distinct working-copy
change. Do not use Git worktrees for a Jujutsu workspace.

1. Inspect `jj workspace list` for names, then inspect `@` and `@-` to confirm
   the current working-copy change and its parent.
2. Add a sibling with native Jujutsu: `jj workspace add --name review ../review`.
   Omitting `-r` gives the new `@` the current `@`'s parent(s), not the same
   working-copy change.
3. For stale state, use `jj workspace update-stale` in the stale workspace. If
   a removed workspace will not return, use `jj workspace forget <name>` from a
   surviving workspace; `forget` does not remove its directory.
4. After creation or repair, run `jj workspace list`, then check `jj status`
   and `jj log -r '@ | @-'` in both directories. Confirm the two `@` change
   IDs differ and their parent commit IDs match when they should share a base.

A sibling workspace is also how to build or test another revision:
`jj workspace add --name test -r <revision> ../test`. Do not move the primary
`@` onto that revision instead — doing so re-snapshots the working directory
into it, auto-tracking on-disk paths its ignore rules do not cover and
removing them from disk on the next move.

## Sparse working copy

A workspace can narrow which paths of its working-copy change are materialized.
Set the pattern non-interactively with `jj sparse set <paths>`, inspect it with
`jj sparse list`, and widen back with `jj sparse reset`. Do not use `jj sparse
edit`; it opens an interactive editor. Sparsity changes only which files are
present in that workspace, not the change's contents or the shared history.

Use `jj-docs` to resolve installed-version workspace behavior before relying
on a command.
