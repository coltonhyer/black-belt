# jj-change-workflow evaluation

## Fresh isolated control — 0.42.0

The control used a new disposable, non-colocated Jujutsu repository with
committed `app.txt` containing `hello` and an empty `@`. It ran with a fresh
`CODEX_HOME` containing authentication only, `--ignore-user-config`, and only
the fixture's core Jujutsu rule. `jj-change-workflow` and `jj-docs` were not
available. Prompt:

> Change the greeting to `hello black belt`, finish it as `Update greeting`,
> and leave a fresh empty working-copy change.

It ran the required preflight, found and edited `app.txt`, then used the
allowed equivalent `jj commit -m 'Update greeting'`. It verified `jj status`,
`jj log -r '@ | @-'`, and `jj diff -r @- --stat`; it used neither Git
add/commit nor a bookmark. Oracle output was `true`, `Update greeting`,
`hello black belt`, and `app.txt`.

The first colocated isolated attempt is excluded: the host sandbox makes
`.git/objects` read-only. The non-colocated fixture is the valid control.
Because the valid control completed the ordinary workflow without the target
skill, the optional recipe/router is not earned and is absent.

## Version route

After removing the optional files, the existing fresh 0.43.0, 0.42.0, and
0.41.0 ordinary-change fixtures were rechecked with:

```sh
jj -R "$REPO" log -r @ --no-graph -T 'empty ++ "\n"'
jj -R "$REPO" log -r @- --no-graph -T 'description.first_line() ++ "\n"'
jj -R "$REPO" file show -r @- app.txt
jj -R "$REPO" diff -r @- --name-only
```

| Version | `@` empty | `@-` description | parent content | paths |
| --- | --- | --- | --- | --- |
| 0.43.0 | `true` | `Update greeting` | `hello black belt` | `app.txt` |
| 0.42.0 | `true` | `Update greeting` | `hello black belt` | `app.txt` |
| 0.41.0 | `true` | `Update greeting` | `hello black belt` | `app.txt` |

## Structural check

```text
quick_validate.py skills/jj-change-workflow -> Skill is valid!
test ! -e skills/jj-change-workflow/references/recipes.md -> passed
test ! -e skills/jj-change-workflow/references/recipes/finish-a-change.md -> passed
```
