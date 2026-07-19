# Check feature maturity

## Use when

A command appears in current documentation or installed help and you must know
whether this installed version can safely use it.

## Inspect first

Record `jj version`, then run `jj help <command>`. Use `jj help -k <topic>`
when the feature is named by concept rather than command. Consult generated
help or schema only when they answer the exact question.

## Version-sensitive behavior

Validated on 0.43.0, 0.42.0, and 0.41.0. In 0.42.0 and 0.41.0, `jj help run`
labels `jj run` a stub; it is unsupported even though help lists syntax. In
0.43.0, installed help describes a mutating command, so probe only in scratch.

## Recipe

1. Run `jj version` and `jj help <command>`.
2. If help says stub, experimental, deprecated, or otherwise lacks enough
   safety detail, report it unsupported or unvalidated; do not execute it in
   the real repository.
3. If the command is mutating or help is insufficient, recreate the needed
   state in a fresh scratch repository and exercise the smallest safe case.
4. Report the exact version, probe result, and a fallback that does not use a
   Git loop.

## Verify

Before and after any scratch exercise, compare its graph and relevant files.
For catalog guidance, repeat the probe on 0.43.0, 0.42.0, and 0.41.0.

## If the result is wrong

Stop using the command in the real repository, preserve state, and re-check
installed help. Then compare exact-version documentation; `/latest/` may only
help locate the relevant page.

## Live documentation

Use the [upstream CLI reference](https://jj-vcs.github.io/jj/latest/cli-reference/)
and [upstream changelog](https://github.com/jj-vcs/jj/blob/main/CHANGELOG.md)
to locate an exact-version source, then treat installed help as authoritative.
