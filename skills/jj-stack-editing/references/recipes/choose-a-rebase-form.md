# Choose a rebase form

`jj rebase` takes one selector for *what* moves and one for *where* it lands.
Choosing the wrong selector silently restructures the stack, so decide both
before running anything.

## What moves

| Selector | Moves | Use when |
|---|---|---|
| `-s`, `--source` | the revision **and all its descendants** | relocating a subtree |
| `-r`, `--revisions` | only the named revisions, **descendants stay** | extracting one change out of a stack |
| `-b`, `--branch` | the whole branch containing the revision, relative to the destination | replaying local work onto an updated base |

With no selector at all, `jj rebase` defaults to `-b @`. Never rely on that
default; name the selector.

## Where it lands

| Selector | Result |
|---|---|
| `-o`, `--onto` | the moved revisions become children of the target |
| `-A`, `--insert-after` | moved onto the target, and the target's descendants are rebased onto the moved revisions |
| `-B`, `--insert-before` | moved onto the target's parents, and the target and its descendants are rebased onto the moved revisions |

`-d`/`--destination` is still accepted as an alias for `--onto`, but prefer
`--onto`; much older material uses `-d` and the spellings are easy to confuse.

## Procedure

1. Inspect the subgraph before deciding:

   ```sh
   jj log -r 'ancestors(@, 5) | descendants(@-, 3)'
   ```

2. State the intended parent/child result in words, then choose the two
   selectors that produce it.
3. Run one rebase. Do not chain several to grope toward the shape.
4. Verify the new graph and that change IDs survived:

   ```sh
   jj log -r 'ancestors(@, 5)'
   jj status
   ```

If the rebase reports an immutable target, stop. That is the
`immutable_heads()` guardrail, not an obstacle to force past.
