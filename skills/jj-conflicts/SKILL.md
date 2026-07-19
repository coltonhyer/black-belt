---
name: jj-conflicts
description: Use when Jujutsu reports conflicts, when a conflict is carried through history, or when conflict resolution propagation is unclear.
---

# Jujutsu conflicts

Conflicts are first-class values in Jujutsu history, not a mandatory
interrupted operation. Resolve the intended revision without changing the
graph merely to make the conflict disappear.

1. Inspect the conflicted revision, its parents, relevant descendants, and
   the conflicted paths. Determine the intended content before editing.
2. Edit the conflicted file to that result, or use the configured merge tool.
   Preserve the intended parent graph; do not silently choose one side or drop
   a parent just to remove a conflict.
3. Verify the conflict set is now as intended, then inspect affected
   descendants for propagated conflicts and verify their content and graph.

Use `jj-docs` to resolve installed syntax or merge-tool behavior before
relying on a command.
