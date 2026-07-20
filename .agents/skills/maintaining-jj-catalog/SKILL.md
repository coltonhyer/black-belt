---
name: maintaining-jj-catalog
description: Use when updating Black Belt for a new Jujutsu release, validating the supported version window, or repairing stale catalog recipes.
---

# Maintain the Jujutsu catalog

Repository-only release maintenance. Start with `jj version`, `jj root`, and
`jj status`; use Jujutsu for catalog history, diffs, and checkpoints.

For a new release, support `N`, `N-1`, and `N-2`. Verify upstream archive
checksums, capture each installed binary's generated surface, then compare
release/help/config changes only where they map to an existing recipe. See
[the release workflow](references/release-workflow.md) for commands and gates.

Exercise every affected recipe in a fresh disposable repository. Change only
an observed gap: state its validation range, probe, safe fallback, removal
condition when relevant, and upstream link. Do not copy release notes or help
wholesale, mutate unrelated recipes, or claim a validation that did not run.

Put a behavior shared by multiple recipes in `version-deltas/`; a one-recipe
change stays with that recipe. Generated guidance drops deprecated spellings,
but compatibility recognition remains while any supported version needs it.
Keep router entries to one line and shard a category index before it reaches
roughly 100 entries.

Before checkpointing, run structural, behavioral, three-version, link,
host-discovery, and manifest-sync gates. The shared metadata fields must agree
across all host manifests; run `scripts/check-manifest-sync.sh` to enforce it.
Inspect `jj status` and the targeted `jj diff`, then `jj describe` and `jj new`
only after the gates pass.
