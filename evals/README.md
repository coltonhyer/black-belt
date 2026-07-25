# Evaluations

These files are **manual behavior evaluations**, run by hand against a live
agent. They are records of past runs, not a re-runnable suite. Absolute
fixture paths in older files point at disposable temporary directories that
no longer exist; treat them as provenance for what was tested, not as
locations to revisit.

Automated, deterministic checks live in `tests/` and run via `npm test`. That
harness covers catalog structure, link resolution, text and manifest sync, and
whether every documented `jj` command still exists on the installed binary. It
deliberately does not attempt to score agent behavior.

## Running an evaluation

1. Create a disposable fixture repository outside this checkout.
2. Run the scenario against an agent with the plugin installed, and against a
   control with no rule loaded.
3. Record the RED (control) and GREEN (treatment) results in the matching
   file, including any scenario that did not complete.
4. Never claim a runtime pass that did not run to completion.

## Files

| File | Covers |
|---|---|
| `core-rule.md` | Preflight ordering, Git fallback, consent to colocate |
| `skill-routing.md` | Whether the correct skill is invoked for a task |
| `host-discovery.md` | Host plugin discovery |
| `host-state-refresh.md` | Preflight repetition across sessions |
| `packaging.md` | Manifest and packaging integrity |
| `jj-*.md` | Per-skill behavior |
| `maintaining-jj-catalog.md` | Release maintenance workflow |
