# Insert, duplicate, abandon

## Insert a new change mid-stack

`jj new` accepts the same placement selectors as `jj rebase`:

```sh
jj new --insert-after <revision> -m 'description'
jj log -r 'ancestors(@, 4)'
```

`--insert-after` relocates the target's children onto the new change;
`--insert-before` places it ahead of the target. Passing several revisions as
plain arguments instead creates a merge: `jj new <a> <b>` makes a change with
both as parents.

## Duplicate a change

```sh
jj duplicate -r <revision> --onto <target>
```

Duplicating produces a **new change ID** with the same content — the original
is untouched. With none of `--onto`, `--insert-after`, or `--insert-before`,
the copy lands on the original's existing parents.

## Abandon a change

```sh
jj abandon -r <revision>
jj log -r 'ancestors(@, 5)'
```

Descendants are rebased onto the abandoned revision's parents, so the stack
closes up rather than breaking. Abandoning the working-copy commit yields a
fresh empty one.

Abandoning is recoverable: `jj undo` reverses it, and `jj op log` retains the
prior state. Route anything beyond a single reversal to `jj-recovery`.
