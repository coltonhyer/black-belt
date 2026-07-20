# Manage config safely

## Use when

A Jujutsu setting must be read or changed — for example a diff editor, merge
tool, or the `immutable_heads()` revset alias — without opening an interactive
editor.

## Inspect first

Record `jj version`, then run `jj help config` and `jj help -k config`. Config
keys and their scopes (`--user`, `--repo`) can differ between releases, so
confirm the exact key and scope on the installed version before writing.

## Version-sensitive behavior

`jj config` exposes `get`, `list`, `path`, `set`, and `unset`, which are all
non-interactive. `jj config edit` opens an editor and must not be used by an
agent. Setting `ui.diff-editor`, `ui.merge-editor`, or `revset-aliases` changes
how later commands behave, so read the current value before overwriting it.

## Recipe

1. Read the current state: `jj config list <prefix>` or `jj config get <key>`,
   and `jj config path` to see which file a scope resolves to.
2. Change one key at a time with an explicit scope: `jj config set --repo <key>
   <value>` or `jj config set --user <key> <value>`. Use `jj config unset` to
   remove a key. Never run `jj config edit`.
3. Re-read the key with `jj config get <key>` to confirm the written value.

## Verify

Confirm the effective value with `jj config get`, and exercise the affected
command (for example a non-blocking `jj diff`) to confirm the setting behaves as
intended. For catalog guidance, repeat on 0.43.0, 0.42.0, and 0.41.0.

## If the result is wrong

Unset or reset the specific key you changed rather than editing the file blind,
then re-read it. Do not leave an interactive editor or merge tool configured as
the default for an agent session.

## Live documentation

Use the [upstream CLI reference](https://jj-vcs.github.io/jj/latest/cli-reference/)
and [upstream config guide](https://jj-vcs.github.io/jj/latest/config/) to
locate an exact-version source, then treat installed help as authoritative.
