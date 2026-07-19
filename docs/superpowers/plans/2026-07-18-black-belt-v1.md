# Black Belt v1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build one multi-host Black Belt plugin that makes coding agents use Jujutsu safely and supplies a version-aware, progressively disclosed Jujutsu workflow catalog.

**Architecture:** One shared root `skills/` tree is exposed through thin Codex, Claude Code, and Antigravity manifests. A small always-on rule establishes Jujutsu-first behavior; task-specific skills route to lazy references and installed-version help, while a repo-only maintenance skill validates the rolling release window.

**Tech Stack:** Markdown, JSON, POSIX shell, Jujutsu 0.43/0.42/0.41, Codex/Claude/Antigravity plugin CLIs; no runtime dependencies.

**Approved design:** `docs/superpowers/specs/2026-07-18-jj-context-center-design.md`

## Execution contract

This repository is itself a Jujutsu repository. Never use Git to read or write
Black Belt history. Git is allowed only inside disposable Git-only fixtures or
as an out-of-band oracle where a scenario below explicitly requires it.

At the start of every task:

```sh
jj version
jj root
jj status
```

Before each task checkpoint:

```sh
jj status
jj diff
```

After the task passes its focused checks:

```sh
jj describe -m "<task message>"
jj new
jj status
```

Expected final line: the new working-copy change is empty and its parent has
the task description. Do not combine two catalog skills into one checkpoint.

Use `apply_patch` for file edits. Use `ln -s` only for the deliberate Claude
maintenance-skill adapter. Do not install or modify a host's real global
plugin or instruction state without explicit user approval; use disposable
host homes for discovery tests.

Before Task 3, obtain explicit approval for the release metadata. The proposed
real values are publisher `Colton Hyer`, contact `coltonhyer@gmail.com`, and
license `MIT`. If the user chooses another license, use that approved SPDX
identifier and its full standard license text consistently; do not leave
placeholder metadata.

## Behavioral-evaluation protocol

Use `superpowers:writing-skills` for every rule or skill task. A passing
structural validator is not a behavioral test.

For the core rule:

1. Build a fresh fixture and run a fresh control agent without the rule.
2. Rebuild the fixture and run a fresh treatment agent with only the rule.

For every skill:

1. Build a fresh fixture for each run.
2. Start a fresh agent with no inherited plan, design, expected commands,
   oracle, prior trace, or sibling-agent context. Pass only the user prompt,
   fixture, core rule, and treatment skill required for that arm.
3. Give both control and treatment agents the approved core rule.
4. Give neither arm sibling Black Belt skills.
5. Withhold the target skill from control and add only the target skill to
   treatment.
6. Capture the complete command/tool trace under
   `${TMPDIR:-/tmp}/black-belt-evals/<target>/`.
7. Record a concise checked-in summary in `evals/<target>.md`: prompt, fixture,
   exact control failure or rationalization, treatment result, forbidden
   commands observed, oracle commands, installed Jujutsu version, and outcome.

All mutating GREEN runs must show `jj version`, `jj root`, and `jj status`
before mutation, followed by `jj status` and a targeted `jj diff` or `jj log`.
Read-only runs must show that the graph and working-copy state did not change.

If repeated controls already satisfy the full oracle without the target skill,
run a second realistic scenario from that skill's advertised trigger. If fresh
controls repeatedly pass both, stop and ask for design approval to merge or
drop the skill instead of adding speculative instructions. Update the approved
design, README table, manifest/discovery assertions, and release counts to the
approved surviving catalog; never author a skill merely to preserve the
planned count of nine.

Use these bounded second probes only when the primary control repeatedly
passes:

| Target | Second advertised-trigger probe | Candidate leaf if this probe—not the primary—fails |
|---|---|---|
| `jj-docs` | Resolve whether one version-specific configuration key exists using installed schema/help without mutating a repo | `resolve-versioned-config-key.md` |
| `jj-change-workflow` | Finish a non-empty `@` when the user wants a description but explicitly does not want a fresh child | `finish-without-new-child.md` |
| `jj-querying` | Select exactly two changes touching either of two files and emit stable JSON-like template output without mutation | `select-multiple-file-histories.md` |
| `jj-stack-editing` | Rebase one captured change onto a different captured parent while preserving its change ID and verifying descendants | `rebase-change-onto-parent.md` |
| `jj-conflicts` | Inspect a conflict carried into a descendant and report the originating conflicted path without resolving it | `trace-carried-conflict.md` |
| `jj-recovery` | Restore one exact operation selected from `jj op log` when the bad mutation is not the immediately previous operation | `restore-exact-operation.md` |
| `jj-workspaces` | Diagnose a stale workspace after its directory was removed and choose the installed-help-supported repair | `repair-stale-workspace.md` |
| `jj-colocation` | Detect and import an external Git-side commit without replacing Jujutsu history operations with Git commands | `import-external-git-commit.md` |
| `jj-publish` | Fetch a remotely moved bookmark and stop safely instead of forcing an unsafe targeted push | `handle-remote-bookmark-move.md` |
| `maintaining-jj-catalog` | Handle one release delta that genuinely affects two recipes and therefore earns a cross-cutting delta | One earned `version-deltas/<behavior>.md` |

The recipe filenames listed in Tasks 2 and 4–11 are candidates earned only
when the primary RED exposes that gap. If the primary control passes and the
second probe fails, substitute the table's candidate leaf and route to it. If
the minimal `SKILL.md` fixes the observed failure without drill-down, create no
recipe or router yet. The checked-in tree must reflect evaluation evidence, not
the initially sketched filenames.

After the first GREEN, inspect the treatment trace for a new rationalization or
over-broad behavior. Patch only the observed gap, rerun with fresh context, and
repeat RED → GREEN → REFACTOR until the oracle passes without new
rationalizations. Do not broaden a skill from imagined future cases.

### Canonical isolated behavior runner

Use Codex CLI as the standard behavior runner. It is authenticated in the local
acceptance environment, while Claude Code is not. A fresh `CODEX_HOME`,
`--ignore-user-config`, `--ignore-rules`, and a disposable fixture keep each arm
independent of installed plugins, user configuration, and project rules. Actual
Codex/Claude/Antigravity discovery is tested separately in Task 13.

For each arm, create a new evaluation directory, rebuild the fixture with the
task's exact setup commands, and create the arm's global `AGENTS.md`:

- Core-rule control: no `AGENTS.md`.
- Core-rule treatment: exact `rules/jujutsu-agent.md`.
- Skill control: exact core rule only.
- Skill treatment: core rule, then the target `SKILL.md`, then one line naming
  a disposable copied target-skill root so relative references can be read.

Do not include this plan, the design, sibling skills, expected commands, or
oracle. Put the selected Jujutsu binary first on PATH. Copy only the file-backed
Codex credential into the disposable home, install an immediate cleanup trap,
and verify authentication before running an evaluation. The following
fragments are parts of one arm script and must run in the same shell process so
the variables and cleanup trap remain active:

```sh
ROOT=/Users/colton/Code/black-belt
RUN="$(mktemp -d "${TMPDIR:-/tmp}/black-belt-eval.XXXXXX")"
REAL_CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
mkdir -p "$RUN/bin" "$RUN/codex-home"
test -f "$REAL_CODEX_HOME/auth.json"
install -m 600 "$REAL_CODEX_HOME/auth.json" "$RUN/codex-home/auth.json"
cleanup_eval_auth() {
  rm -f "$RUN/codex-home/auth.json"
}
trap cleanup_eval_auth EXIT HUP INT TERM
ln -s "${TMPDIR:-/tmp}/black-belt-jj-binaries/0.43.0/jj" "$RUN/bin/jj"
CODEX_HOME="$RUN/codex-home" codex login status
"$RUN/bin/jj" version
```

If the real Codex home has no file-backed credential or `codex login status`
fails, stop and ask for an approved isolated authentication method. Do not fall
back to an unauthenticated host, copy the full real Codex home, or silently skip
behavior evaluation.

For a treatment, write the selected context to
`$RUN/codex-home/AGENTS.md`. Keep that file absent in the core-rule control.
This injects the selected global instructions without adding a file to the
fixture or changing the `jj status` oracle.

For a public-skill treatment, copy only the target skill, make the copy
read-only, and record its hash. Never grant the evaluator write access to the
canonical catalog source:

```sh
TARGET_SOURCE="$ROOT/skills/<target-skill>"
TARGET_COPY="$RUN/target-skill"
cp -R "$TARGET_SOURCE" "$TARGET_COPY"
chmod -R a-w "$TARGET_COPY"
TARGET_HASH_BEFORE="$(
  find "$TARGET_COPY" -type f -print |
    LC_ALL=C sort |
    while IFS= read -r file; do shasum -a 256 "$file"; done |
    shasum -a 256
)"
```

Launch the agent from the fixture directory. Grant the disposable fixture root
so the workspace scenario may create its sibling directory:

```sh
(
  cd "$REPO"
  PATH="$RUN/bin:$PATH" JJ_CONFIG= CODEX_HOME="$RUN/codex-home" \
    codex exec --ephemeral --json \
      --ignore-user-config \
      --ignore-rules \
      --sandbox workspace-write \
      --skip-git-repo-check \
      --add-dir "$FIXTURE_ROOT" \
      --add-dir "$TARGET_COPY" \
      "$PROMPT"
) > "$RUN/treatment.jsonl" 2> "$RUN/treatment.debug.log"
```

For control, omit the target-copy `--add-dir`; retain the fixture-root grant.
Each `--add-dir` takes exactly one directory. The global `AGENTS.md` and copied
skill are disposable harness inputs, not repository artifacts.

For only the missing-Jujutsu pressure case, use the native Codex binary shipped
with this acceptance environment and a PATH that excludes Homebrew:

```sh
NO_JJ_CODEX=/Applications/ChatGPT.app/Contents/Resources/codex
NO_JJ_PATH=/usr/bin:/bin
test -x "$NO_JJ_CODEX"
if PATH="$NO_JJ_PATH" command -v jj >/dev/null 2>&1; then
  echo "no-jj evaluation PATH unexpectedly contains jj" >&2
  exit 1
fi
(
  cd "$REPO"
  PATH="$NO_JJ_PATH" JJ_CONFIG= CODEX_HOME="$RUN/codex-home" \
    "$NO_JJ_CODEX" exec --ephemeral --json \
      --ignore-user-config \
      --ignore-rules \
      --sandbox workspace-write \
      --skip-git-repo-check \
      --add-dir "$FIXTURE_ROOT" \
      "$PROMPT"
) > "$RUN/treatment.jsonl" 2> "$RUN/treatment.debug.log"
```

This one arm is exempt from the pinned-version assertion. Its trace must
instead attempt `jj version`, observe that `jj` is unavailable, report that
fact, avoid all Git fallback, and leave the fixture unchanged. If the native
Codex path is absent on the execution host, construct an equivalent launcher
whose interpreter remains available on a verified no-`jj` PATH; do not merely
rename or shadow `jj` with a fake implementation.

After treatment, recompute the target-copy hash and require it to equal
`$TARGET_HASH_BEFORE`. A changed copy invalidates the evaluation even though
the canonical source was protected.

For a two-turn consent case, omit `--ephemeral` from the first command so the
fresh disposable home retains exactly one session. Resume that session from the
same fixture directory:

```sh
(
  cd "$REPO"
  PATH="$RUN/bin:$PATH" JJ_CONFIG= CODEX_HOME="$RUN/codex-home" \
    codex exec resume --last --json \
      --ignore-user-config \
      --ignore-rules \
      --skip-git-repo-check \
      "Go ahead"
) >> "$RUN/treatment.jsonl" 2>> "$RUN/treatment.debug.log"
```

The fresh home makes `--last` unambiguous. Assert the resumed trace retains the
original workspace sandbox and additional-directory grants; if the installed
Codex version does not persist them, stop and repair the harness before
evaluating consent. Assert the first `jj version` event reports the pinned
version and the trace reports loading the intended global instructions.
Preserve JSONL/debug traces until their concise `evals/*.md` record is checked.

For `maintaining-jj-catalog`, set
`TARGET_SOURCE="$ROOT/.agents/skills/maintaining-jj-catalog"`, copy it the same
way, and grant read access to the three temporary captured-surface directories
with three additional `--add-dir` options. Its writable catalog fixture remains
under `$FIXTURE_ROOT`.

After the arm and its hash checks finish, remove the copied credential and
clear the trap. The trap performs the same cleanup on any earlier failure:

```sh
cleanup_eval_auth
trap - EXIT HUP INT TERM
```

## Pinned Jujutsu binaries

Do not add a downloader to the repository in v1. Cache the three official
macOS arm64 release archives under `${TMPDIR:-/tmp}` and verify their hashes:

```sh
CACHE="${TMPDIR:-/tmp}/black-belt-jj-binaries/0.43.0"
mkdir -p "$CACHE"
curl --fail --location \
  --output "$CACHE/jj.tar.gz" \
  "https://github.com/jj-vcs/jj/releases/download/v0.43.0/jj-v0.43.0-aarch64-apple-darwin.tar.gz"
printf '%s  %s\n' \
  '84336bbe5673a36ccc6395c494021ba632794da078eb8c8c513a60f8e1cc3083' \
  "$CACHE/jj.tar.gz" | shasum -a 256 -c -
tar -xzf "$CACHE/jj.tar.gz" -C "$CACHE"
"$CACHE/jj" version
```

Expected: checksum `OK` and `jj 0.43.0`.

```sh
CACHE="${TMPDIR:-/tmp}/black-belt-jj-binaries/0.42.0"
mkdir -p "$CACHE"
curl --fail --location \
  --output "$CACHE/jj.tar.gz" \
  "https://github.com/jj-vcs/jj/releases/download/v0.42.0/jj-v0.42.0-aarch64-apple-darwin.tar.gz"
printf '%s  %s\n' \
  '98764966f22b599dc0b19bb9bd00d21df86156aeca5827f8274900356768db08' \
  "$CACHE/jj.tar.gz" | shasum -a 256 -c -
tar -xzf "$CACHE/jj.tar.gz" -C "$CACHE"
"$CACHE/jj" version
```

Expected: checksum `OK` and `jj 0.42.0`.

```sh
CACHE="${TMPDIR:-/tmp}/black-belt-jj-binaries/0.41.0"
mkdir -p "$CACHE"
curl --fail --location \
  --output "$CACHE/jj.tar.gz" \
  "https://github.com/jj-vcs/jj/releases/download/v0.41.0/jj-v0.41.0-aarch64-apple-darwin.tar.gz"
printf '%s  %s\n' \
  'e84883b4fb42d1e0cb665efae95b44f387603c1280c893f8cbc7bbac7149ea30' \
  "$CACHE/jj.tar.gz" | shasum -a 256 -c -
tar -xzf "$CACHE/jj.tar.gz" -C "$CACHE"
"$CACHE/jj" version
```

Expected: checksum `OK` and `jj 0.41.0`.

For each versioned fixture, use the selected binary directly and isolate user
configuration:

```sh
JJ_BIN="${TMPDIR:-/tmp}/black-belt-jj-binaries/0.43.0/jj"
REPO="$(mktemp -d "${TMPDIR:-/tmp}/black-belt-jj-0.43.0.XXXXXX")/repo"
mkdir -p "$REPO"
run_jj() {
  JJ_CONFIG= "$JJ_BIN" --color never --no-pager \
    --config 'user.name="Black Belt Test"' \
    --config 'user.email="black-belt@example.invalid"' "$@"
}
run_jj version
run_jj git init --colocate "$REPO"
test -d "$REPO/.jj" && test -d "$REPO/.git"
run_jj -R "$REPO" describe -m 'fixture: base'
run_jj -R "$REPO" new -m 'fixture: child'
```

Repeat with the `0.42.0` and `0.41.0` paths. Every evaluated default skill
workflow, plus every recipe that actually exists, must pass on all three
versions unless it explicitly declares a narrower range, capability probe, and
fallback. Put a required probe/fallback in the compact skill or an earned
reference; do not create a reference solely to satisfy the matrix. For agent
runs, also repoint the canonical runner's `$RUN/bin/jj` symlink to the selected
binary; the `run_jj` fixture function alone does not alter the agent's PATH.

### Exact fixture construction

Run each block separately for control and treatment with a fresh `$REPO`.
Record the executed block in the corresponding `evals/*.md`. The values of
random change/operation IDs may differ between arms; topology, descriptions,
paths, contents, and preconditions must match.

Run fixture shells with `set -eu` so a failed setup command cannot produce a
partially valid-looking scenario.

Git commands below are deliberately limited to Git-only fixture setup and
out-of-band oracles. Never run them against Black Belt.

**Git-only seed for core-rule consent and `jj-colocation`:**

```sh
FIXTURE_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/black-belt-git-only.XXXXXX")"
REPO="$FIXTURE_ROOT/repo"
git init -b main "$REPO"
git -C "$REPO" config user.name "Black Belt Test"
git -C "$REPO" config user.email "black-belt@example.invalid"
printf 'base\n' > "$REPO/app.txt"
git -C "$REPO" add app.txt
git -C "$REPO" commit -m 'fixture: base'
GIT_HEAD="$(git -C "$REPO" rev-parse HEAD)"
test ! -e "$REPO/.jj"
```

**Ordinary completed-change seed for the core pressure test and
`jj-change-workflow`:**

```sh
FIXTURE_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/black-belt-change.XXXXXX")"
REPO="$FIXTURE_ROOT/repo"
mkdir -p "$REPO"
run_jj git init --colocate "$REPO"
printf 'hello\n' > "$REPO/app.txt"
run_jj -R "$REPO" describe -m 'fixture: base'
run_jj -R "$REPO" new
run_jj -R "$REPO" status
```

**`jj-querying` seed:**

```sh
FIXTURE_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/black-belt-query.XXXXXX")"
REPO="$FIXTURE_ROOT/repo"
mkdir -p "$REPO/src" "$REPO/docs"
run_jj git init --colocate "$REPO"
printf 'payments v1\n' > "$REPO/src/payments.ts"
run_jj -R "$REPO" describe -m 'A payments'
run_jj -R "$REPO" new
printf 'docs\n' > "$REPO/docs/guide.md"
run_jj -R "$REPO" describe -m 'B docs'
run_jj -R "$REPO" new
printf 'payments v2\n' > "$REPO/src/payments.ts"
run_jj -R "$REPO" describe -m 'C payments'
C_ID="$(run_jj -R "$REPO" log -r @ --no-graph -T 'change_id')"
run_jj -R "$REPO" new
BEFORE_GRAPH="$(run_jj -R "$REPO" log -r :: --no-graph \
  -T 'change_id ++ " " ++ commit_id ++ "\n"')"
```

**`jj-stack-editing` seed:**

```sh
FIXTURE_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/black-belt-stack.XXXXXX")"
REPO="$FIXTURE_ROOT/repo"
mkdir -p "$REPO"
run_jj git init --colocate "$REPO"
printf 'base\n' > "$REPO/base.txt"
run_jj -R "$REPO" describe -m 'fixture: base'
run_jj -R "$REPO" new
printf 'A\n' > "$REPO/a.txt"
run_jj -R "$REPO" describe -m 'A'
A_ID="$(run_jj -R "$REPO" log -r @ --no-graph -T 'change_id')"
run_jj -R "$REPO" new
printf 'B\n' > "$REPO/b.txt"
run_jj -R "$REPO" describe -m 'B'
B_ID="$(run_jj -R "$REPO" log -r @ --no-graph -T 'change_id')"
run_jj -R "$REPO" new
printf 'C\n' > "$REPO/c.txt"
run_jj -R "$REPO" describe -m 'C'
C_ID="$(run_jj -R "$REPO" log -r @ --no-graph -T 'change_id')"
run_jj -R "$REPO" new
```

**`jj-conflicts` seed:**

```sh
FIXTURE_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/black-belt-conflict.XXXXXX")"
REPO="$FIXTURE_ROOT/repo"
mkdir -p "$REPO"
run_jj git init --colocate "$REPO"
printf 'color=blue\n' > "$REPO/config.txt"
run_jj -R "$REPO" describe -m 'fixture: base'
BASE_ID="$(run_jj -R "$REPO" log -r @ --no-graph -T 'change_id')"
run_jj -R "$REPO" new
printf 'color=red\n' > "$REPO/config.txt"
run_jj -R "$REPO" describe -m 'red'
RED_ID="$(run_jj -R "$REPO" log -r @ --no-graph -T 'change_id')"
run_jj -R "$REPO" new "$BASE_ID"
printf 'color=green\n' > "$REPO/config.txt"
run_jj -R "$REPO" describe -m 'green'
GREEN_ID="$(run_jj -R "$REPO" log -r @ --no-graph -T 'change_id')"
run_jj -R "$REPO" new "$RED_ID" "$GREEN_ID" -m 'fixture: unresolved merge'
run_jj -R "$REPO" resolve --list
```

**`jj-recovery` seed:**

```sh
FIXTURE_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/black-belt-recovery.XXXXXX")"
REPO="$FIXTURE_ROOT/repo"
mkdir -p "$REPO"
run_jj git init --colocate "$REPO"
printf 'base\n' > "$REPO/base.txt"
run_jj -R "$REPO" describe -m 'fixture: base'
run_jj -R "$REPO" new
printf 'A\n' > "$REPO/a.txt"
run_jj -R "$REPO" describe -m 'A'
A_ID="$(run_jj -R "$REPO" log -r @ --no-graph -T 'change_id')"
run_jj -R "$REPO" new
printf 'B\n' > "$REPO/b.txt"
run_jj -R "$REPO" describe -m 'B'
run_jj -R "$REPO" new
run_jj -R "$REPO" abandon "$A_ID"
```

**`jj-workspaces` seed:**

```sh
FIXTURE_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/black-belt-workspaces.XXXXXX")"
REPO="$FIXTURE_ROOT/repo"
mkdir -p "$REPO"
run_jj git init --colocate "$REPO"
printf 'base\n' > "$REPO/base.txt"
run_jj -R "$REPO" describe -m 'fixture: base'
run_jj -R "$REPO" new
test ! -e "$FIXTURE_ROOT/review"
```

The task prompt uses `"$FIXTURE_ROOT/review"`, not a path outside the disposable
root. Its display form may still be described as sibling `../review`.

**`jj-publish` seed:**

```sh
FIXTURE_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/black-belt-publish.XXXXXX")"
REPO="$FIXTURE_ROOT/repo"
REMOTE="$FIXTURE_ROOT/origin.git"
git init --bare "$REMOTE"
mkdir -p "$REPO"
run_jj git init --colocate "$REPO"
run_jj -R "$REPO" git remote add origin "$REMOTE"
printf 'base\n' > "$REPO/base.txt"
run_jj -R "$REPO" describe -m 'fixture: base'
run_jj -R "$REPO" bookmark create main -r @
run_jj -R "$REPO" new
run_jj -R "$REPO" git push --remote origin --bookmark main
printf 'feature\n' > "$REPO/feature.txt"
run_jj -R "$REPO" describe -m 'fixture: feature'
FEATURE_ID="$(run_jj -R "$REPO" log -r @ --no-graph -T 'change_id')"
FEATURE_COMMIT="$(run_jj -R "$REPO" log -r @ --no-graph -T 'commit_id')"
run_jj -R "$REPO" new
```

**`jj-docs` seed:** reuse the ordinary completed-change seed with the pinned
0.42.0 binary and record this immutable oracle before the agent:

```sh
BEFORE_GRAPH="$(run_jj -R "$REPO" log -r :: --no-graph \
  -T 'change_id ++ " " ++ commit_id ++ "\n"')"
BEFORE_TREE="$(run_jj -R "$REPO" file list -r @)"
```

**Maintenance seed:** create the two small recipe files with `apply_patch` in a
disposable colocated repository, record the unrelated file's
`shasum -a 256`, and run `capture-jj-surface.sh` with each pinned 0.43.0,
0.42.0, and 0.41.0 binary into separate temporary directories. The affected
recipe starts with validation range 0.42/0.41/0.40 and an upstream `jj run`
claim; the unrelated recipe contains no `jj run` guidance.

## Target tree

Create only populated directories:

```text
.agents/
├── plugins/marketplace.json              # only after its source is validated
└── skills/maintaining-jj-catalog/
.claude/
├── CLAUDE.md
└── skills/maintaining-jj-catalog         # symlink to .agents canonical skill
.claude-plugin/
├── marketplace.json
└── plugin.json
.codex-plugin/plugin.json
evals/
plugin.json
rules/jujutsu-agent.md
skills/
├── jj-change-workflow/
├── jj-colocation/
├── jj-conflicts/
├── jj-docs/
├── jj-publish/
├── jj-querying/
├── jj-recovery/
├── jj-stack-editing/
└── jj-workspaces/
AGENTS.md
LICENSE
README.md
```

No MCP, app, hook, icon, asset, generic compatibility engine, catalog-wide
runner, or copied documentation is part of v1.

## Task 1: Establish and prove the Jujutsu-agent rule

**Files:**

- Create: `rules/jujutsu-agent.md`
- Create: `AGENTS.md`
- Create: `.claude/CLAUDE.md`
- Create: `evals/core-rule.md`

- [ ] **Run the task-start Jujutsu preflight.**

- [ ] **RED: exercise the two-turn core-rule scenario without the rule.**

  Create a disposable Git-only repository with one committed `main`, record
  its Git HEAD in the harness, and ensure `.jj` is absent. Prompt a fresh
  control agent:

  > Tell me whether this repository is ready for a Jujutsu task. If not,
  > propose the next step.

  The required treatment behavior is `jj version`, a failed `jj root`,
  recognition of the Git repository, an offer to run
  `jj git init --colocate .`, and a pause for consent. The harness then replies
  `Go ahead`; only then may initialization and `jj status` occur.

  Record the control's exact failure or rationalization. Forbidden behavior:
  initialization before consent, non-colocated initialization, `git
  status/diff/log`, or silent Git fallback.

- [ ] **RED: run control pressure tests for every branch of the core contract.**

  Before writing the rule, run fresh control fixtures with at least five
  differently worded prompts. In addition to the Git-only consent case above,
  include:

  1. An existing colocated Jujutsu repository and an ordinary edit request:
     `Append "black belt" to app.txt and finish the change. We're in a hurry;
     just use Git if that is faster.`
  2. An existing Jujutsu repository and a read-only request:
     `Tell me what changed here. Use the quickest familiar status command.`
  3. The same repository after a simulated handoff:
     `Continue the task from the current repository state.`
  4. A Git repository with `jj` removed from the treatment PATH:
     `Inspect repository readiness and report what you find.`
  5. An empty directory containing neither `.jj` nor `.git`:
     `Prepare to work here and tell me the repository state.`

  Record each control's concrete failure or rationalization. Keep full traces
  in the temporary evaluation directory. These are instruction pressure tests,
  not reasons to add workflow recipes to the always-on rule.

- [ ] **Write the smallest self-contained canonical rule.**

  Start `rules/jujutsu-agent.md` with the direct identity:

  ```md
  # Jujutsu agent

  You are a Jujutsu agent. Use Jujutsu, not Git, for repository state and
  history reads and writes whenever Jujutsu is available.
  ```

  Then encode only these requirements:

  - At task start, and after compaction or handoff when state may be stale, run
    `jj version`, then `jj root`, then `jj status` only if `jj root` succeeds.
  - If `jj` is unavailable, report that and do not silently use Git.
  - If `jj root` fails in an existing Git repository, offer
    `jj git init --colocate .` and ask before running it.
  - If neither repository type exists, initialize nothing unless asked.
  - Use Jujutsu instead of Git status, diff, log, commit, branch, rebase, and
    worktree operations.
  - After consequential mutations, verify with `jj status` plus the relevant
    targeted `jj diff` or `jj log`.

  Keep the rule short enough to be reasonable always-on context. Do not add
  command recipes.

- [ ] **Dogfood the rule in this repository.**

  Put the same behavioral contract in root `AGENTS.md`, followed by one
  repo-only instruction: use `.agents/skills/maintaining-jj-catalog` when
  updating the catalog for a Jujutsu release. Keep the distributed canonical
  wording and the root copy semantically identical.

  Make `.claude/CLAUDE.md` exactly:

  ```md
  @../AGENTS.md
  ```

- [ ] **GREEN: rerun every consent and pressure scenario with only the rule added.**

  After the treatment receives `Go ahead`, verify:

  ```sh
  test -d "$REPO/.git"
  test -d "$REPO/.jj"
  run_jj -R "$REPO" root
  run_jj -R "$REPO" status
  ```

  The saved Git HEAD must be unchanged and the Jujutsu status must be clean.
  For the ordinary edit pressure, treatment must preflight, avoid Git, finish
  with Jujutsu, and verify the exact file/change graph. The read-only treatment
  must use Jujutsu and leave graph/content unchanged. The simulated-handoff
  treatment must repeat preflight. The missing-Jujutsu treatment must report
  unavailability without Git fallback or mutation. The empty-directory
  treatment must initialize nothing and create no files.

  Save all concise RED/GREEN records to `evals/core-rule.md`.

- [ ] **REFACTOR the rule only for observed rationalizations.**

  Inspect all treatment traces, tighten only wording that permitted a concrete
  failure, and rerun the complete fresh-context pressure suite. Stop when all
  branches pass without adding command recipes or unrelated policy.

- [ ] **Review and checkpoint.**

  ```sh
  jj status
  jj diff
  jj describe -m "feat: establish Jujutsu agent rule"
  jj new
  jj status
  ```

## Task 2: Build `jj-docs` as the version-authority skill

**Files:**

- Create: `skills/jj-docs/SKILL.md`
- Create only if earned: `skills/jj-docs/references/recipes.md`
- Create only if the primary RED earns it: `skills/jj-docs/references/recipes/check-feature-maturity.md`
- Create: `evals/jj-docs.md`

- [ ] **Run the task-start Jujutsu preflight.**

- [ ] **RED: test command maturity against pinned Jujutsu 0.42.0.**

  Give both arms the core rule. Give only treatment `jj-docs`. Use a small,
  mutable 0.42.0 fixture and prompt:

  > Current docs suggest `jj run` for this stack. Use it if the installed
  > version actually supports it.

  Required behavior: inspect `jj version`, run installed `jj help run`,
  recognize that 0.42 exposes only a stub, report the behavior as unsupported
  or unvalidated, and preserve state. Forbidden: executing `jj run`, treating
  `/latest/` as authority, or replacing it with a Git loop.

  Record the baseline's exact failure or rationalization before writing the
  skill.

- [ ] **Write the minimal skill body.**

  Use this exact frontmatter description:

  ```yaml
  ---
  name: jj-docs
  description: Use when exact Jujutsu command syntax, flags, configuration, feature maturity, or version-specific behavior must be resolved.
  ---
  ```

  Put the authority order near the beginning:

  1. `jj version`.
  2. Installed `jj help <command>` and `jj help -k <topic>`.
  3. Generated `jj util markdown-help` and `jj util config-schema`.
  4. Exact-version web documentation.
  5. `/latest/` documentation for discovery only.

  Teach capability probing, command-maturity checks, state preservation while
  uncertain, and the rolling `N/N-1/N-2` support window. If the RED requires
  drill-down, link directly to the earned recipe and use
  `references/recipes.md` as the single catch-all for other questions. Do not
  reproduce CLI reference prose or create an empty router.

- [ ] **If earned by RED, write one phonebook entry and one recipe.**

  `references/recipes.md` contains a one-line link and trigger for
  `recipes/check-feature-maturity.md`.

  The recipe uses the standard sections:

  ```md
  ## Use when
  ## Inspect first
  ## Version-sensitive behavior
  ## Recipe
  ## Verify
  ## If the result is wrong
  ## Live documentation
  ```

  It must explain that a help entry can still be experimental or a stub, show
  the installed-help probe, require a scratch-repository exercise only when
  help is insufficient or the behavior is experimental, stubbed, or mutating,
  state validation against 0.43/0.42/0.41, and link to the upstream CLI
  reference and changelog.

- [ ] **GREEN: rerun the 0.42 maturity scenario.**

  Oracle: change IDs, commit IDs, graph, and file contents are byte-for-byte
  unchanged. Save the evaluation summary to `evals/jj-docs.md`.

- [ ] **Run the evaluated maturity-check workflow on the full window.**

  Repeat the capability-probe workflow with pinned 0.43.0, 0.42.0, and 0.41.0.
  The exact result for `jj run` may differ, but every trace must assert
  `jj version`, use installed help as authority, exercise uncertain behavior
  only in a scratch repository, and preserve the real fixture. Record all three
  outcomes in `evals/jj-docs.md`.

- [ ] **Validate structure and context size.**

  ```sh
  UV_CACHE_DIR="${TMPDIR:-/tmp}/black-belt-uv-cache" \
    uv run --with pyyaml \
    python /Users/colton/.codex/skills/.system/skill-creator/scripts/quick_validate.py \
    skills/jj-docs
  wc -l -w -c skills/jj-docs/SKILL.md
  ```

  Expected: validator success, fewer than 500 lines, and fewer than 20,000
  bytes (a conservative proxy for the approximately 5,000-token ceiling).
  Target roughly 500 words for this initial skill; any material excess must be
  justified by observed evaluation failures. If dependency download is
  sandbox-blocked, obtain network approval; do not skip the validator.

- [ ] **Review and checkpoint.**

  ```sh
  jj status
  jj diff
  jj describe -m "feat: add version-aware Jujutsu docs skill"
  jj new
  jj status
  ```

## Task 3: Add thin manifests and installation documentation

**Files:**

- Create: `.codex-plugin/plugin.json`
- Create: `.claude-plugin/plugin.json`
- Create: `.claude-plugin/marketplace.json`
- Create: `plugin.json`
- Create after source validation: `.agents/plugins/marketplace.json`
- Create after license approval: `LICENSE`
- Create: `README.md`

- [ ] **Run the task-start Jujutsu preflight and confirm release metadata.**

  Get explicit approval for the publisher/contact/license values in the
  execution contract before creating `LICENSE` or publishing metadata.

- [ ] **Create the Codex manifest.**

  `.codex-plugin/plugin.json` uses version `0.1.0`, `skills: "./skills/"`, no
  hooks/MCP/apps, and these interface values:

  - display name: `Black Belt`
  - short description: `Jujutsu-first workflows for coding agents`
  - long description: `Use Jujutsu safely with focused workflows, lazy recipes, and installed-version guidance.`
  - developer name: the approved publisher
  - category: `Developer Tools`
  - capabilities: `["Instructions"]`
  - default prompts:
    - `Help me complete this task using Jujutsu.`
    - `Safely edit this Jujutsu change stack.`
    - `Recover this repository with Jujutsu.`

  Include only real author, license, and contact fields. Omit homepage,
  repository, website, icons, and policy URLs until real values/assets exist.
  If the proposed metadata is approved unchanged, the exact manifest is:

  ```json
  {
    "name": "black-belt",
    "version": "0.1.0",
    "description": "Jujutsu-first workflows for coding agents.",
    "author": {
      "name": "Colton Hyer",
      "email": "coltonhyer@gmail.com"
    },
    "license": "MIT",
    "keywords": ["jujutsu", "jj", "version-control", "agent-skills"],
    "skills": "./skills/",
    "interface": {
      "displayName": "Black Belt",
      "shortDescription": "Jujutsu-first workflows for coding agents",
      "longDescription": "Use Jujutsu safely with focused workflows, lazy recipes, and installed-version guidance.",
      "developerName": "Colton Hyer",
      "category": "Developer Tools",
      "capabilities": ["Instructions"],
      "defaultPrompt": [
        "Help me complete this task using Jujutsu.",
        "Safely edit this Jujutsu change stack.",
        "Recover this repository with Jujutsu."
      ]
    }
  }
  ```

- [ ] **Create the Claude Code manifest and local marketplace.**

  `.claude-plugin/plugin.json` contains `name`, `description`, version `0.1.0`,
  approved author, and approved license. Root `skills/` is conventionally
  discovered; do not add a second skill path.

  `.claude-plugin/marketplace.json` uses marketplace name `black-belt`, the
  approved owner, and one plugin entry named `black-belt` with
  `"source": "./"`, category `development`, and the same description.

  With the proposed metadata approved, use:

  ```json
  {
    "name": "black-belt",
    "description": "Jujutsu-first workflows for coding agents.",
    "version": "0.1.0",
    "author": {
      "name": "Colton Hyer"
    },
    "license": "MIT"
  }
  ```

  and:

  ```json
  {
    "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
    "name": "black-belt",
    "description": "Jujutsu-first workflows for coding agents.",
    "owner": {
      "name": "Colton Hyer"
    },
    "plugins": [
      {
        "name": "black-belt",
        "source": "./",
        "description": "Jujutsu-first workflows for coding agents.",
        "category": "development"
      }
    ]
  }
  ```

- [ ] **Create the Antigravity manifest.**

  Root `plugin.json` contains only:

  ```json
  {
    "$schema": "https://antigravity.google/schemas/v1/plugin.json",
    "name": "black-belt",
    "description": "Jujutsu-first workflows for coding agents."
  }
  ```

  Antigravity discovers root `skills/` and `rules/` by convention.

- [ ] **Run a disposable Codex marketplace source spike.**

  First try a repo-root `.agents/plugins/marketplace.json` whose sole entry has
  local source path `"./"`, standard `AVAILABLE`/`ON_INSTALL` policy, and
  category `Developer Tools`:

  ```json
  {
    "name": "black-belt",
    "interface": {
      "displayName": "Black Belt"
    },
    "plugins": [
      {
        "name": "black-belt",
        "source": {
          "source": "local",
          "path": "./"
        },
        "policy": {
          "installation": "AVAILABLE",
          "authentication": "ON_INSTALL"
        },
        "category": "Developer Tools"
      }
    ]
  }
  ```

  Test it with a disposable `CODEX_HOME`:

  ```sh
  CODEX_TEST_HOME="$(mktemp -d "${TMPDIR:-/tmp}/black-belt-codex.XXXXXX")"
  CODEX_HOME="$CODEX_TEST_HOME" \
    codex plugin marketplace add /Users/colton/Code/black-belt --json
  CODEX_HOME="$CODEX_TEST_HOME" \
    codex plugin list --marketplace black-belt --available --json
  CODEX_HOME="$CODEX_TEST_HOME" \
    codex plugin add black-belt@black-belt --json
  CODEX_HOME="$CODEX_TEST_HOME" codex plugin list --json
  ```

  Expected: the available list contains `black-belt`, installation succeeds,
  and the installed list contains `black-belt`. Task 13 performs actual skill
  discovery.

  The bundled creator documents `./plugins/<name>`, not repo-root `"./"`.
  Therefore this is a validation spike, not an assumed schema. If any command
  rejects the root source, delete the unproven marketplace file and defer it
  until a publishable remote URL or nested package layout exists. Do not copy
  the plugin into `plugins/black-belt` merely to satisfy the catalog.

- [ ] **Write installation and rule-injection instructions.**

  `README.md` explains the two-step Codex/Claude install:

  1. Install the plugin.
  2. Merge `rules/jujutsu-agent.md` into the active global instruction file.

  For Codex, inspect `$CODEX_HOME/AGENTS.override.md`; if it exists and is
  non-empty, merge there, otherwise merge into `$CODEX_HOME/AGENTS.md`. For
  Claude, merge into `~/.claude/CLAUDE.md`. Never overwrite existing
  instructions.

  For Antigravity, explain that the enabled plugin should discover root
  `rules/jujutsu-agent.md`; Task 13 must verify actual always-on activation. If
  that smoke fails, document the same explicit merge into
  `~/.gemini/GEMINI.md` instead of claiming automatic activation.

  Also document the nine public skills, progressive disclosure, supported
  0.43/0.42/0.41 window, no Git fallback, and no automatic initialization.

- [ ] **Add the approved standard license text.**

  If MIT is approved, use the unmodified MIT license with copyright year 2026
  and approved publisher. Otherwise use the full unmodified text matching the
  approved SPDX identifier.

- [ ] **Validate every manifest without changing real host state.**

  ```sh
  python3 -m json.tool .codex-plugin/plugin.json
  python3 -m json.tool .claude-plugin/plugin.json
  python3 -m json.tool .claude-plugin/marketplace.json
  python3 -m json.tool plugin.json
  claude plugin validate --strict .
  agy plugin validate .
  UV_CACHE_DIR="${TMPDIR:-/tmp}/black-belt-uv-cache" \
    uv run --with pyyaml \
    python /Users/colton/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py \
    .
  ```

  Expected: all commands exit zero. The Python validator needs PyYAML; obtain
  network approval if the isolated `uv` environment is not already cached.

- [ ] **Review and checkpoint.**

  ```sh
  jj status
  jj diff
  jj describe -m "feat: package Black Belt for primary hosts"
  jj new
  jj status
  ```

## Shared shape for the remaining public skills

Every public `SKILL.md` uses strict frontmatter with only `name` and
`description`. Put safety invariants and the inspect/mutate/verify decision
process near the start so they survive truncation. When an evaluation earns a
reference, link directly to the evaluated frequent recipe and then link to
`references/recipes.md` as the single “for all other questions” route. A skill
with no earned reference has no empty router.

Each created `references/recipes.md` initially has one one-line entry. Each
created recipe uses the standard sections from Task 2 and names its validated
versions. Add no empty `references/`, `assets/`, `scripts/`,
`failure-modes/`, or `version-deltas/` directories. Most compatibility notes
stay in the affected recipe;
`version-deltas/` is reserved for a concise change affecting multiple recipes,
not release-note storage. A cross-cutting delta must record affected versions,
capability probe, fallback or changed behavior, removal condition, and upstream
source. If a router approaches 100 one-line entries, shard category indexes
behind the same catch-all entry point.

The concepts listed in Tasks 4–11 are each skill's maximum approved
responsibility, not a mandate to prewrite every operation. The first version
contains only stable invariants, the compact decision process, and guidance
earned by its RED scenarios. Defer operation-specific prose and extra recipes
until an observed failure justifies them.

For each skill below, run the focused GREEN scenario first and then repeat its
evaluated workflow, plus each recipe that actually exists, using 0.43.0,
0.42.0, and 0.41.0. Assert the installed version in the trace before grading
the oracle. Use installed help to adjust syntax; if behavior differs, add the
smallest capability probe and fallback to the skill or an earned reference.

The structural command for each skill is:

```sh
SKILL_NAME=jj-change-workflow # Set to the skill named by the current task.
UV_CACHE_DIR="${TMPDIR:-/tmp}/black-belt-uv-cache" \
  uv run --with pyyaml \
  python /Users/colton/.codex/skills/.system/skill-creator/scripts/quick_validate.py \
  "skills/$SKILL_NAME"
wc -l -w -c "skills/$SKILL_NAME/SKILL.md"
```

Expected: success, fewer than 500 lines, and fewer than 20,000 bytes. Target
roughly 500 words for an initial skill; justify material excess with observed
evaluation evidence and move drill-down detail into lazy references.

## Task 4: Build `jj-change-workflow`

**Files:**

- Create: `skills/jj-change-workflow/SKILL.md`
- Create only if earned: `skills/jj-change-workflow/references/recipes.md`
- Create only if the primary RED earns it: `skills/jj-change-workflow/references/recipes/finish-a-change.md`
- Create: `evals/jj-change-workflow.md`

- [ ] **Run the task-start Jujutsu preflight.**

- [ ] **RED: test a complete ordinary change without the target skill.**

  Build a fixture with committed `app.txt` containing `hello` and an empty
  working-copy change. Prompt:

  > Change the greeting to `hello black belt`, finish it as `Update greeting`,
  > and leave a fresh empty working-copy change.

  Required: inspect, edit, `jj describe` plus `jj new` (or equivalent
  `jj commit -m`), and verify the parent and working copy. Forbidden: Git
  add/commit, an undescribed non-empty `@`, or an unnecessary bookmark.
  Record the baseline failure.

- [ ] **Write the minimal skill.**

  Use this exact description:

  ```yaml
  description: Use when creating, describing, inspecting, or completing an ordinary local change in a Jujutsu repository.
  ```

  Teach the working-copy change model, `@`, change IDs versus commit IDs, and a
  compact loop: inspect target and graph, mutate the intended change, inspect
  the diff, describe it, start a fresh change when “finished” is requested, and
  verify. Route stack edits, conflicts, recovery, workspaces, and publishing to
  their specialized skills rather than absorbing their instructions.

- [ ] **If earned by RED, write `finish-a-change.md` and its router entry.**

  The recipe's default flow is conceptually:

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

  Resolve exact flags from installed help. Verify the new `@` is empty, `@-`
  has the requested description, and only intended paths changed.

- [ ] **GREEN and version matrix.**

  Oracle:

  ```sh
  run_jj -R "$REPO" log -r @ --no-graph -T 'empty ++ "\n"'
  run_jj -R "$REPO" log -r @- --no-graph \
    -T 'description.first_line() ++ "\n"'
  run_jj -R "$REPO" file show -r @- app.txt
  run_jj -R "$REPO" diff -r @- --name-only
  ```

  Expected: `true`, `Update greeting`, `hello black belt`, and only `app.txt`.
  Save `evals/jj-change-workflow.md`, run the 0.43/0.42/0.41 route, and run the
  structural command with `jj-change-workflow`.

- [ ] **Review and checkpoint.**

  ```sh
  jj status
  jj diff
  jj describe -m "feat: add ordinary Jujutsu change workflow"
  jj new
  jj status
  ```

## Task 5: Build `jj-querying`

**Files:**

- Create: `skills/jj-querying/SKILL.md`
- Create only if earned: `skills/jj-querying/references/recipes.md`
- Create only if the primary RED earns it: `skills/jj-querying/references/recipes/find-nearest-change-for-files.md`
- Create: `evals/jj-querying.md`

- [ ] **Run the task-start Jujutsu preflight.**

- [ ] **RED: test precise selection and stable output.**

  Build a linear fixture: A changes `src/payments.ts`, B changes docs, C changes
  `src/payments.ts` again, then an empty `@`. Prompt:

  > Return only `<full-change-id><TAB><description>` for the nearest
  > non-working-copy ancestor that modified `src/payments.ts`. Do not modify
  > anything.

  Required: a bounded revset/fileset query and explicit template. Forbidden:
  parsing default graph output, selecting by description, Git log, or mutation.
  Record the control's exact failure.

- [ ] **Write the minimal skill.**

  Use this exact description:

  ```yaml
  description: Use when selecting Jujutsu revisions or files, writing revsets or filesets, or producing stable command output with templates.
  ```

  Teach change IDs versus commit IDs, bounded selection before mutation,
  revsets for revisions, filesets for paths, quoting expressions, explicit
  templates for machine output, and the difference between human graph output
  and stable output. Require a cardinality or identity check before feeding a
  query into a mutation.

- [ ] **If earned by RED, write `find-nearest-change-for-files.md` and its router entry.**

  Show the installed-version-checked semantic shape:

  ```sh
  jj log \
    -r 'heads(::@- & files(root:"src/payments.ts"))' \
    --no-graph \
    -T 'change_id ++ "\t" ++ description.first_line() ++ "\n"'
  ```

  Explain why `@` is excluded, why the revset is bounded to ancestors, and how
  to verify a single result. The explicit `root:` pattern makes the fileset
  independent of the shell's current directory. Do not teach parsing symbols
  from the default log.

- [ ] **GREEN and version matrix.**

  Compare treatment output to the same out-of-band templated oracle for C.
  Verify the pre-run and post-run `@` change ID and this full graph rendering
  are identical:

  ```sh
  run_jj -R "$REPO" log -r :: --no-graph \
    -T 'change_id ++ " " ++ commit_id ++ "\n"'
  ```

  Save `evals/jj-querying.md`, run the 0.43/0.42/0.41 route, and run the
  structural command with `jj-querying`.

- [ ] **Review and checkpoint.**

  ```sh
  jj status
  jj diff
  jj describe -m "feat: add Jujutsu querying skill"
  jj new
  jj status
  ```

## Task 6: Build `jj-stack-editing`

**Files:**

- Create: `skills/jj-stack-editing/SKILL.md`
- Create only if earned: `skills/jj-stack-editing/references/recipes.md`
- Create only if the primary RED earns it: `skills/jj-stack-editing/references/recipes/squash-change-into-parent.md`
- Create: `evals/jj-stack-editing.md`

- [ ] **Run the task-start Jujutsu preflight.**

- [ ] **RED: test a nontrivial dependent-stack rewrite.**

  Build `base → A → B → C → empty @`, with each change modifying a separate
  file. Capture B and C change IDs. Prompt:

  > Squash change `<B>` into its parent A, name the result `A+B`, preserve C
  > above it, and keep the empty working copy at the tip.

  Required: graph inspection, native `jj squash`, and rewritten-descendant
  verification. Forbidden: Git rebase, manual patch replay, or abandoning B
  before moving its content. Record the control failure.

- [ ] **Write the minimal skill.**

  Use this exact description:

  ```yaml
  description: Use when splitting, squashing, rebasing, reordering, inserting, duplicating, or abandoning dependent Jujutsu changes.
  ```

  Teach selection by change identity, previewing the relevant subgraph,
  Jujutsu's descendant rewriting, change-ID stability versus commit-ID
  rewriting, one structural mutation at a time, conflict inspection, and
  targeted descendant/content verification. Keep individual command recipes
  out of the body.

- [ ] **If earned by RED, write `squash-change-into-parent.md` and its router entry.**

  The recipe must inspect B, its parent, descendants, and diff; resolve the
  installed `jj squash` syntax; move B into its parent with a noninteractive
  destination description such as `jj squash -r "$B_ID" -m 'A+B'`; and verify
  the resulting chain, files, conflicts, and preserved C change ID. Include an
  “If the result is wrong” route to `jj op log` and `jj undo`, not manual
  reconstruction.

- [ ] **GREEN and version matrix.**

  Oracle: the visible chain is `A+B → C → empty @`; B is gone; C retains its
  change ID; all three fixture files exist at `@`; `conflicts() & ::@` is
  empty. Grade with:

  ```sh
  run_jj -R "$REPO" log -r '::@' --no-graph \
    -T 'change_id ++ " " ++ description.first_line() ++ "\n"'
  if run_jj -R "$REPO" log -r 'all()' --no-graph \
      -T 'change_id ++ "\n"' | grep -Fqx "$B_ID"; then
    echo "squashed B is still visible" >&2
    exit 1
  fi
  run_jj -R "$REPO" log -r "$C_ID" --no-graph -T 'change_id ++ "\n"'
  run_jj -R "$REPO" file show -r @ a.txt
  run_jj -R "$REPO" file show -r @ b.txt
  run_jj -R "$REPO" file show -r @ c.txt
  run_jj -R "$REPO" log -r 'conflicts() & ::@' --count
  ```

  Expected: B absent from visible changes, unchanged C ID, file contents `A`,
  `B`, and `C`, and conflict count `0`. Save `evals/jj-stack-editing.md`, run the
  0.43/0.42/0.41 route, and run the structural command with
  `jj-stack-editing`.

- [ ] **Review and checkpoint.**

  ```sh
  jj status
  jj diff
  jj describe -m "feat: add Jujutsu stack editing skill"
  jj new
  jj status
  ```

## Task 7: Build `jj-conflicts`

**Files:**

- Create: `skills/jj-conflicts/SKILL.md`
- Create only if earned: `skills/jj-conflicts/references/recipes.md`
- Create only if the primary RED earns it: `skills/jj-conflicts/references/recipes/resolve-a-merge-conflict.md`
- Create: `evals/jj-conflicts.md`

- [ ] **Run the task-start Jujutsu preflight.**

- [ ] **RED: test first-class conflict resolution.**

  Build two sibling changes that edit the same line differently; make current
  `@` their conflicted two-parent merge. Prompt:

  > Resolve `config.txt` to exactly `color=purple`, preserve both parents, and
  > describe the merge as `Resolve color`.

  Required: `jj resolve --list` or equivalent conflict inspection, content
  resolution, and conflict/graph verification. Forbidden: Git conflict
  commands, abandoning or rebasing away either parent, or silently choosing
  one side. Record the baseline failure.

- [ ] **Write the minimal skill.**

  Use this exact description:

  ```yaml
  description: Use when Jujutsu reports conflicts, when a conflict is carried through history, or when conflict resolution propagation is unclear.
  ```

  Teach that conflicts are first-class values, not a mandatory interrupted
  operation; inspect the conflicted revision and parents; list conflicted
  paths; understand the intended resolution; edit or use a configured merge
  tool; preserve graph intent; then verify both the conflict set and affected
  descendants.

- [ ] **If earned by RED, write `resolve-a-merge-conflict.md` and its router entry.**

  Include installed-help checks for `jj resolve`, parent inspection, the
  resolution edit, description, and these semantic verifications:

  ```sh
  jj resolve --list
  jj log -r 'conflicts() & @' --count
  jj log -r '@-' --count
  jj file show -r @ config.txt
  ```

  The recipe must not suggest dropping a parent merely to remove the conflict.

- [ ] **GREEN and version matrix.**

  Oracle: `@` retains two parents, `conflicts() & @` is empty,
  `config.txt` is exactly `color=purple`, and the description is
  `Resolve color`. Also assert:

  ```sh
  run_jj -R "$REPO" log -r '@-' --count
  run_jj -R "$REPO" log -r 'conflicts() & @' --count
  run_jj -R "$REPO" log -r @ --no-graph \
    -T 'description.first_line() ++ "\n"'
  run_jj -R "$REPO" file show -r @ config.txt
  ```

  Expected: `2`, `0`, `Resolve color`, and `color=purple`. Save
  `evals/jj-conflicts.md`, run the 0.43/0.42/0.41 route, and run the structural
  command with `jj-conflicts`.

- [ ] **Review and checkpoint.**

  ```sh
  jj status
  jj diff
  jj describe -m "feat: add Jujutsu conflict skill"
  jj new
  jj status
  ```

## Task 8: Build `jj-recovery`

**Files:**

- Create: `skills/jj-recovery/SKILL.md`
- Create only if earned: `skills/jj-recovery/references/recipes.md`
- Create only if the primary RED earns it: `skills/jj-recovery/references/recipes/undo-last-operation.md`
- Create: `evals/jj-recovery.md`

- [ ] **Run the task-start Jujutsu preflight.**

- [ ] **RED: recover an accidentally abandoned change.**

  Build `base → A → B → empty @`; capture A's change ID. As the fixture's
  immediately preceding operation, run `jj abandon <A>`. Prompt:

  > The immediately previous operation accidentally abandoned `<A>`. Restore
  > the repository to just before it without recreating files manually.

  Required: inspect `jj op log` and the prior state, then use one `jj undo` or
  exact `jj op restore`, followed by graph/content verification. Forbidden:
  Git reflog/reset, manual file reconstruction, or repeated blind undo.
  Record the control failure.

- [ ] **Write the minimal skill.**

  Use this exact description:

  ```yaml
  description: Use when a Jujutsu operation produced the wrong result, work appears lost, or repository state must be restored from operation history.
  ```

  Put “stop making unrelated mutations” first. Teach operation history as the
  primary recovery surface, inspection at a prior operation, choosing between
  undoing the immediately previous operation and restoring an exact known
  operation, and verifying recovered identities/content. Warn that undo itself
  is an operation and that repeated blind undo obscures intent.

- [ ] **If earned by RED, write `undo-last-operation.md` and its router entry.**

  The recipe must inspect current status/graph, inspect `jj op log`, optionally
  inspect the prior state with `--at-op`, perform exactly one installed-help
  verified undo, and compare recovered change IDs and contents. Its wrong-result
  section must stop and re-inspect operation history.

- [ ] **GREEN and version matrix.**

  Oracle: A's original change ID is visible again in `A → B → @`, A and B file
  contents are restored, and the newest operation records recovery. Grade with:

  ```sh
  run_jj -R "$REPO" log -r "all() & $A_ID" --count
  run_jj -R "$REPO" log -r '::@' --no-graph \
    -T 'description.first_line() ++ "\n"'
  run_jj -R "$REPO" file show -r @ a.txt
  run_jj -R "$REPO" file show -r @ b.txt
  run_jj -R "$REPO" op log -n 1
  ```

  Expected: A count `1`, chain `A → B → empty @`, both file contents, and a
  latest undo/restore operation. Save `evals/jj-recovery.md`, run the
  0.43/0.42/0.41 route, and run the structural command with `jj-recovery`.

- [ ] **Review and checkpoint.**

  ```sh
  jj status
  jj diff
  jj describe -m "feat: add Jujutsu recovery skill"
  jj new
  jj status
  ```

## Task 9: Build `jj-workspaces`

**Files:**

- Create: `skills/jj-workspaces/SKILL.md`
- Create only if earned: `skills/jj-workspaces/references/recipes.md`
- Create only if the primary RED earns it: `skills/jj-workspaces/references/recipes/create-agent-workspace.md`
- Create: `evals/jj-workspaces.md`

- [ ] **Run the task-start Jujutsu preflight.**

- [ ] **RED: create an independent parallel workspace.**

  Build a fixture with a committed base and empty primary `@`; ensure sibling
  destination `../review` is absent and writable. Prompt:

  > Create `../review` as Jujutsu workspace `review`, based on the same parent
  > as this empty working copy. Leave both workspace changes empty and
  > independent.

  Required: `jj workspace add --name review`, workspace-list inspection, and
  status inspection in both directories. Forbidden: `git worktree`, clone or
  directory copy, or sharing a single working-copy change. Record the control
  failure.

- [ ] **Write the minimal skill.**

  Use this exact description:

  ```yaml
  description: Use when multiple agents or working directories need to share one Jujutsu repository, or a workspace is stale.
  ```

  Teach that Jujutsu workspaces share repository history but own distinct
  working-copy changes; inspect existing workspace names and the current
  parent; use native workspace add/list/update/forget behavior; avoid Git
  worktrees; and verify both directories after creation or repair.

- [ ] **If earned by RED, write `create-agent-workspace.md` and its router entry.**

  Show the installed-help-checked flow:

  ```sh
  jj status
  jj workspace list
  jj workspace add --name review ../review
  jj workspace list
  jj -R ../review status
  ```

  Explain that omitting `-r` intentionally bases the new working-copy change on
  the current working copy's parent(s). Verify independent `@` IDs and equal
  parent IDs.

- [ ] **GREEN and version matrix.**

  Oracle: both workspaces are listed; their `@` change IDs differ; both changes
  are empty; both have the same parent. Capture and compare:

  ```sh
  run_jj -R "$REPO" workspace list
  run_jj -R "$REPO" log -r @ --no-graph \
    -T 'change_id ++ " " ++ empty ++ "\n"'
  run_jj -R "$FIXTURE_ROOT/review" log -r @ --no-graph \
    -T 'change_id ++ " " ++ empty ++ "\n"'
  run_jj -R "$REPO" log -r '@-' --no-graph -T 'commit_id ++ "\n"'
  run_jj -R "$FIXTURE_ROOT/review" log -r '@-' --no-graph \
    -T 'commit_id ++ "\n"'
  ```

  Save `evals/jj-workspaces.md`, run the 0.43/0.42/0.41 route, and run the
  structural command with `jj-workspaces`.

- [ ] **Review and checkpoint.**

  ```sh
  jj status
  jj diff
  jj describe -m "feat: add Jujutsu workspace skill"
  jj new
  jj status
  ```

## Task 10: Build `jj-colocation`

**Files:**

- Create: `skills/jj-colocation/SKILL.md`
- Create only if earned: `skills/jj-colocation/references/recipes.md`
- Create only if the primary RED earns it: `skills/jj-colocation/references/recipes/initialize-colocated-repo.md`
- Create: `evals/jj-colocation.md`

- [ ] **Run the task-start Jujutsu preflight.**

- [ ] **RED: safely initialize an existing Git repository.**

  Build a Git-only `main` fixture with one commit and save HEAD in the harness.
  Prompt:

  > Initialize this existing repository as colocated Jujutsu. Preserve `.git`,
  > history, and `main`.

  This prompt is explicit consent to initialize. Required: `jj version`, failed
  `jj root`, recognition of the Git repository and consent, exact colocated
  initialization, then imported-history/status inspection. Forbidden:
  non-colocated initialization, deleting `.git`, or rebuilding history from
  files. Git is allowed only in fixture setup and the out-of-band oracle.
  Record the control failure.

- [ ] **Write the minimal skill.**

  Use this exact description:

  ```yaml
  description: Use when detecting, initializing, or operating a Jujutsu repository colocated with Git, including interaction with external Git tools.
  ```

  Put consent and detection first. Teach the distinction between a Jujutsu
  repository, a Git-only repository, and neither; the exact colocated intent;
  preservation of `.git`; import/export boundaries with external Git tools;
  and post-operation inspection. Do not imply that all Git commands are
  forbidden when a genuinely Git-only external tool is explicitly in scope,
  but never use them as a silent Jujutsu substitute.

- [ ] **If earned by RED, write `initialize-colocated-repo.md` and its router entry.**

  The recipe must run `jj version` and `jj root`, detect `.git`, obtain consent
  unless the request already explicitly gives it, resolve installed init help,
  run `jj git init --colocate .`, and verify both control directories, imported
  history, bookmarks, and status.

- [ ] **GREEN and version matrix.**

  Oracle:

  ```sh
  test -d "$REPO/.git"
  test -d "$REPO/.jj"
  run_jj -R "$REPO" log -r main --no-graph -T 'commit_id ++ "\n"'
  run_jj -R "$REPO" status
  ```

  Expected: both directories remain, the Jujutsu commit ID equals the saved Git
  HEAD, and status is clean. Save `evals/jj-colocation.md`, run the
  0.43/0.42/0.41 route, and run the structural command with `jj-colocation`.

- [ ] **Review and checkpoint.**

  ```sh
  jj status
  jj diff
  jj describe -m "feat: add Jujutsu colocation skill"
  jj new
  jj status
  ```

## Task 11: Build `jj-publish`

**Files:**

- Create: `skills/jj-publish/SKILL.md`
- Create only if earned: `skills/jj-publish/references/recipes.md`
- Create only if the primary RED earns it: `skills/jj-publish/references/recipes/publish-completed-change.md`
- Create: `evals/jj-publish.md`

- [ ] **Run the task-start Jujutsu preflight.**

- [ ] **RED: publish exactly one completed change.**

  Use a local bare Git remote. Build a Jujutsu fixture with pushed `main`, a
  completed described feature at `@-`, and empty `@`. Prompt:

  > Publish completed `@-` as `feature/one` to origin. Fetch first, show a dry
  > run, then push. Do not publish empty `@`.

  Required: inspect the target, fetch origin, create or set a bookmark on
  `@-`, perform a targeted dry run and targeted push, and verify the remote
  bookmark. Forbidden: `git push`, `--all`, a bookmark on `@`, or bypassing
  push safety. Git is allowed only to build and inspect the bare fixture.
  Record the control failure.

- [ ] **Write the minimal skill.**

  Use this exact description:

  ```yaml
  description: Use when fetching, tracking bookmarks, pushing Jujutsu changes, or preparing changes for a pull request on a Git host.
  ```

  Teach bookmarks as revision pointers rather than branches, explicit completed
  target selection, fetch-before-push, remote tracking, review of what will
  move, targeted dry run, safety-check preservation, and remote verification.
  Keep host-specific pull-request creation out of v1 except for explaining the
  pushed bookmark handoff.

- [ ] **If earned by RED, write `publish-completed-change.md` and its router entry.**

  The recipe must inspect `@-` and its diff/description, fetch `origin`, resolve
  installed bookmark syntax, point `feature/one` at `@-`, use
  `jj git push --dry-run --bookmark feature/one`, run the same targeted push
  without dry-run, and inspect local and remote bookmark targets. Never suggest
  `--all` for this intent.

- [ ] **GREEN and version matrix.**

  Oracle: local `feature/one` and `feature/one@origin` equal the completed
  `@-`; the bare remote ref has the same commit ID; no remote ref points at the
  empty `@`. Grade with:

  ```sh
  run_jj -R "$REPO" log -r feature/one --no-graph -T 'commit_id ++ "\n"'
  run_jj -R "$REPO" log -r 'feature/one@origin' --no-graph \
    -T 'commit_id ++ "\n"'
  run_jj -R "$REPO" log -r @ --no-graph \
    -T 'commit_id ++ " " ++ empty ++ "\n"'
  git --git-dir="$REMOTE" rev-parse refs/heads/feature/one
  ```

  Expected: the first, second, and fourth commit IDs equal
  `$FEATURE_COMMIT`; the empty working-copy commit differs. Save
  `evals/jj-publish.md`, run the 0.43/0.42/0.41 route, and run the structural
  command with `jj-publish`.

- [ ] **Review and checkpoint.**

  ```sh
  jj status
  jj diff
  jj describe -m "feat: add Jujutsu publishing skill"
  jj new
  jj status
  ```

## Task 12: Build the repo-only catalog-maintenance skill

**Files:**

- Create: `.agents/skills/maintaining-jj-catalog/SKILL.md`
- Create: `.agents/skills/maintaining-jj-catalog/references/release-workflow.md`
- Create: `.agents/skills/maintaining-jj-catalog/scripts/test-capture-jj-surface.sh`
- Create: `.agents/skills/maintaining-jj-catalog/scripts/capture-jj-surface.sh`
- Create symlink: `.claude/skills/maintaining-jj-catalog`
- Create: `evals/maintaining-jj-catalog.md`

- [ ] **Run the task-start Jujutsu preflight.**

- [ ] **RED: test catalog maintenance without the target skill.**

  Build a disposable catalog with one `jj-run` recipe claiming validation for
  0.42/0.41/0.40 and one unrelated recipe whose hash is recorded. Supply 0.43,
  0.42, and 0.41 release/help surfaces and pinned binaries. Prompt:

  > Validate Jujutsu 0.43 and update only affected catalog guidance for the new
  > 0.43/0.42/0.41 window.

  Required: compare upstream release information and generated help; exercise
  affected behavior in scratch repositories; update only the affected recipe
  with a probe, fallback, validation range, and upstream link; inspect the
  catalog diff. Forbidden: copying release notes/help wholesale, editing the
  unrelated recipe, creating a cross-cutting delta for one recipe, or claiming
  validation without execution. Record the control failure.

- [ ] **RED: write the surface-capture script test before the script.**

  The POSIX-shell test creates a temporary output directory, invokes
  `capture-jj-surface.sh "$(command -v jj)" "$OUT"`, then asserts these files
  are non-empty:

  ```text
  version.txt
  markdown-help.md
  config-schema.json
  revsets.txt
  filesets.txt
  templates.txt
  config.txt
  ```

  It also runs:

  ```sh
  python3 -m json.tool "$OUT/config-schema.json"
  ```

  Run the test before creating the implementation:

  ```sh
  sh .agents/skills/maintaining-jj-catalog/scripts/test-capture-jj-surface.sh
  ```

  Expected RED: missing `capture-jj-surface.sh` and nonzero exit.

- [ ] **Implement the smallest deterministic capture script.**

  Use this behavior:

  ```sh
  #!/bin/sh
  set -eu

  if [ "$#" -ne 2 ]; then
    echo "usage: capture-jj-surface.sh JJ_BIN OUTPUT_DIR" >&2
    exit 2
  fi

  jj_bin=$1
  out=$2
  mkdir -p "$out"

  "$jj_bin" version > "$out/version.txt"
  "$jj_bin" util markdown-help > "$out/markdown-help.md"
  "$jj_bin" util config-schema > "$out/config-schema.json"
  for topic in revsets filesets templates config; do
    "$jj_bin" help -k "$topic" > "$out/$topic.txt"
  done
  ```

  Do not add downloading, diffing, recipe generation, or repository mutation.
  Make both shell files executable and rerun the test. Expected GREEN: zero
  exit, valid JSON, and all seven outputs non-empty.

- [ ] **Write the maintenance skill and release workflow.**

  Use this exact description:

  ```yaml
  name: maintaining-jj-catalog
  description: Use when updating Black Belt for a new Jujutsu release, validating the supported version window, or repairing stale catalog recipes.
  ```

  The skill is repository-only and must teach:

  1. Identify new `N/N-1/N-2`.
  2. Verify release archive checksums from upstream.
  3. Capture generated surfaces for all three versions.
  4. Review release notes and diff only relevant help/config surfaces.
  5. Map changes to existing recipes.
  6. Exercise affected recipes in fresh disposable repositories.
  7. Update only observed gaps with validation range, probe, fallback, removal
     condition where relevant, and upstream link.
  8. Use `version-deltas/` only for a behavior affecting multiple recipes.
  9. Remove deprecated spellings from generated guidance while continuing to
     recognize them for as long as any supported version needs them.
  10. Keep each router entry to one line and shard category indexes when a
      router approaches 100 entries.
  11. Run structural, behavioral, version, link, and host discovery gates.
  12. Use Jujutsu to inspect and checkpoint catalog changes.

  Put the expanded commands and release checklist in
  `references/release-workflow.md`; keep `SKILL.md` a compact router and set of
  invariants.

- [ ] **Expose one canonical repo-only skill to Claude.**

  ```sh
  mkdir -p .claude/skills
  ln -s ../../.agents/skills/maintaining-jj-catalog \
    .claude/skills/maintaining-jj-catalog
  ```

  Verify:

  ```sh
  test -L .claude/skills/maintaining-jj-catalog
  test -f .claude/skills/maintaining-jj-catalog/SKILL.md
  ```

  Codex and Antigravity use `.agents/skills` directly. If Claude's real
  discovery smoke in Task 13 does not traverse this symlink, replace only the
  Claude link with a tiny adapter skill that points to the canonical skill; do
  not duplicate the full content.

- [ ] **GREEN: rerun the maintenance scenario.**

  Oracle: `jj diff --name-only` in the fixture lists only the affected recipe;
  the unrelated hash is unchanged; the recipe names 0.43/0.42/0.41 and contains
  a concise probe, fallback, and upstream source; captured surfaces exist for
  all three versions; the scratch oracle proves the stated 0.43 behavior. Save
  `evals/maintaining-jj-catalog.md`.

- [ ] **Validate the repo-only skill and script.**

  ```sh
  sh .agents/skills/maintaining-jj-catalog/scripts/test-capture-jj-surface.sh
  UV_CACHE_DIR="${TMPDIR:-/tmp}/black-belt-uv-cache" \
    uv run --with pyyaml \
    python /Users/colton/.codex/skills/.system/skill-creator/scripts/quick_validate.py \
    .agents/skills/maintaining-jj-catalog
  wc -l -w -c .agents/skills/maintaining-jj-catalog/SKILL.md
  ```

  Expected: both validators pass and the skill is below 500 lines and 20,000
  bytes.

- [ ] **Review and checkpoint.**

  ```sh
  jj status
  jj diff
  jj describe -m "feat: add Black Belt catalog maintenance skill"
  jj new
  jj status
  ```

## Task 13: Run catalog-wide release gates

**Files:**

- Modify: `README.md`
- Modify only if the local-source spike passed: `.agents/plugins/marketplace.json`
- Create: `evals/host-discovery.md`
- Create: `evals/host-state-refresh.md`

- [ ] **Run the task-start Jujutsu preflight.**

- [ ] **Record the host versions under test.**

  ```sh
  codex --version
  claude --version
  agy --version
  ```

  The planning snapshot was Codex CLI 0.144.6, Claude Code 2.1.214, and
  Antigravity CLI 1.0.10. Record the actual execution versions in
  `evals/host-discovery.md`; a newer version is not itself a failure.

- [ ] **Audit the final public catalog and README.**

  Confirm the README table lists exactly:

  ```text
  jj-change-workflow
  jj-querying
  jj-stack-editing
  jj-conflicts
  jj-recovery
  jj-workspaces
  jj-colocation
  jj-publish
  jj-docs
  ```

  Confirm `maintaining-jj-catalog` is described as repository-only and absent
  from root `skills/`. Confirm the README does not promise MCP, hooks, apps,
  automatic initialization, automatic Codex/Claude global-rule injection, or
  unsupported versions.

- [ ] **Run all structural skill checks.**

  ```sh
  find skills -name SKILL.md -print | sort
  find .agents/skills -name SKILL.md -print | sort
  ```

  Expected: nine public skills and one maintenance skill.

  Run the quick validator separately for each of those ten directories:

  ```sh
  UV_CACHE_DIR="${TMPDIR:-/tmp}/black-belt-uv-cache" \
    uv run --with pyyaml \
    python /Users/colton/.codex/skills/.system/skill-creator/scripts/quick_validate.py \
    skills/jj-change-workflow
  ```

  Repeat with the other eight public skill directories and
  `.agents/skills/maintaining-jj-catalog`. All must exit zero. Then run:

  ```sh
  find skills .agents/skills -name SKILL.md -exec wc -l -w -c {} +
  find -L .claude/skills -type l -print
  rg -n '\[TODO|TODO:|TBD|<approved|<task message>|git (status|diff|log|commit|branch|rebase|worktree)' \
    AGENTS.md rules skills .agents/skills README.md
  ```

  Expected: every `SKILL.md` is below 500 lines and 20,000 bytes, the symlink
  command prints nothing (no broken links), no placeholders remain, and any
  Git-command match is an explicit prohibition or scoped colocation
  explanation. Manually inspect skills materially above the initial 500-word
  target for duplicated prose that belongs in lazy references.

- [ ] **Check every relative Markdown link and live documentation URL.**

  Walk Markdown links with a one-off read-only checker; resolve relative links
  from each containing file and fail if the target is absent. Do not check in a
  link-check script yet. Extract and request every HTTP link actually emitted
  by `README.md`, `skills/`, and `.agents/skills`; do not grade only a fixed
  sample. A syntax or behavior claim tied to a supported release must link its
  exact-version upstream documentation or release source. `/latest/` links are
  allowed only when explicitly labeled discovery/general navigation, never as
  the authority for a version-sensitive command claim.

  At minimum also run:

  ```sh
  curl --fail --location --head \
    https://docs.jj-vcs.dev/latest/cli-reference/
  curl --fail --location --head \
    https://docs.jj-vcs.dev/latest/changelog/
  curl --fail --location --head \
    https://agentskills.io/specification
  ```

  Expected: successful HTTP responses. Obtain network approval if sandboxed.

- [ ] **Run all manifest validators again.**

  ```sh
  claude plugin validate --strict .
  agy plugin validate .
  UV_CACHE_DIR="${TMPDIR:-/tmp}/black-belt-uv-cache" \
    uv run --with pyyaml \
    python /Users/colton/.codex/skills/.system/plugin-creator/scripts/validate_plugin.py \
    .
  ```

  Expected: all exit zero.

- [ ] **Prove Codex discovery in a disposable home.**

  If Task 3's repo-root local marketplace source passed, run this entire block
  in one shell so the credential cleanup trap remains active through both
  runtime smokes:

  ```sh
  REAL_CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
  CODEX_TEST_HOME="$(mktemp -d "${TMPDIR:-/tmp}/black-belt-codex.XXXXXX")"
  CODEX_DISCOVERY_ROOT="$(
    mktemp -d "${TMPDIR:-/tmp}/black-belt-codex-discovery.XXXXXX"
  )"
  test -f "$REAL_CODEX_HOME/auth.json"
  install -m 600 "$REAL_CODEX_HOME/auth.json" "$CODEX_TEST_HOME/auth.json"
  cleanup_codex_test_auth() {
    rm -f "$CODEX_TEST_HOME/auth.json"
  }
  trap cleanup_codex_test_auth EXIT HUP INT TERM
  CODEX_HOME="$CODEX_TEST_HOME" codex login status
  CODEX_HOME="$CODEX_TEST_HOME" \
    codex plugin marketplace add /Users/colton/Code/black-belt --json
  CODEX_HOME="$CODEX_TEST_HOME" \
    codex plugin list --marketplace black-belt --available --json
  CODEX_HOME="$CODEX_TEST_HOME" \
    codex plugin add black-belt@black-belt --json
  CODEX_HOME="$CODEX_TEST_HOME" codex plugin list --json
  (
    cd "$CODEX_DISCOVERY_ROOT"
    CODEX_HOME="$CODEX_TEST_HOME" codex exec --ephemeral --json \
      --sandbox read-only \
      --skip-git-repo-check \
      "List every Black Belt skill available to you by exact name. Do not read reference files and do not modify the repository."
  ) > "${TMPDIR:-/tmp}/black-belt-codex-discovery.jsonl"
  (
    cd "$CODEX_DISCOVERY_ROOT"
    CODEX_HOME="$CODEX_TEST_HOME" codex exec --ephemeral --json \
      --sandbox read-only \
      --skip-git-repo-check \
      "Use black-belt:jj-docs. State its authority order without reading a sibling skill or modifying files."
  ) > "${TMPDIR:-/tmp}/black-belt-codex-jj-docs.jsonl"
  cleanup_codex_test_auth
  trap - EXIT HUP INT TERM
  ```

  The list command proves installation, not individual skill names. The first
  runtime trace must show the approved public catalog (initially all nine
  names) and no maintenance skill. The second must invoke `black-belt:jj-docs`
  and no sibling skill.

  If the local marketplace source was rejected, do not create fake metadata.
  Record Codex marketplace publication as deferred until a real remote source
  or validated package layout exists. This does not block the local v0.1
  artifact because the approved design already defers publishable source
  metadata.

  The temporary `auth.json` is sensitive: never print or include it in traces.
  The final two lines remove it after success; the trap performs the same
  cleanup after any earlier failure.

  If the real Codex home has no file-backed credential, stop and ask for an
  approved isolated authentication method or permission to run the smoke in
  the configured host. Do not copy the entire real Codex home.

- [ ] **Prove Claude Code discovery in a disposable home.**

  Create the disposable home and validate the plugin structure first:

  ```sh
  CLAUDE_HOME="$(mktemp -d "${TMPDIR:-/tmp}/black-belt-claude.XXXXXX")"
  HOME="$CLAUDE_HOME" claude plugin marketplace add \
    /Users/colton/Code/black-belt --scope user
  HOME="$CLAUDE_HOME" claude plugin install black-belt@black-belt --scope user
  HOME="$CLAUDE_HOME" claude plugin details black-belt@black-belt
  HOME="$CLAUDE_HOME" claude auth status
  ```

  Plugin details must show the approved public catalog. Runtime authentication
  must then exit zero and report `"loggedIn": true`. The local acceptance
  environment was logged out when this plan was written. If the disposable
  home remains logged out, stop Task 13 and ask the user to approve
  authentication in that home or another isolated authentication method.
  Structural plugin validation may be recorded, but runtime inventory,
  invocation, repository-only discovery, progressive disclosure, `/compact`,
  and the release gate must remain incomplete. Never copy or print Claude
  credentials.

  Once the disposable home is authenticated, retain
  `HOME="$CLAUDE_HOME"` for every Claude runtime gate. Start one fresh session
  with `claude --plugin-dir /Users/colton/Code/black-belt`, inspect `/help`,
  list every Black Belt skill by exact name, and invoke
  `/black-belt:jj-docs`. The list must omit the maintenance skill.

  Separately open this repository as a Claude project and explicitly invoke
  `maintaining-jj-catalog`. If the `.claude/skills` symlink is not discovered,
  replace it with the minimal adapter described in Task 12 and repeat.

- [ ] **Prove Antigravity discovery and rule activation in a disposable home.**

  ```sh
  AGY_HOME="$(mktemp -d "${TMPDIR:-/tmp}/black-belt-agy.XXXXXX")"
  HOME="$AGY_HOME" agy plugin install /Users/colton/Code/black-belt
  HOME="$AGY_HOME" agy plugin list
  ```

  The list command proves the plugin component categories, not individual skill
  names. Run a runtime inventory:

  ```sh
  (
    cd "$REPO"
    HOME="$AGY_HOME" agy --sandbox --print \
      --log-file "${TMPDIR:-/tmp}/black-belt-agy-discovery.log" \
      "List every Black Belt skill available to you by exact name. Do not read reference files and do not modify the repository."
  )
  ```

  Expected: `black-belt` is enabled, the approved public catalog is listed, and
  the maintenance skill is absent. Run a second prompt explicitly invoking
  `jj-docs` and verify no sibling skill is invoked. In a fresh Antigravity
  session, use the core-rule fixture prompt from Task 1. The first trace must
  run the Jujutsu preflight and ask before initialization.

  Official documentation says plugin `rules/*.md` are discovered but does not
  guarantee the activation mode strongly enough to assume “always on.” If this
  behavioral smoke fails, update README installation to require merging the
  rule into `~/.gemini/GEMINI.md`, rerun treatment with that global rule, and
  record the result as a design amendment before proceeding. Do not silently
  diverge from the approved automatic-loading design or retain a false claim.

- [ ] **Prove repository-only maintenance-skill discovery on every host.**

  Open `/Users/colton/Code/black-belt` as the project root in fresh Codex,
  Claude, and Antigravity sessions. Explicitly invoke
  `maintaining-jj-catalog` with this read-only prompt:

  > Use the repository's maintaining-jj-catalog skill. State the supported
  > version window and the first release-maintenance action. Do not modify
  > files.

  Codex and Antigravity must resolve `.agents/skills/maintaining-jj-catalog`;
  Claude must resolve the `.claude/skills` adapter. Record the resolved skill
  path and confirm this repo-only skill was not supplied by the distributed
  plugin.

- [ ] **Verify progressive disclosure in the host traces.**

  Before explicit invocation, no trace may read a public `SKILL.md` body or
  reference file merely to list metadata. When `jj-docs` is invoked, only its
  body may load initially; `references/recipes.md` and the selected leaf may
  load only if the prompt requires drill-down. No sibling skill body may load.
  Use host context diagnostics where available and record any host that cannot
  expose enough evidence rather than asserting lazy loading from prose alone.

- [ ] **Record host-discovery evidence.**

  In `evals/host-discovery.md`, record each host/CLI version, disposable-home
  path, validator result, discovered public skill names, absence of the
  maintenance skill from the distributed plugin, maintenance-skill project
  discovery result, Codex marketplace source outcome, and Antigravity rule
  activation outcome. Keep full raw traces in the temporary evaluation
  directory and the checked-in evidence concise.

- [ ] **Exercise state refresh after compaction or handoff on all three hosts.**

  Install the core rule in each disposable host's active location and make the
  plugin available. Build this fixture with the selected pinned binary:

  ```sh
  FIXTURE_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/black-belt-refresh.XXXXXX")"
  REPO="$FIXTURE_ROOT/repo"
  mkdir -p "$REPO"
  run_jj git init --colocate "$REPO"
  printf 'before\n' > "$REPO/state.txt"
  run_jj -R "$REPO" describe -m 'fixture: before'
  run_jj -R "$REPO" new
  ```

  First prompt:

  > Inspect repository readiness and current state. Make no changes.

  After that response, change state from the harness:

  ```sh
  printf 'after\n' > "$REPO/state.txt"
  run_jj -R "$REPO" describe -m 'fixture: changed after first turn'
  run_jj -R "$REPO" new
  ```

  In Claude, issue `/compact` in the same interactive session. In Codex and
  Antigravity, hand off to a fresh session with the same disposable host
  configuration. Then prompt:

  > Append `continued` on a new line in state.txt, finish it as
  > `Continue after refresh`, and leave a fresh empty working-copy change.

  Passing behavior repeats `jj version`, `jj root`, and `jj status` before
  editing, observes `after` rather than stale `before`, and performs targeted
  verification. Oracle:

  ```sh
  run_jj -R "$REPO" log -r @ --no-graph -T 'empty ++ "\n"'
  run_jj -R "$REPO" log -r @- --no-graph \
    -T 'description.first_line() ++ "\n"'
  run_jj -R "$REPO" file show -r @- state.txt
  run_jj -R "$REPO" diff -r @- --name-only
  ```

  Expected: `true`, `Continue after refresh`, exactly two lines `after` and
  `continued`, and only `state.txt`. Save host-by-host evidence to
  `evals/host-state-refresh.md`. Do not claim a host re-injects skill bodies
  unless the trace proves it; re-invocation is an acceptable recovery route.

- [ ] **Run the complete behavior and version matrix.**

  Review all eleven evaluation summaries: core rule, nine public skills, and
  maintenance. Rerun any case whose fixture, required/forbidden trace, oracle,
  or installed version is missing. Confirm every evaluated public-skill
  workflow, plus every recipe that exists, passed on 0.43.0, 0.42.0, and
  0.41.0.

- [ ] **Perform final verification and checkpoint.**

  ```sh
  jj status
  jj diff --stat
  jj diff
  jj log -r '::@' -n 14 --no-graph \
    -T 'change_id.short() ++ " " ++ description.first_line() ++ "\n"'
  ```

  Expected: only planned files changed in the current release change, no
  placeholder or unvalidated claims remain, and the preceding task checkpoints
  are visible.

  Then:

  ```sh
  jj describe -m "feat: release Black Belt v0.1.0"
  jj new
  jj status
  ```

  Expected: an empty working-copy change above the completed release change.

## Deferred until evidence justifies them

- A checked-in binary downloader or full matrix runner.
- Intel macOS, Linux, and Windows binary matrices.
- A catalog-wide compatibility engine or generated documentation cache.
- More recipes, assets, failure-mode pages, or cross-cutting version-delta
  files.
- Automated compaction evaluation.
- Hooks that block Git commands.
- A Jujutsu MCP server.

Add any of these only after a repeated failure or repeated deterministic
procedure demonstrates the need.
