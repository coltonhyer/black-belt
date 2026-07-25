# Choose a recovery command

Pick the narrowest command that reaches the intended state.

| Command | Effect | Use when |
|---|---|---|
| `jj undo` | undoes the last operation; repeat to walk further back | the very last thing you did was wrong |
| `jj op revert <operation>` | applies the inverse of **one** operation, keeping later ones | one earlier operation was wrong but later work is good |
| `jj op restore <operation>` | resets the whole repo to that operation, discarding everything after | several operations compounded and later work is disposable |

`jj op revert` takes an optional operation argument; `jj op restore` requires
one. Both create a new operation, so neither is destructive to the log itself.

## Procedure

1. Identify and inspect the operation first — see
   [Read the operation log](read-the-operation-log.md).
2. Confirm which of the three commands matches the scope of the damage. If
   later operations must survive, `op restore` is the wrong tool.
3. Run exactly one command.
4. Verify the result — change IDs, graph shape, and file content:

   ```sh
   jj status
   jj log -r 'ancestors(@, 10)'
   jj diff -r <change>
   ```

5. If the result is still wrong, **stop and re-read `jj op log`** rather than
   running another reversal. `jj undo` is itself an operation; stacking blind
   reversals makes the intended state harder to reach.

`jj redo` moves forward again after one or more undos, which is the correct
response to overshooting.

If recovery would rewrite an immutable revision, stop. That is the
`immutable_heads()` guardrail, not an obstacle to force past.
