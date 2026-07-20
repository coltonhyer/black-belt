---
name: jj-recovery
description: Use when a Jujutsu operation produced the wrong result, work appears lost, or repository state must be restored from operation history.
---

# Recover Jujutsu state

Stop making unrelated mutations. Treat operation history as the recovery
surface, not a reason to reconstruct files manually.

1. Inspect `jj op log` for repository-wide operations, and `jj evolog -r
   <change>` for one change's own rewrite history, before changing anything.
   Inspect the candidate operation and the affected graph first.
2. Choose the narrowest command that reaches the intended state:
   - `jj undo` inverts the most recent operation; repeat it to walk further
     back one operation at a time.
   - `jj op revert <operation>` inverts one specific earlier operation while
     keeping later operations.
   - `jj op restore <operation>` resets the whole repository to that exact
     earlier state, discarding operations after it.
3. Verify the recovered change IDs, graph, and relevant file contents, then
   check status and a targeted log or diff.

`jj undo` itself creates an operation. Repeated blind undo obscures intent;
stop and re-inspect operation history when the result is not the intended state.
If recovery would rewrite an immutable revision, stop: that is a configured
guardrail, not an obstacle to force past.

Use `jj-docs` to resolve installed syntax for inspecting an operation or
restoring it.
