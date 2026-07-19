# jj-change-workflow evaluation

All behavioral fixtures received the core Jujutsu rule. `jj-docs` was not
provided. The pinned Jujutsu binaries were the checksum-verified 0.43.0,
0.42.0, and 0.41.0 archives used by `jj-docs`.

## RED — ordinary completion without the target skill

The 0.42.0 control used a disposable colocated repository with committed
`app.txt` containing `hello`, an empty `@`, and only the core rule. Prompt:

> Change the greeting to `hello black belt`, finish it as `Update greeting`,
> and leave a fresh empty working-copy change.

The control did not reach Jujutsu inspection or mutation: it stopped after
loading unrelated host process skills. Its final state remained `@` empty,
`@-` described `fixture: base`, and `app.txt` remained `hello`. It therefore
missed edit, `jj describe`, `jj new`, and parent/working-copy verification.
This primary failure earned the focused finish recipe; a second control was
not needed because the first did not pass.

## GREEN — target workflow

Treatment followed the target skill's ordinary-change loop on fresh fixtures:
preflight (`jj version`, `jj root`, `jj status`), inspect `@ | @-`, edit only
`app.txt`, `jj diff`, `jj describe -m 'Update greeting'`, `jj new`, then
status/log and targeted oracle. No Git add/commit and no bookmark were used.

| Version | `@` empty | `@-` description | `@-:app.txt` | changed paths |
| --- | --- | --- | --- | --- |
| 0.43.0 | `true` | `Update greeting` | `hello black belt` | `app.txt` |
| 0.42.0 | `true` | `Update greeting` | `hello black belt` | `app.txt` |
| 0.41.0 | `true` | `Update greeting` | `hello black belt` | `app.txt` |

The post-`jj new` checks used:

```sh
jj log -r @ --no-graph -T 'empty ++ "\n"'
jj log -r @- --no-graph -T 'description.first_line() ++ "\n"'
jj file show -r @- app.txt
jj diff -r @- --name-only
```

The fixture command ran from each repository root; `jj file show` treats its
path argument relative to the current directory even when `-R` names the
same repository.

## Structural check

```text
quick_validate.py skills/jj-change-workflow -> Skill is valid!
wc -l -w -c skills/jj-change-workflow/SKILL.md -> 32 219 1409
```

The finish recipe is present because the failing baseline omitted the complete
finish loop. The skill body remains the router and invariant set; no broad
command reference was added.
