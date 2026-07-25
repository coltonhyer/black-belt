# Split and move changes

Every form here is non-interactive. `jj split` with no fileset and
`jj squash -i` both open a diff editor and will block.

## Split one revision by path

Passing filesets is what makes `jj split` non-interactive — the matched paths
go into the first commit, the remainder stays in the second.

```sh
jj split -r <revision> 'src/parser/**' 'tests/parser/**'
jj log -r 'ancestors(@, 3)'
jj diff -r <revision>
```

Confirm both resulting revisions before continuing: the split is where a
partial selection quietly leaves work in the wrong change.

## Move a whole revision into another

```sh
jj squash --from <source> --into <destination>
```

Without `--from`/`--into`, `jj squash` moves `@` into its parent. With `-r`,
it moves the named revision into *its* parent and fails if that revision is a
merge.

## Move hunks to where they belong

`jj absorb` routes each hunk in the source revision to the closest mutable
ancestor that last modified those lines. Hunks it cannot place unambiguously
stay put.

```sh
jj absorb
jj log -r 'ancestors(@, 6)'
jj diff -r @
```

The source revision is abandoned if every hunk absorbed **and** the source had
no description. Verify where each hunk landed rather than assuming the routing
matched intent.

## Never reach for these

`jj squash -i` and `jj diffedit` open a diff editor. If only an interactive
edit can express the change, first confirm a non-interactive diff editor is
configured; do not launch a blocking tool.
