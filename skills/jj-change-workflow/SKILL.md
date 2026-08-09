---
name: jj-change-workflow
description: Use when creating, describing, inspecting, or completing an ordinary local change in a Jujutsu repository.
---

# Ordinary Jujutsu changes

The working copy is a change: `@` names the change being edited, not an
untracked staging area. Its change ID remains stable while its commit ID can
change as it is rewritten. `@-` is its parent.

Every command re-snapshots `@` from the working directory, so its content is
whatever is on disk — including files written by other tools or agents. Ignore
rules are versioned: a path ignored by one revision's `.gitignore` is
auto-tracked under any revision whose rules do not cover it, older or newer.
Keep agent scratch paths in an unversioned ignore source instead —
`.git/info/exclude` when colocated, `.jj/repo/store/git/info/exclude` when not
— set before those files appear, because ignoring a path never untracks it.

## Single-change loop

1. Follow the repository's Jujutsu preflight, then inspect `jj status` and
   `jj log -r '@ | @-'` before selecting the intended change.
2. Before the first edit, confirm `@` is yours to write into. If `jj status`
   shows `@` already carries a description, a bookmark, or a remote-tracking
   name, it is a finished or published change: run `jj new` before touching
   any file. There is no unstaged state to review first — the next command
   snapshots your edit straight into `@` and silently amends it.
3. Edit only the requested paths. Inspect `jj diff` before describing it.
4. Use `jj describe -m 'concise changeset description'` for the current `@`.
   Pass subsequent `-m` flags for additional paragraphs when the change needs
   body text.
5. When the change is complete, start a fresh working-copy change with `jj
   new`, or use `jj commit -m 'concise changeset description'` in place of
   step 4 to describe and advance in one step. Treat handoff, pausing,
   reporting the change done, and publishing as complete. Never leave `@`
   parked on a change you consider finished: the next snapshot amends it
   silently.
6. Verify with `jj status`, `jj log -r '@ | @-'`, and a targeted diff. After
   `jj new`, inspect `@-` to verify the completed change and `@` to verify it
   is empty.

Do not add a bookmark for local completion alone.

## Describe versus commit

`jj describe` names `@` and keeps it active. `jj commit` combines describe
with `jj new`, finalizing `@` and starting a fresh working-copy change, so it
suits a change that is already finished. When `@` has grown past one coherent
change, peel commits off with `jj commit <fileset> -m 'concise changeset
description'`: the named paths are finalized with that description and the
remaining edits stay in the new `@`. Repeat until `@` holds one coherent
change. Splitting a change already in history is stack editing, not this
loop.

## Scope

This is for one ordinary local change. Route stack edits, conflicts, recovery,
workspaces, and publishing to their specialized skills. Use `jj-docs` only
when installed help is needed to resolve version-specific behavior.
