# jj-publish evaluation

## Behavioral-runner status

Fresh isolated core-rule control and skill treatment ran on the runner's
installed Jujutsu 0.42.0. Each used a disposable non-colocated repository, a
local bare `origin`, pushed `main`, a described feature at `@-`, and empty
`@`. The prompt was:

> Publish completed `@-` as `feature/one` to origin. Fetch first, show a dry
> run, then push. Do not publish empty `@`.

The core-only control completed the safe target-only flow: it inspected `@-`,
fetched `origin`, created `feature/one` at `@-`, dry-ran the targeted push,
pushed that bookmark, fetched again, and verified the
remote-tracking bookmark. The oracle confirmed local `feature/one`,
`feature/one@origin`, and the bare remote ref all matched the completed change,
while empty `@` remained distinct and clean. The trace contains no `--all`,
force option, or direct Git command.

The treatment read `jj-publish`, used `jj bookmark set feature/one -r @-`, and
performed the same fetch, targeted dry-run, targeted push, and final remote
verification. Its independent oracle passed with the same pointer and empty-@
invariants. The read-only target skill copy was byte-identical after the run,
and the disposable credential copy was removed. Artifacts are retained outside
the catalog at `/private/tmp/black-belt-publish-control.yXNyaQ/` and
`/private/tmp/black-belt-publish-treatment.3zEF1e/`.

No recipe or router is included: the fresh control completed the workflow
without a narrow drill-down gap, and the treatment confirms the compact skill.

## Native compatibility matrix

Fresh local bare-remote fixtures ran the same target-only sequence on each
pinned binary:

```sh
jj git fetch --remote origin
jj bookmark set feature/one -r @-
jj git push --remote origin --dry-run --bookmark feature/one
jj git push --remote origin --bookmark feature/one
jj git fetch --remote origin
```

The oracle required local `feature/one`, `feature/one@origin`, and the bare
remote `refs/heads/feature/one` to equal the completed feature commit, while
empty `@` differed. Each dry run left `refs/heads/feature/one` absent; after
the targeted push, no bare remote ref pointed at empty `@`.

| Version | Result |
| --- | --- |
| 0.43.0 | All three feature pointers matched the completed feature; `@` remained empty and distinct. |
| 0.42.0 | All three feature pointers matched the completed feature; `@` remained empty and distinct. |
| 0.41.0 | All three feature pointers matched the completed feature; `@` remained empty and distinct. |

## Structural check

`quick_validate.py skills/jj-publish` reported `Skill is valid!`.
`skills/jj-publish/references/` is intentionally absent.
