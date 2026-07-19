---
name: jj-docs
description: Use when exact Jujutsu command syntax, flags, configuration, feature maturity, or version-specific behavior must be resolved.
---

# Version-aware Jujutsu documentation

Installed behavior is the authority; a command name alone is not proof that it
works.

## Authority order

1. `jj version`.
2. Installed `jj help <command>` and `jj help -k <topic>`.
3. Generated `jj util markdown-help` and `jj util config-schema`.
4. Exact-version web documentation.
5. `/latest/` documentation for discovery only.

## Resolve a version-sensitive question

1. Record `jj version`, then inspect the installed help or generated surface.
2. Treat experimental, deprecated, and stub markers as behavior constraints.
   A help entry can exist without being safe or implemented.
3. Preserve the real repository while uncertain: do not run an unvalidated or
   mutating command there. Use a fresh scratch repository only when help is
   insufficient or the behavior is experimental, stubbed, or mutating.
4. State the result as supported, unsupported, or unvalidated for that exact
   version. Do not replace an unavailable command with a Git loop.

Validate default workflows across the rolling supported window: latest
validated minor `N`, `N-1`, and `N-2`. A version-specific variant needs a
capability probe and fallback.

For a command-maturity decision, use
[the maturity-check recipe](references/recipes/check-feature-maturity.md).
For all other documentation questions, use
[the recipe index](references/recipes.md).
