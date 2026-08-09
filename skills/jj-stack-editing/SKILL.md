---
name: jj-stack-editing
description: Use when splitting, squashing, rebasing, reordering, inserting, duplicating, or abandoning dependent Jujutsu changes.
---

# Dependent Jujutsu changes

A change ID identifies the logical change; commit IDs identify rewritten
revisions. Select the intended changes by change ID, never by description. A
split is the exception: it reassigns the original ID to one half, so re-verify
an ID you held across one.

## Inspect, mutate, verify

1. Inspect the relevant subgraph, including the selected change, its parents,
   descendants, and diff. Confirm the exact structural result before changing
   anything.
2. Make one structural mutation at a time. Jujutsu rewrites affected
   descendants: their change IDs normally remain stable while their commit IDs
   change. Inspect conflicts immediately if the rewrite creates any.
3. Verify the intended parent/descendant links, preserved or removed change
   identities, affected content, and conflicts in the rewritten subgraph.
   Verify the working-copy change separately when it is a descendant.

## Non-interactive editing

Prefer non-interactive forms so no command blocks on an editor. Split by naming
paths (`jj split <fileset>`) rather than the interactive selection, and move
changes with `jj squash --into <revision>` or `jj absorb` rather than `jj
squash -i` or `jj diffedit`. Selecting content non-interactively does not make
a command non-interactive: `jj squash` still opens an editor to merge
descriptions when both revisions have one, and `-u` keeps the destination's.
Read `--help` for a command's non-interactive flag before running it rather
than assuming the recommended form has none. When only an interactive tool can
express the edit, first confirm a non-interactive diff editor is configured; do
not launch a blocking editor.

## Splitting redistributes identity

`jj split` gives one half a new change ID, and which half keeps the original
depends on the form. The default and `--parallel` keep it on the selected
changes; `-o`, `-A`, and `-B` keep it on the remainder. Installed help
documents which half `-m` describes; it does not document change-ID
assignment, so do not infer one from the other. Read the `Selected changes`
and `Remaining changes` lines the command
prints, confirm with `jj diff -s -r <change>`, then describe. Selecting by
change ID does not survive a split unverified: the ID you held may now name
the other content.

## Validating another revision

Do not build, test, or inspect a historical revision by moving `@` to it with
`jj new <revision>` or `jj edit <revision>`. `@` is re-snapshotted from disk on
every command, so an on-disk path the destination's ignore rules do not cover
is auto-tracked into the working-copy change, and the next move removes it from
disk. `jj edit` is the worse of the two: `@` becomes that revision, so the
contamination amends it and rewrites its descendants rather than landing in a
throwaway child. Read content with `jj file
show -r` or `jj diff -r`, and run builds or tests in a separate workspace.

## Immutable revisions

A rewrite may fail because the target is immutable. That is a configured
guardrail defined by the `immutable_heads()` revset alias, not an error to force
past. Inspect the alias and the selected revision, then edit the intended
mutable change instead. Never override immutability merely to make a command
succeed.

Use `jj-docs` to resolve installed-version syntax and behavior before relying
on an editing command. Route conflict resolution and recovery to their
specialized skills.
