---
name: jj-stack-editing
description: Use when splitting, squashing, rebasing, reordering, inserting, duplicating, or abandoning dependent Jujutsu changes.
---

# Dependent Jujutsu changes

A change ID identifies the logical change; commit IDs identify rewritten
revisions. Select the intended changes by change ID, never by description.

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

Use `jj-docs` to resolve installed-version syntax and behavior before relying
on an editing command. Route conflict resolution and recovery to their
specialized skills.
