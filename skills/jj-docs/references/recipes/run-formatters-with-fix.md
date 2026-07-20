# Run formatters with jj fix

## Use when

Formatting or another mechanical tool must be applied across one or more
revisions, not just the working copy.

## Inspect first

Record `jj version`, then run `jj help fix`. `jj fix` rewrites the revisions it
touches, so treat it as a mutating stack operation, and confirm the configured
`fix.tools` before relying on it.

## Version-sensitive behavior

`jj fix` runs configured tools over a revset and rewrites affected revisions;
descendants are rewritten like any other stack edit. Confirm the exact flag and
config spelling on the installed version with `jj help fix`, because the tool
configuration schema can change between releases.

## Recipe

1. Inspect the target revset and its descendants, and the current diff, before
   running anything.
2. Confirm `fix.tools` runs non-interactively; a formatter that prompts blocks
   the whole command.
3. Run `jj fix -s <revset>` (default is the working copy). It rewrites each
   matched revision in place.
4. Inspect the rewritten subgraph for changed commit IDs and any new conflicts,
   exactly as with other stack edits.

## Verify

Compare the diff of each rewritten revision and check `jj status` and a targeted
`jj log`. For catalog guidance, repeat on 0.43.0, 0.42.0, and 0.41.0.

## If the result is wrong

Do not force past it. Use `jj-recovery` to inspect `jj op log` and undo or
restore the operation, then re-check the tool configuration.

## Live documentation

Use the [upstream CLI reference](https://jj-vcs.github.io/jj/latest/cli-reference/)
and [upstream changelog](https://github.com/jj-vcs/jj/blob/main/CHANGELOG.md)
to locate an exact-version source, then treat installed help as authoritative.
