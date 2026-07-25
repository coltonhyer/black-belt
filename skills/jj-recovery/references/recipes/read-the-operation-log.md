# Read the operation log

Identify the operation before reversing anything. Blind repeated `jj undo`
obscures what happened and is itself recorded as new operations.

## Find the operation that caused the wrong state

```sh
jj op log --limit 10
```

Each entry carries an operation ID, the command that produced it, and a
timestamp. Read downward until you reach the last state that was correct —
that is the operation you restore *to*; the one after it is the operation you
revert.

For stable output rather than the human-facing graph:

```sh
jj op log --no-graph --limit 10 -T 'id.short() ++ " " ++ description ++ "\n"'
```

## Inspect a candidate before acting

Never reverse an operation you have not looked at.

```sh
jj op show <operation>
jj op diff --operation <operation>
```

To view the whole repository as it was, without changing anything:

```sh
jj --at-op=<operation> log -r 'ancestors(@, 10)'
jj --at-op=<operation> status
```

**`--at-op` is not itself read-only** — it sets the operation a command runs
against, and Jujutsu permits mutating commands there. Doing so writes from a
stale view and forks the operation log, which Jujutsu then reports as
`Concurrent modification detected` and reconciles into divergent operations.
That turns an inspection into a second problem to recover from.

Pair `--at-op` only with read-only commands such as the `log` and `status`
above. To change history, return to the current operation and use one of the
reversal commands.

## Trace one change rather than the whole repo

When a single change was rewritten and its content looks wrong, its own
history is the narrower surface:

```sh
jj evolog -r <change>
```

This lists the commits that change has pointed to across rewrites, which
identifies the pre-rewrite commit to restore content from.
