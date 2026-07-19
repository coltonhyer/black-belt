# jj-conflicts evaluation

## Valid isolated controls — 0.42.0

The root-run, non-colocated merge-resolution control received only the core
Jujutsu rule. In a fresh two-parent conflict, it inspected the conflict
directly through Jujutsu conflict markers (an allowed equivalent to listing
conflicted paths), set `config.txt` to `color=purple`, retained both parents,
described the merge `Resolve color`, and verified no conflict remained.

A fresh second carried-conflict control was read-only. It reported
`config.txt` as conflicted and left the graph and operation unchanged.

The original colocated runner failure is invalid harness evidence: the sandbox
could not write the Git backend. It is not a RED.

## Catalog decision

The valid controls completed the advertised conflict work with the core rule
alone. Under the revised catalog policy, this earns the compact top-level
skill and its evidence record, not a recipe, router, or operation-specific
instructions. `skills/jj-conflicts/references/` is absent.

## Copied-skill treatment — 0.42.0

A fresh non-colocated treatment received only the core rule and a read-only
copy of `jj-conflicts`. In a two-parent red/green merge conflict, the prompt
required `config.txt` to be exactly `color=purple`, both parents preserved,
and the description `Resolve color`.

The trace ran `jj version`, `jj root`, `jj status`, read the copied skill,
inspected parents, descendants, and conflict markers, edited the file
directly, ran `jj describe`, and verified status, diff, and log without any
Git executable command. A broad `jj file show -r parents(@)` first failed
because that revset has two parents; the treatment inspected each parent
separately and completed safely.

The final oracle found two parents, `conflicts() & @` equal to 0, no
descendant conflicts, description `Resolve color`, `config.txt` equal to
`color=purple`, and the copied target unchanged. Post-resolution `jj status`
correctly showed the resolution as a modification in the current Jujutsu
change; it was not clean.

## Compatibility evidence

The native default route was exercised in fresh non-colocated fixtures with
the pinned official binaries. Each run listed `config.txt` as a two-sided
conflict, resolved it by editing the marker file, and verified both the
resolved revision and its descendants.

| Version | Parents | `conflicts() & @` | Description | `config.txt` | Descendant conflicts |
| --- | --- | --- | --- | --- | --- |
| 0.43.0 | 2 | 0 | `Resolve color` | `color=purple` | 0 |
| 0.42.0 | 2 | 0 | `Resolve color` | `color=purple` | 0 |
| 0.41.0 | 2 | 0 | `Resolve color` | `color=purple` | 0 |

## Structural check

The bundled `quick_validate.py skills/jj-conflicts` ran with PyYAML and
reported `Skill is valid!`. No recipe, router, or `references/` directory
exists.
