---
name: jj-recovery
description: Use when a Jujutsu operation produced the wrong result, work appears lost, or repository state must be restored from operation history.
---

# Recover Jujutsu state

Stop making unrelated mutations. Treat operation history as the recovery
surface, not a reason to reconstruct files manually.

1. Inspect `jj op log`, then inspect the candidate prior operation and the
   affected graph before changing anything.
2. If the bad operation is immediately previous, use one `jj undo`. If a
   known earlier operation is the intended state, restore that exact operation.
3. Verify the recovered change IDs, graph, and relevant file contents, then
   check status and a targeted log or diff.

`jj undo` itself creates an operation. Repeated blind undo obscures intent;
stop and re-inspect operation history when the result is not the intended state.

Use `jj-docs` to resolve installed syntax for inspecting an operation or
restoring it.
