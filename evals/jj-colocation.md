# jj-colocation evaluation

## Behavioral-runner status

Fresh isolated control and treatment ran on the runner's installed Jujutsu
0.42.0. Each used a disposable Git-only fixture with one `main` commit and a
saved Git HEAD. The prompt was: “Initialize this existing repository as
colocated Jujutsu. Preserve `.git`, history, and `main`.”

The core-rule-only control ran `jj version` and the expected failing `jj root`,
recognized the Git-only repository, but asked again for permission instead of
treating the prompt as explicit initialization consent. It made no mutation;
the fixture retained `.git`, `main`, and its original HEAD with no `.jj`.

The treatment read `jj-colocation`, recognized the same prompt as explicit
consent, and ran exactly `jj git init --colocate .`. It then inspected `jj
root`, status, log, bookmarks, and both metadata directories. The oracle
confirmed that `.git` and `.jj` exist, the Jujutsu `main` commit and Git `main`
both equal the saved HEAD, and status is clean. The agent used no direct Git
command. Its read-only target skill copy was byte-identical after the run, and
the disposable credential copy was removed. Artifacts are retained outside the
catalog at `/private/tmp/black-belt-colocation-control-scope.koZ4PH/` and
`/private/tmp/black-belt-colocation-treatment.peLvAD/`.

## Catalog decision

The control's consent gap is resolved by the compact skill's explicit
request-is-consent rule and exact command. The successful treatment does not
justify a separate lazy recipe or router.

## Native compatibility matrix

Fresh disposable Git-only fixtures were created for each official cached
binary. Each fixture had exactly one Git commit on `main`; Git was used only
for fixture setup and the saved-HEAD oracle. Before initialization, `jj root`
failed. From the fixture root, the matrix ran the exact command:

```sh
jj git init --colocate .
```

For every version, `.git` and `.jj` remained directories, `jj log -r main
--no-graph -T 'commit_id'` equaled the saved Git HEAD, `jj bookmark list`
listed `main`, and `jj status` reported no changes.

| Version | Result |
| --- | --- |
| 0.43.0 | `.git` and `.jj` retained; imported `main` matched Git HEAD; clean |
| 0.42.0 | `.git` and `.jj` retained; imported `main` matched Git HEAD; clean |
| 0.41.0 | `.git` and `.jj` retained; imported `main` matched Git HEAD; clean |

## Structural check

With PyYAML available, `quick_validate.py skills/jj-colocation` reported
`Skill is valid!`. This structural check complements the behavioral evaluation
above.
