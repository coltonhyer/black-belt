---
name: jj-publish
description: Use when fetching, tracking bookmarks, pushing Jujutsu changes, or preparing changes for a pull request on a Git host.
---

# Publish Jujutsu changes

A bookmark is a named pointer to a revision, not a mutable branch checkout.
Choose the completed revision explicitly; do not assume `@` is the change to
publish. A pushed bookmark is the handoff for creating a pull request in the
host's own interface.

## Publish one completed change

1. Inspect the intended completed revision, its description, and its diff. If
   `@` is an empty successor, select `@-` deliberately; otherwise ask rather
   than publishing a guessed revision.
2. Fetch the named remote before deciding what may move:

   ```sh
   jj git fetch --remote origin
   ```

   Inspect the local bookmark, its `@origin` remote-tracking bookmark when it
   exists, and the selected revision. Resolve bookmark conflicts or an
   unexpected remote move before pushing.
3. Point only the requested bookmark at the selected revision, then review the
   exact bookmark target and its diff:

   ```sh
   jj bookmark set feature/one -r @-
   jj log -r 'feature/one | @-'
   jj diff -r feature/one
   ```

4. Use a targeted dry run, then the same targeted push:

   ```sh
   jj git push --remote origin --dry-run --bookmark feature/one
   jj git push --remote origin --bookmark feature/one
   ```

   The targeted push establishes remote tracking for a new bookmark. Do not
   replace safety failures with Git force-pushes, broad push options, or
   `--all`; fetch, inspect the remote movement, and resolve the disagreement
   first.
5. Fetch again and verify both the local and remote-tracking pointers name the
   intended revision:

   ```sh
   jj git fetch --remote origin
   jj log -r 'feature/one | feature/one@origin | @-'
   ```

Keep host-specific pull-request creation out of this workflow; the pushed
bookmark name is the head branch to hand to the host's own CLI or web
interface. Use `jj-docs` for installed-version command syntax or an
unfamiliar push safety failure.
