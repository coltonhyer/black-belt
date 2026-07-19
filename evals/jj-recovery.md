# jj-recovery evaluation

## Behavioral-runner status

Fresh isolated control and treatment runs passed on Jujutsu 0.42.0. Each used
a disposable non-colocated repository with `base → A → B → empty @`, then
`jj abandon <A_ID>` as the immediately prior operation. The prompt was:
“The immediately previous operation accidentally abandoned `<A_ID>`. Restore
the repository to just before it without recreating files manually.”

The control used the core rule only. It inspected the operation log, ran one
`jj undo`, and restored `A`, its file, and the `B → A → base` graph with a
clean working copy.

The treatment read this skill, confirmed that the latest operation was the
abandon, and inspected the prior state with `jj --at-op <prior-operation>`.
An initial current-state revset for the now-absent change failed harmlessly;
the agent then used the prior operation, ran one `jj undo`, and verified the
restored change, `a.txt`, graph, and clean working copy. The read-only target
skill copy was byte-identical after the run, and the disposable credential copy
was removed.

## Catalog decision

The required top-level skill is present under the catalog policy. No observed
control gap earned a recipe or router, so `skills/jj-recovery/references/` is
absent.

## Local compatibility and structural checks

The native immediate-undo route passed in fresh non-colocated fixtures using
the pinned official binaries. Each fixture used the stated topology, captured
`A_ID`, abandoned A, then ran one `jj undo`. The oracle ran `jj log -r
"all() & $A_ID" --count`, `jj log -r '::@' --no-graph`, `jj file show -r @
a.txt`, `jj file show -r @ b.txt`, and `jj op log -n 1` from the fixture root.

| Version | Result |
| --- | --- |
| 0.43.0 | A count `1`; `B → A → fixture: base → empty @`; files `A` and `B`; latest operation `undo` |
| 0.42.0 | A count `1`; `B → A → fixture: base → empty @`; files `A` and `B`; latest operation `undo` |
| 0.41.0 | A count `1`; `B → A → fixture: base → empty @`; files `A` and `B`; latest operation `undo` |

Every matrix run ended with `jj status` clean and a targeted `jj diff -r @`.
The bundled `quick_validate.py skills/jj-recovery` ran offline with cached
PyYAML and reported `Skill is valid!`. These checks do not replace the blocked
behavioral evaluation.
