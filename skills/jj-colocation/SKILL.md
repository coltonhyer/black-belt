---
name: jj-colocation
description: Use when detecting, initializing, or operating a Jujutsu repository colocated with Git, including interaction with external Git tools.
---

# Jujutsu colocation

Keep Jujutsu as the repository interface. Colocation adds Jujutsu metadata to
an existing Git repository; it does not replace `.git`, its commits, or its
bookmarks.

Start with `jj version`, then `jj root`; if the root succeeds, also run `jj
status`. Distinguish the result before doing anything else:

- If `jj root` succeeds, it is a Jujutsu repository. If `.git` is also
  present, it is colocated; use Jujutsu for repository state and history.
- If `jj root` fails but `.git` exists, it is Git-only. Do not initialize it
  automatically. Obtain explicit consent, unless the request already clearly
  asks to initialize this repository as colocated Jujutsu.
- If `jj root` fails and `.git` is absent, neither repository is present.
  Report that state and initialize nothing unless asked.

With consent in a Git-only repository, inspect installed init help if the
syntax is uncertain, then run exactly:

```sh
jj git init --colocate .
```

Never delete or recreate `.git`, initialize a separate Jujutsu repository, or
rebuild Git history from files. Afterwards, inspect imported history and
bookmarks with `jj log` and `jj bookmark list`, then run `jj status`. Confirm
both `.git` and `.jj` remain.

Colocated workspaces import and export changes automatically. Use Git only
when a genuinely Git-only external tool is explicitly in scope; name that
boundary, then return to Jujutsu and inspect `jj status`, relevant `jj log`,
and bookmarks. Consult installed `jj help git import` and `jj help git export`
when a manual synchronization question is version-sensitive. Git is never a
silent substitute for Jujutsu state, history, or mutation commands.

Use `jj-docs` when installed behavior or external-tool synchronization is
uncertain.
