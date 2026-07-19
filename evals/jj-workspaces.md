# jj-workspaces evaluation

## Behavioral-runner status

Fresh isolated core-rule control and skill treatment both passed on the
runner's installed Jujutsu 0.42.0. Each disposable non-colocated fixture had a
committed `fixture: base` and an empty primary `@`; the prompt requested a
sibling `../review` workspace named `review`, on the same parent with distinct
empty working-copy changes.

The core-only control inspected Jujutsu state and workspace help, created the
native workspace, and verified clean status in both directories plus the
workspace list. It made two harmless failed template attempts using a
nonexistent `workspace` keyword before completing the required outcome. The
oracle confirmed both names, distinct empty `@` change IDs, and one shared
parent. No Git worktree, clone, or directory-copy command appeared in the
trace.

The treatment read `jj-workspaces`, checked installed `workspace add` help and
the existing workspace list before mutation, then created and checked both
workspaces. It verified distinct change IDs and the shared parent in each
directory. Its read-only target skill copy was byte-identical after the run,
and the disposable credential copy was removed. Artifacts are retained outside
the catalog at `/private/tmp/black-belt-workspaces-control.qr7ZcT/` and
`/private/tmp/black-belt-workspaces-treatment.pDTQXE/`.

No recipe or router is present: the fresh control completed the task without a
guidance gap that merits lazy drill-down.

## Native compatibility matrix

Fresh disposable non-colocated fixtures used a committed `fixture: base` and
an empty primary `@`. Each ran native `jj workspace add --name review
../review`, then checked `workspace list`, `status` in both directories, each
workspace's `@` change ID plus `empty`, and each `@-` commit ID.

| Version | Result |
| --- | --- |
| 0.43.0 | `default` and `review` listed; distinct empty `@` changes; same parent |
| 0.42.0 | `default` and `review` listed; distinct empty `@` changes; same parent |
| 0.41.0 | `default` and `review` listed; distinct empty `@` changes; same parent |

Every fixture reported both working copies clean. The oracle required both
names in `jj workspace list`, unequal `@` change IDs, `empty` equal to `true`
for each, and equal `@-` commit IDs.

## Structural check

`quick_validate.py skills/jj-workspaces` reported `Skill is valid!` with
cached PyYAML in the final local checks.
No `references/recipes.md` or recipe leaf exists.
