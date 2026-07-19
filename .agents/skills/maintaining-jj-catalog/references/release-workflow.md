# Jujutsu catalog release workflow

Use this procedure only in the Black Belt repository. It maintains recipes;
it does not download binaries, generate recipes, or alter an unrelated
repository.

## 1. Establish the support window

The new window is `N/N-1/N-2` (for example, `0.43/0.42/0.41`). Begin and end
each maintenance session with Jujutsu state checks:

```sh
jj version
jj root
jj status
```

Get the release archive and its checksum from the official Jujutsu release
page, then compare the downloaded archive locally. Record the release URL and
the verified checksum with the affected recipe evidence:

```sh
shasum -a 256 jj-"$VERSION"-"$PLATFORM".tar.gz
```

Do not treat a checksum copied from an untrusted mirror as upstream evidence.

## 2. Capture what the three binaries actually expose

Use pinned, checksum-verified binaries. Capture their generated surfaces in a
temporary directory; never add captures or binaries to the catalog.

```sh
tmp=$(mktemp -d "${TMPDIR:-/tmp}/jj-catalog-surface.XXXXXX")
for version in 0.43 0.42 0.41; do
  .agents/skills/maintaining-jj-catalog/scripts/capture-jj-surface.sh \
    "/path/to/jj-$version" "$tmp/$version"
done
```

The capture records exact `version`, `util markdown-help`, `util
config-schema`, and help-keyword output for revsets, filesets, templates, and
config. Compare only relevant files and sections, alongside upstream release
notes:

```sh
diff -u "$tmp/0.42/revsets.txt" "$tmp/0.43/revsets.txt"
diff -u "$tmp/0.42/config-schema.json" "$tmp/0.43/config-schema.json"
```

Release notes point to candidates; generated help and a scratch run establish
the behavior. Do not paste either source wholesale.

For a candidate command or config key, query its exact heading or key and cap
the output; never scan a whole surface with broad terms. Run expected-negative
probes one version at a time, outside an all-or-nothing `set -e` chain, and
record their exit and concise output before choosing a fallback.

## 3. Map and exercise an observed change

Find only recipes that name the changed command, config key, revset, fileset,
template, or affected workflow. Build a fresh disposable repository for each
candidate and execute the recipe's documented success path and its fallback.
Keep the command transcript, installed version, and oracle outside the
catalog's public guidance.

For a maintenance control/treatment, make a disposable synthetic catalog with
one affected `jj-run` recipe and a hashed unrelated recipe. Supply all three
release/help surfaces and binaries. The control must compare upstream and
generated surfaces, scratch-test the affected behavior, add a range/probe/
fallback/removal condition/link, and inspect its diff. A treatment that skips
one of those facts is a failed evaluation, not evidence of success. If an
isolated Codex evaluator cannot run, record that limitation and the commands
that did run; never invent a control or treatment result.

## 4. Make the smallest evidence-backed edit

Edit only an observed gap. A version-specific recipe addition states:

- the validation range (`0.43–0.41`, or the narrower observed range);
- a probe that detects the capability before relying on it;
- a safe fallback for supported binaries lacking it;
- the removal condition when the compatibility path has an expiry; and
- a direct upstream release, documentation, or issue link.

Use `version-deltas/` only if one behavior affects multiple recipes. Keep a
single-recipe difference beside that recipe. Remove deprecated spellings from
generated guidance, while accepting them in compatibility logic until every
supported version no longer needs them. Router entries remain one line; shard
category indexes before a router grows to about 100 entries.

## 5. Run evidence gates

Run the applicable structural validator (for example, the cached PyYAML
validator when available), then a scratch behavior check for every changed
recipe on `N`, `N-1`, and `N-2`. Check direct upstream links, and run host
discovery/read-only invocation checks for the repository-only skill without
asserting progressive disclosure where a host trace cannot prove it. Record
facts, versions, command exits, and limitations concisely in the matching
evaluation.

Before and after a checkpoint, inspect only the intended release change:

```sh
jj status
jj diff --stat
jj diff
jj log -r '::@' -n 14 --no-graph
```

After all gates pass, describe and advance with Jujutsu:

```sh
jj describe -m "docs: maintain Jujutsu catalog for $VERSION"
jj new
jj status
```

If the colocated backend refuses a write, do not force a checkpoint. Report
the verified files and the backend error instead.
