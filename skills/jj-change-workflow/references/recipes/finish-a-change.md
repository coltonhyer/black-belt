# Finish an ordinary change

Use this for a single local change that the user explicitly says is finished.
Follow the repository preflight first.

```sh
jj status
jj log -r '@ | @-'
# edit the requested files
jj diff
jj describe -m 'meaningful description'
jj new
jj status
jj log -r '@ | @-'
```

`jj describe -m` describes `@`. `jj new` makes a new empty change whose
default parent is `@` and edits that new change in the working copy.

Verify the new `@` is empty, `@-` has the requested description, and
`jj diff -r @- --name-only` lists only the intended paths. Use a targeted
`jj file show -r @- path` when file content matters.
