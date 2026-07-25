# Split and move changes

These commands open **two** different editors, and avoiding one does not avoid
the other. A fileset suppresses the *diff* editor; only a message flag
suppresses the *description* editor. Omit either and the command aborts with
`Failed to edit description`, leaving the edit undone.

## Split one revision by path

A fileset selects content without the diff editor, but `jj split` still needs
a description for the commit it creates. Supply one with `-m`:

```sh
jj split -r <revision> -m 'description of the split-off change' 'src/parser/**'
jj log -r 'ancestors(@, 3)'
jj diff -r <revision>
```

`-m` describes the **selected** commit; the remainder keeps the original
revision's description. Without `-m`, a described revision cannot be split
non-interactively.

Confirm both resulting revisions before continuing: the split is where a
partial selection quietly leaves work in the wrong change.

## Move a whole revision into another

`jj squash` opens a description editor when the source **and** the destination
both have descriptions, because it must combine them. Say which description
survives:

```sh
jj squash --from <source> --into <destination> --use-destination-message
```

Use `-m '<combined description>'` instead when the result deserves new wording.
Neither flag is needed when the source has no description — the common case of
squashing an undescribed working copy into its parent.

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

`jj absorb` needs no message flag: it writes into existing revisions rather
than composing a new description.

## Never reach for these

`jj squash -i` and `jj diffedit` open a diff editor. If only an interactive
edit can express the change, first confirm a non-interactive diff editor is
configured; do not launch a blocking tool.
