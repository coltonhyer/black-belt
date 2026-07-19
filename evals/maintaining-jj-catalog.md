# maintaining-jj-catalog evaluation

## Capture harness

The POSIX test was written before its capture script. Its RED run exited
nonzero because `capture-jj-surface.sh` did not exist. After the minimal
script was added, the test passed with `jj 0.42.0`: all seven required outputs
were nonempty and `python3 -m json.tool` accepted `config-schema.json`. A
wrong-argument invocation exited 2 and printed the documented usage.

On 2026-07-19, the same capture script succeeded for pinned 0.43.0, 0.42.0,
and 0.41.0 binaries in
`/private/tmp/black-belt-maintenance-surfaces.mB3y2o`. Each produced seven
nonempty files with a valid schema. The focused 0.42-to-0.43 comparison found
the new usable `jj run` command and `run.jobs` configuration surface. A fresh
scratch repository confirmed that 0.43 `jj run` rewrote a revision; 0.42 and
0.41 exposed the documented non-working stub. The upstream candidate was the
[0.43.0 release](https://github.com/jj-vcs/jj/releases/tag/v0.43.0).

The capture implementation has no download, diff, recipe-generation, or
repository-mutation path. The cached skill validator, run with PyYAML, also
accepted the repository-only skill.

## Maintenance control

The control fixture was
`/private/tmp/black-belt-maintenance-control.Ey6AjT`. It changed only the
synthetic `jj-run` recipe and preserved the hashed unrelated recipe, but it
recorded only a range and availability statement. It omitted the required
capability probe, safe fallback, removal condition, upstream link, and scratch
execution. It is therefore a failed control, not evidence that the catalog
workflow was sufficient.

## Revised treatment

The first treatment stopped in a broad, all-or-nothing command chain before
editing the recipe. That observed failure added the focused-query and
one-version-at-a-time negative-probe guardrail to the release workflow.

The fresh retry was
`/private/tmp/black-belt-maintenance-treatment-retry.NGK4h6`. An isolated
Codex evaluator read the read-only source skill, narrowed the comparison to
`jj run`, and exercised all three pinned binaries in fresh repositories. It
updated exactly `skills/jj-run/references/recipes/run.md` with the 0.43–0.41
range, stub probe, safe fallback, removal condition, release link, and the
verified 0.43 archive SHA-256. It left the unrelated recipe hash unchanged:
`7ba39c713a0f0f5efb7d893c63dd0b72171b497a8bf16ff76760d93707b1c804`.

The evaluator could not snapshot or inspect its Jujutsu diff because its
sandbox denied writes to the fixture Git object store. It reported that
limitation and did not force a checkpoint. The host independently confirmed
the one-file Jujutsu diff, source immutability, and removal of the temporary
credential. Direct source-path reading exercises read-only invocation; host
discovery remains a catalog-wide release gate.
