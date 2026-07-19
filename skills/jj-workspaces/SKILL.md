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

Use `jj-docs` to resolve installed-version workspace behavior before relying
on a command.
