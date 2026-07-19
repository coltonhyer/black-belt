# jj-stack-editing evaluation

## Valid isolated controls

The pinned 0.43.0 primary control used a fresh non-colocated fixture
`base → A → B → C → empty @`, with each change adding a separate file. It
received only the core Jujutsu rule; `jj-stack-editing` and `jj-docs` were not
available. It inspected the graph, used native `jj squash` to move B into A,
renamed the result `A+B`, and verified the rewritten stack. B was absent, C's
change ID was preserved, and the working copy was clean and empty above C.

A separate fresh 0.42.0 control, also with only the core rule, rebased B onto
the base in a `base → A → B → C → empty @` fixture. It preserved B and C
change IDs, left C and `@` above B, and reported no conflicts. This confirms
the stable identity/rewrite behavior independently of the squash control.

The original colocated-sandbox failure is invalid harness evidence: its
filesystem policy prevented writes to the Git backend. It is not a RED.

## Catalog decision

Both valid advertised-trigger controls completed without the target skill.
Under the revised catalog policy, the compact top-level skill remains a
catalog commitment, but no recipe, router, or operation-specific prose is
earned. `skills/jj-stack-editing/references/` is absent.

## Treatment status

A fresh 0.42.0 treatment used the core rule plus a readonly copied
`jj-stack-editing` skill on `base → A → B → C → empty @`. The prompt asked it
to squash captured B into captured parent A, name the result `A+B`, preserve C
above it, and keep empty `@` at the tip. The trace showed `jj version`, `jj
root`, `jj status`, the target-skill read, graph/diff inspection, installed
`jj squash --help`, native `jj squash -r B -m 'A+B'`, and no Git commands.

The target skill led the agent to verify the surviving graph. An intermediate
explicit B lookup returned “revision doesn’t exist,” as expected after the
squash, and it reran the surviving graph checks. The post-run oracle confirmed
B absent; C's change ID retained; C parent description `A+B`; empty `@`
directly above C; conflicts `0`; `a`/`b`/`c` content `A`/`B`/`C`; clean post
`jj status`; and the readonly copied skill identical to the source.

## Compatibility evidence

The default native squash route passed in fresh local copies with the pinned
official binaries:

| Version | Result |
| --- | --- |
| 0.43.0 | `A+B → C → empty @`; B absent, C identity retained, files `A/B/C`, conflicts `0` |
| 0.42.0 | `A+B → C → empty @`; B absent, C identity retained, files `A/B/C`, conflicts `0` |
| 0.41.0 | `A+B → C → empty @`; B absent, C identity retained, files `A/B/C`, conflicts `0` |

## Structural check

`quick_validate.py skills/jj-stack-editing` reports `Skill is valid!`. No
`references/recipes.md` or recipe leaf exists.
