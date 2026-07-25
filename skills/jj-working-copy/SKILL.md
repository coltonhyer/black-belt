---
name: jj-working-copy
description: Use when generated or untracked files enter a change, a snapshot fails on file size, or ignore and tracking rules must be adjusted.
---

# The Jujutsu working copy

Jujutsu snapshots the working copy into `@` at the start of every command.
There is no staging area and no opt-in add step: by default
`snapshot.auto-track` is `all()`, so build output, caches, and test artifacts
join the change as soon as any `jj` command runs. Ignore rules are the only
thing that keeps them out.

## Before running a build or test suite

1. Inspect `jj status` and confirm which paths the tool will generate.
2. Add those paths to `.gitignore` before running the tool. A colocated
   workspace also honors `.git/info/exclude` for rules that should stay
   local.
3. Run the tool, then re-inspect `jj status` and `jj diff --stat` to confirm
   only intended paths entered the change.

## Remove a generated file already in the change

Order matters: `jj file untrack` refuses a path that is not already ignored.

1. Add the path to `.gitignore` first.
2. Untrack it by fileset:

   ```sh
   jj file untrack 'target/**'
   ```

3. Verify with `jj status` and a targeted `jj diff`. The file stays on disk;
   only its tracking stops.

Track a path that ignore rules currently exclude with
`jj file track <fileset>`.

## A snapshot fails on file size

`snapshot.max-new-file-size` defaults to `1MiB`, and a larger new file makes
the snapshot fail rather than silently including it. Treat that as a signal
that the path is generated. Ignore and untrack it. Raise the limit only when
a genuinely large file belongs in history, and say so explicitly rather than
adjusting the setting to make an error disappear.

Use `--ignore-working-copy` only to inspect state without snapshotting; it
does not fix an ignore-rule problem.

Route ordinary change work to `jj-change-workflow` and use `jj-docs` to
resolve installed-version behavior for tracking or snapshot configuration.
