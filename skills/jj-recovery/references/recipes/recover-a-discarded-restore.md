# Recover work discarded by `jj restore`

`jj restore <paths>` replaces those paths with another revision's content,
discarding uncommitted edits without a prompt. The content is not gone: every
command snapshots the working copy before acting, so the pre-restore state is
in the operation log.

Which recovery works depends on what ran after the restore. Check that first.

## The restore is the most recent operation

```sh
jj undo
jj status
```

Confirm the file's content, not merely that the command succeeded.

## Other commands ran after the restore

`jj undo` is the wrong tool here. It inverts the latest operation, which is
usually a `snapshot working copy`, and leaves the discarded content untouched
while reporting success.

1. Find the restore, and the snapshot recorded immediately before it:

   ```sh
   jj op log --limit 10
   ```

   Entries read newest first. `restore into commit <id>` is the destructive
   operation; the `snapshot working copy` listed directly below it holds the
   content as it stood just before.

2. Read that content without mutating anything:

   ```sh
   jj --at-op=<snapshot-operation> file show <path>
   ```

3. Write the recovered content back into the working copy, then verify:

   ```sh
   jj status
   jj diff
   ```

Steps 1 and 2 are read-only, so an incorrect guess about which operation to
inspect costs nothing. Confirm the content is the wanted version before
writing it back.

## Do not reach for `jj op revert` here

Reverting the restore operation reports success, but the working copy has
since moved to a different commit, so the files on disk do not change. It can
also leave the change that held the work divergent, which is a second problem
to resolve. Prefer the extraction above.
