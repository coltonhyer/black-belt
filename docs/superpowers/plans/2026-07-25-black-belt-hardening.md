# Black Belt Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Close the catalog's four content and durability gaps — working-copy snapshotting, under-specified stack editing and recovery, unmeasured skill routing, and unautomated validation — so Black Belt stays correct without hand-checking.

**Architecture:** Three independent workstreams. (1) An automated `node --test` harness that lints catalog structure, enforces text/manifest sync, and probes every documented `jj` command against the installed binary. (2) New and expanded skill content: a standalone `jj-working-copy` skill, plus nested `references/recipes/` under `jj-stack-editing` and `jj-recovery`. (3) Hygiene: a single source of truth for the supported version window, aligned host manifests, and eval-file provenance. The harness lands first so every later content task is automatically validated.

**Tech Stack:** Node.js 24 (`node --test`, no runtime dependencies), Jujutsu 0.41–0.43, GitHub Actions, Markdown skills with YAML frontmatter.

## Global Constraints

- **This repository uses Jujutsu, not Git.** Never run `git status`, `git add`, `git commit`, `git diff`, or `git log`. Commit steps in this plan use `jj describe -m '<message>'` followed by `jj new`. Before any task, run the preflight: `jj version`, then `jj root`, then `jj status`.
- **Run Jujutsu non-interactively.** Never invoke a command that opens an editor, diff editor, or merge tool. Describe with `-m`; select content with filesets.
- Supported Jujutsu window: **0.41, 0.42, 0.43**. All facts in this plan were verified against **jj 0.42.0**.
- **No runtime npm dependencies.** Tests use only the Node standard library. `package.json` must have no `dependencies` and no `devDependencies`.
- Skill body files stay compact. A `SKILL.md` targets under 60 lines and is gated at a hard ceiling of 70; depth belongs in `references/`.
- Every `SKILL.md` needs YAML frontmatter with exactly `name` and `description`. `name` must equal its directory name. `description` must begin with `Use when `.
- Markdown wraps at **79 columns** to match the existing catalog. Do not reflow files you are not otherwise editing.
- Public skills live in `skills/`. Repository-maintenance skills live in `.agents/skills/` and are excluded from the distributed plugin.
- Never edit `.agents/ledger.db`.

---

## File Structure

**Created:**
- `package.json` — test wiring only; no dependencies.
- `tests/helpers.mjs` — shared filesystem/parsing helpers for all test files.
- `tests/structure.test.mjs` — frontmatter lint and README skill-table coverage.
- `tests/links.test.mjs` — relative-link resolution across all Markdown.
- `tests/sync.test.mjs` — core-rule text sync and host-manifest field sync.
- `tests/jj-surface.test.mjs` — installed-version window check and command/flag probes.
- `jj-support.json` — single machine-readable source for the supported version window.
- `.github/workflows/ci.yml` — CI running the harness against the supported window.
- `skills/jj-working-copy/SKILL.md` — new public skill.
- `skills/jj-stack-editing/references/recipes.md` — recipe index.
- `skills/jj-stack-editing/references/recipes/choose-a-rebase-form.md`
- `skills/jj-stack-editing/references/recipes/split-and-move-changes.md`
- `skills/jj-stack-editing/references/recipes/insert-duplicate-abandon.md`
- `skills/jj-recovery/references/recipes.md` — recipe index.
- `skills/jj-recovery/references/recipes/read-the-operation-log.md`
- `skills/jj-recovery/references/recipes/choose-a-recovery-command.md`
- `evals/README.md` — eval provenance and re-runnability status.
- `evals/skill-routing.md` — new routing eval.

**Modified:**
- `tests/antigravity-jujutsu-context.test.mjs` — reuse shared helpers.
- `README.md` — skill table row, version window sourcing, testing section.
- `skills/jj-stack-editing/SKILL.md` — link to new recipes.
- `skills/jj-recovery/SKILL.md` — link to new recipes.
- `skills/jj-change-workflow/SKILL.md` — merge-change coverage, route to `jj-working-copy`.
- `skills/jj-publish/SKILL.md` — PR handoff sentence.
- `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, `plugin.json` — version alignment.
- `.agents/skills/maintaining-jj-catalog/SKILL.md` — point gates at `npm test`.

---

### Task 1: Test harness foundation

Stand up `node --test` with shared helpers and bring the one existing test under it. No new assertions yet — this task only proves the runner works.

**Files:**
- Create: `package.json`
- Create: `tests/helpers.mjs`
- Modify: `tests/antigravity-jujutsu-context.test.mjs`

**Interfaces:**
- Consumes: nothing.
- Produces: `tests/helpers.mjs` exporting `ROOT: string`, `skillDirs(): string[]` (absolute paths to every directory containing a `SKILL.md`, across `skills/` and `.agents/skills/`), `markdownFiles(): string[]` (absolute paths to every tracked `.md` file in the catalog), `parseFrontmatter(text: string): Record<string,string> | null`, and `readRoot(relPath: string): string`. Every later test task imports from this module.

- [x] **Step 1: Write `tests/helpers.mjs`**

```javascript
import { readdirSync, readFileSync, existsSync, statSync } from "node:fs";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

export const ROOT = fileURLToPath(new URL("..", import.meta.url));

export function readRoot(relPath) {
  return readFileSync(join(ROOT, relPath), "utf8");
}

const SKILL_ROOTS = [join(ROOT, "skills"), join(ROOT, ".agents", "skills")];

export function skillDirs() {
  const found = [];
  for (const root of SKILL_ROOTS) {
    if (!existsSync(root)) continue;
    for (const name of readdirSync(root).sort()) {
      const dir = join(root, name);
      if (statSync(dir).isDirectory() && existsSync(join(dir, "SKILL.md"))) {
        found.push(dir);
      }
    }
  }
  return found;
}

// `docs/` is deliberately excluded: implementation plans quote illustrative
// and intentionally-broken commands that must not be probed as catalog facts.
const MARKDOWN_ROOTS = ["skills", ".agents/skills", "rules", "evals"];
const MARKDOWN_FILES = ["README.md", "AGENTS.md", ".claude/CLAUDE.md"];

function walk(dir, out) {
  for (const entry of readdirSync(dir, { withFileTypes: true }).sort((a, b) =>
    a.name.localeCompare(b.name),
  )) {
    const full = join(dir, entry.name);
    if (entry.isDirectory()) walk(full, out);
    else if (entry.name.endsWith(".md")) out.push(full);
  }
}

export function markdownFiles() {
  const out = [];
  for (const rel of MARKDOWN_ROOTS) {
    const dir = join(ROOT, rel);
    if (existsSync(dir)) walk(dir, out);
  }
  for (const rel of MARKDOWN_FILES) {
    const file = join(ROOT, rel);
    if (existsSync(file)) out.push(file);
  }
  return out;
}

export function parseFrontmatter(text) {
  const match = /^---\n([\s\S]*?)\n---\n/.exec(text);
  if (!match) return null;
  const fields = {};
  for (const line of match[1].split("\n")) {
    const pair = /^([A-Za-z_-]+):\s*(.*)$/.exec(line);
    if (pair) fields[pair[1]] = pair[2].trim();
  }
  return fields;
}
```

- [x] **Step 2: Write `package.json`**

```json
{
  "name": "black-belt",
  "version": "0.1.0",
  "private": true,
  "description": "Jujutsu-first workflows for coding agents.",
  "license": "MIT",
  "type": "module",
  "engines": {
    "node": ">=20"
  },
  "scripts": {
    "test": "node --test tests/"
  }
}
```

- [x] **Step 3: Rewrite `tests/antigravity-jujutsu-context.test.mjs` to use the runner and helpers**

The current file runs bare assertions at module top level. Convert it to a named `node:test` case so failures are attributable.

```javascript
import test from "node:test";
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { ROOT, readRoot } from "./helpers.mjs";

test("antigravity hook injects the core rule regardless of cwd", () => {
  const script = join(ROOT, "hooks", "antigravity-jujutsu-context.mjs");
  const output = execFileSync("node", [script], {
    cwd: tmpdir(),
    encoding: "utf8",
  });

  assert.deepEqual(JSON.parse(output), {
    injectSteps: [{ ephemeralMessage: readRoot("rules/jujutsu-agent.md") }],
  });
});
```

- [x] **Step 4: Run the harness and verify it passes**

Run: `npm test`

Expected: exit code 0, output containing `# pass 1` and `# fail 0`.

- [x] **Step 5: Verify the runner actually reports failures**

A harness that silently passes is worse than none. Prove it fails:

```bash
printf 'import test from "node:test";\nimport assert from "node:assert/strict";\ntest("deliberate failure", () => assert.equal(1, 2));\n' > tests/scratch-probe.test.mjs
npm test; echo "exit=$?"
rm tests/scratch-probe.test.mjs
npm test; echo "exit=$?"
```

Expected: first run prints `exit=1` and names `deliberate failure`; second run prints `exit=0`. Confirm `jj status` shows no leftover `tests/scratch-probe.test.mjs`.

- [x] **Step 6: Commit**

```bash
jj status
jj diff --stat
jj describe -m 'test: add node --test harness and shared helpers'
jj new
```

---

### Task 2: Frontmatter and README skill-table gates

Assert every skill is well-formed and every public skill is advertised in the README table.

**Files:**
- Create: `tests/structure.test.mjs`

**Interfaces:**
- Consumes: `skillDirs()`, `parseFrontmatter()`, `readRoot()` from `tests/helpers.mjs`.
- Produces: nothing consumed by later tasks; the gate itself constrains Tasks 7–10.

- [ ] **Step 1: Write the failing test**

Write `tests/structure.test.mjs`:

```javascript
import test from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { basename, join, sep } from "node:path";
import { skillDirs, parseFrontmatter, readRoot } from "./helpers.mjs";

test("every SKILL.md has well-formed frontmatter", () => {
  for (const dir of skillDirs()) {
    const name = basename(dir);
    const fields = parseFrontmatter(readFileSync(join(dir, "SKILL.md"), "utf8"));

    assert.ok(fields, `${name}: missing YAML frontmatter block`);
    assert.equal(fields.name, name, `${name}: frontmatter name must equal directory name`);
    assert.ok(
      fields.description && fields.description.startsWith("Use when "),
      `${name}: description must start with "Use when "`,
    );
    assert.deepEqual(
      Object.keys(fields).sort(),
      ["description", "name"],
      `${name}: frontmatter must contain exactly name and description`,
    );
  }
});

// Hard ceiling, not the target. Skills should aim well under this; the gate
// exists to stop a SKILL.md silently growing into a reference document.
const SKILL_LINE_CEILING = 70;

test("every SKILL.md body stays compact", () => {
  for (const dir of skillDirs()) {
    const lines = readFileSync(join(dir, "SKILL.md"), "utf8").split("\n").length;
    assert.ok(
      lines <= SKILL_LINE_CEILING,
      `${basename(dir)}: SKILL.md is ${lines} lines, ceiling is ${SKILL_LINE_CEILING}`,
    );
  }
});

test("every public skill appears in the README table", () => {
  const readme = readRoot("README.md");
  const publicSkills = skillDirs()
    .filter((dir) => dir.includes(`${sep}skills${sep}`) && !dir.includes(`.agents${sep}`))
    .map((dir) => basename(dir));

  assert.ok(publicSkills.length > 0, "expected at least one public skill");

  for (const name of publicSkills) {
    assert.ok(
      readme.includes(`\`${name}\``),
      `README.md does not mention public skill \`${name}\``,
    );
  }
});

test("maintenance skills are not advertised as public skills", () => {
  const readme = readRoot("README.md");
  const tableRows = readme
    .split("\n")
    .filter((line) => /^\| `jj-/.test(line))
    .map((line) => line.split("|")[1].trim().replaceAll("`", ""));

  assert.ok(!tableRows.includes("maintaining-jj-catalog"));
});
```

- [ ] **Step 2: Run the tests to verify they pass against the current tree**

Run: `npm test`
Expected: exit 0. All four new cases pass — the catalog is already conformant, so this gate starts green and exists to catch regressions.

- [ ] **Step 3: Prove the gate actually catches a violation**

Run this scratch check, which must exit 1:

```bash
mkdir -p skills/jj-scratch-probe
printf -- '---\nname: wrong-name\n---\n\n# probe\n' > skills/jj-scratch-probe/SKILL.md
npm test; echo "exit=$?"
rm -rf skills/jj-scratch-probe
```

Expected: `exit=1`, with failure text naming `jj-scratch-probe` for both the `name` mismatch, the missing `description`, and the README omission. Confirm `skills/jj-scratch-probe` is deleted and `jj status` is clean of it afterward.

- [ ] **Step 4: Re-run the harness clean**

Run: `npm test`
Expected: exit 0.

- [ ] **Step 5: Commit**

```bash
jj status
jj diff --stat
jj describe -m 'test: gate skill frontmatter and README skill coverage'
jj new
```

---

### Task 3: Relative-link resolution gate

Every relative Markdown link in the catalog must resolve to a real file. This is what makes nested `references/` safe to add in Tasks 8 and 9.

**Files:**
- Create: `tests/links.test.mjs`

**Interfaces:**
- Consumes: `markdownFiles()`, `ROOT` from `tests/helpers.mjs`.
- Produces: nothing consumed by later tasks.

- [ ] **Step 1: Write the test**

Write `tests/links.test.mjs`:

```javascript
import test from "node:test";
import assert from "node:assert/strict";
import { existsSync, readFileSync } from "node:fs";
import { dirname, relative, resolve } from "node:path";
import { markdownFiles, ROOT } from "./helpers.mjs";

const LINK = /\[[^\]]*\]\(([^)\s]+)(?:\s+"[^"]*")?\)/g;
const EXTERNAL = /^(https?:|mailto:|#)/;

test("every relative Markdown link resolves to a real file", () => {
  const broken = [];

  for (const file of markdownFiles()) {
    const text = readFileSync(file, "utf8");
    for (const match of text.matchAll(LINK)) {
      const target = match[1];
      if (EXTERNAL.test(target)) continue;

      const [path] = target.split("#");
      if (path === "") continue;

      const resolved = resolve(dirname(file), path);
      if (!existsSync(resolved)) {
        broken.push(`${relative(ROOT, file)} -> ${target}`);
      }
    }
  }

  assert.deepEqual(broken, [], `broken relative links:\n${broken.join("\n")}`);
});

test("skills reference other skills by name, not by relative path", () => {
  const offenders = [];

  for (const file of markdownFiles()) {
    if (!file.includes("SKILL.md")) continue;
    const text = readFileSync(file, "utf8");
    for (const match of text.matchAll(LINK)) {
      const target = match[1];
      if (EXTERNAL.test(target)) continue;
      if (target.includes("../")) {
        offenders.push(`${relative(ROOT, file)} -> ${target}`);
      }
    }
  }

  assert.deepEqual(
    offenders,
    [],
    `SKILL.md files must not link across skill directories; route by skill name instead:\n${offenders.join("\n")}`,
  );
});
```

- [ ] **Step 2: Run and verify it passes**

Run: `npm test`
Expected: exit 0. The existing `jj-docs` links (`references/recipes.md` and `references/recipes/check-feature-maturity.md`) resolve, and no `SKILL.md` uses `../`.

- [ ] **Step 3: Prove the gate catches a broken link**

```bash
printf '\n[dangling](references/does-not-exist.md)\n' >> skills/jj-docs/SKILL.md
npm test; echo "exit=$?"
jj restore skills/jj-docs/SKILL.md
```

Expected: `exit=1` naming `skills/jj-docs/SKILL.md -> references/does-not-exist.md`. `jj restore` returns the file to its committed content — confirm with `jj status` showing no change to that path.

- [ ] **Step 4: Re-run clean**

Run: `npm test`
Expected: exit 0.

- [ ] **Step 5: Commit**

```bash
jj status
jj diff --stat
jj describe -m 'test: gate relative Markdown link resolution'
jj new
```

---

### Task 4: Core-rule and host-manifest sync gates

The core rule exists verbatim in two places because Codex requires a literal `AGENTS.md`. Port the existing shell/python manifest gate to Node so one command runs everything.

**Files:**
- Create: `tests/sync.test.mjs`
- Modify: `.agents/skills/maintaining-jj-catalog/SKILL.md`

**Interfaces:**
- Consumes: `readRoot()`, `ROOT` from `tests/helpers.mjs`.
- Produces: nothing consumed by later tasks. `.agents/skills/maintaining-jj-catalog/scripts/check-manifest-sync.sh` is **kept**, not deleted — the release workflow still calls it directly. The Node test duplicates its assertions so `npm test` is self-contained.

- [ ] **Step 1: Confirm the current relationship between the two files**

Run: `diff rules/jujutsu-agent.md AGENTS.md`

Expected (verified against the current tree): exit 1 with exactly this output —

```
24a25,27
> 
> When updating the catalog for a Jujutsu release, use
> `.agents/skills/maintaining-jj-catalog`.
```

`AGENTS.md` is the rule file verbatim plus one trailing paragraph. That is why the test below asserts **containment**, not equality. If the diff shows anything else, the files have already drifted — reconcile them before writing the gate.

- [ ] **Step 2: Write the test**

Write `tests/sync.test.mjs`:

```javascript
import test from "node:test";
import assert from "node:assert/strict";
import { existsSync } from "node:fs";
import { join } from "node:path";
import { ROOT, readRoot } from "./helpers.mjs";

function ruleBody() {
  // Drop the leading "# Jujutsu agent" heading; compare prose only.
  return readRoot("rules/jujutsu-agent.md").replace(/^#[^\n]*\n\n/, "").trim();
}

test("AGENTS.md carries the canonical core rule verbatim", () => {
  const agents = readRoot("AGENTS.md");
  const missing = ruleBody()
    .split("\n\n")
    .filter((paragraph) => !agents.includes(paragraph));

  assert.deepEqual(
    missing,
    [],
    `AGENTS.md has drifted from rules/jujutsu-agent.md. Missing paragraphs:\n${missing.join("\n---\n")}`,
  );
});

const MANIFESTS = [
  "plugin.json",
  ".claude-plugin/plugin.json",
  ".codex-plugin/plugin.json",
  ".claude-plugin/marketplace.json",
  ".agents/plugins/marketplace.json",
];

function load(rel) {
  return JSON.parse(readRoot(rel));
}

test("plugin name agrees across every host manifest", () => {
  for (const rel of MANIFESTS) {
    assert.equal(load(rel).name, "black-belt", `${rel}: unexpected top-level name`);
  }

  for (const rel of [".claude-plugin/marketplace.json", ".agents/plugins/marketplace.json"]) {
    for (const entry of load(rel).plugins ?? []) {
      assert.equal(entry.name, "black-belt", `${rel}: unexpected plugin entry name`);
    }
  }
});

test("description agrees across every manifest that declares one", () => {
  const rels = [
    "plugin.json",
    ".claude-plugin/plugin.json",
    ".codex-plugin/plugin.json",
    ".claude-plugin/marketplace.json",
  ];
  const values = new Set(rels.map((rel) => load(rel).description));
  assert.equal(values.size, 1, `descriptions disagree: ${[...values].join(" | ")}`);
});

test("version agrees across every manifest that declares one", () => {
  const rels = [".claude-plugin/plugin.json", ".codex-plugin/plugin.json", "package.json"];
  const values = new Set(rels.map((rel) => load(rel).version));
  assert.equal(values.size, 1, `versions disagree: ${[...values].join(" | ")}`);
});

test("author and owner display names agree", () => {
  const values = new Set([
    load(".claude-plugin/plugin.json").author?.name,
    load(".codex-plugin/plugin.json").author?.name,
    load(".claude-plugin/marketplace.json").owner?.name,
  ]);
  assert.equal(values.size, 1, `author/owner names disagree: ${[...values].join(" | ")}`);
});

test("every manifest path reference points at a real file", () => {
  const skillsDir = load(".codex-plugin/plugin.json").skills;
  assert.ok(skillsDir, ".codex-plugin/plugin.json must declare a skills directory");
  assert.ok(
    existsSync(join(ROOT, skillsDir.replace(/^\.\//, ""))),
    `.codex-plugin/plugin.json skills path missing: ${skillsDir}`,
  );

  const command = readRoot("hooks.json");
  const scriptMatch = /node \.\/(\S+\.mjs)/.exec(command);
  assert.ok(scriptMatch, "hooks.json must invoke a .mjs hook script");
  assert.ok(
    existsSync(join(ROOT, scriptMatch[1])),
    `hooks.json references a missing script: ${scriptMatch[1]}`,
  );
});
```

- [ ] **Step 3: Run the tests**

Run: `npm test`

Expected: exit 0 — all six cases pass. `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`, and the `package.json` written in Task 1 are all at `0.1.0`, so the version case is already satisfied. If any case fails, its message names the disagreeing values; align them to `0.1.0` and re-run rather than loosening the assertion.

- [ ] **Step 4: Add a version field to the Antigravity manifest**

The root `plugin.json` has no `version`. Add one so all three plugin manifests agree, and extend the test. Edit `plugin.json` to:

```json
{
  "$schema": "https://antigravity.google/schemas/v1/plugin.json",
  "name": "black-belt",
  "version": "0.1.0",
  "description": "Jujutsu-first workflows for coding agents."
}
```

Then change the version test's `rels` array in `tests/sync.test.mjs` to include it:

```javascript
  const rels = [
    "plugin.json",
    ".claude-plugin/plugin.json",
    ".codex-plugin/plugin.json",
    "package.json",
  ];
```

- [ ] **Step 5: Run and verify**

Run: `npm test`
Expected: exit 0.

- [ ] **Step 6: Prove the sync gate catches drift**

```bash
node -e 'const f=".codex-plugin/plugin.json";const j=require("fs");const o=JSON.parse(j.readFileSync(f));o.version="9.9.9";j.writeFileSync(f,JSON.stringify(o,null,2)+"\n")'
npm test; echo "exit=$?"
jj restore .codex-plugin/plugin.json
npm test
```

Expected: first `npm test` exits 1 with `versions disagree: 0.1.0 | 9.9.9`; after `jj restore`, exit 0.

- [ ] **Step 7: Point the maintenance skill's gates at `npm test`**

In `.agents/skills/maintaining-jj-catalog/SKILL.md`, replace this sentence:

```
The shared metadata fields must agree
across all host manifests; run `scripts/check-manifest-sync.sh` to enforce it.
```

with:

```
Run `npm test` for the structural, link, sync, and installed-surface gates;
`scripts/check-manifest-sync.sh` remains the standalone manifest check.
```

Confirm the file still passes the 70-line ceiling from Task 2.

- [ ] **Step 8: Commit**

```bash
jj status
jj diff --stat
jj describe -m 'test: gate core-rule and host-manifest sync'
jj new
```

---

### Task 5: Version window source and installed-surface probes

Make the supported window machine-readable, and probe every `jj` command the catalog documents against the installed binary. This is the gate that catches upstream drift — for example, `jj rebase` moving its primary destination flag from `-d/--destination` to `-o/--onto`.

**Files:**
- Create: `jj-support.json`
- Create: `tests/jj-surface.test.mjs`
- Modify: `README.md`

**Interfaces:**
- Consumes: `markdownFiles()`, `readRoot()` from `tests/helpers.mjs`.
- Produces: `jj-support.json` with shape `{ "supported": string[] }`, newest first. Task 6's CI matrix reads it.

**Design note for the implementer:** the probe never runs a documented command for real — that could mutate the repository. It verifies (a) the subcommand path exists via `jj <sub...> --help`, and (b) each flag literal appears in that help text. This is non-mutating and deterministic.

- [ ] **Step 1: Create `jj-support.json`**

```json
{
  "supported": ["0.43", "0.42", "0.41"]
}
```

- [ ] **Step 2: Write the failing test**

Write `tests/jj-surface.test.mjs`:

```javascript
import test from "node:test";
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { relative } from "node:path";
import { markdownFiles, readRoot, ROOT } from "./helpers.mjs";

const SUPPORTED = JSON.parse(readRoot("jj-support.json")).supported;

function jj(args) {
  return execFileSync("jj", args, { encoding: "utf8", stdio: ["ignore", "pipe", "pipe"] });
}

function installedVersion() {
  const match = /(\d+)\.(\d+)\.(\d+)/.exec(jj(["--version"]));
  assert.ok(match, "could not parse jj --version");
  return { minor: `${match[1]}.${match[2]}`, full: match[0] };
}

test("installed jj is inside the supported window", () => {
  const { minor, full } = installedVersion();
  assert.ok(
    SUPPORTED.includes(minor),
    `installed jj ${full} (minor ${minor}) is outside the supported window ${SUPPORTED.join(", ")}`,
  );
});

test("README advertises exactly the supported window", () => {
  const readme = readRoot("README.md");
  for (const version of SUPPORTED) {
    assert.ok(readme.includes(version), `README.md does not mention supported version ${version}`);
  }
});

// --- command extraction -------------------------------------------------

// Subcommands that take a second word. Anything not listed is single-word.
const NESTED = new Set([
  "git", "op", "operation", "file", "bookmark", "util", "workspace", "config", "sparse",
]);

// Illustrative placeholders that are not real flags.
const PLACEHOLDER = /^-{1,2}[<{]/;

function extractInvocations(text) {
  // Strip quoted spans so revset operators are not parsed as flags.
  const cleaned = text.replaceAll(/'[^']*'/g, " ARG ").replaceAll(/"[^"]*"/g, " ARG ");
  const found = [];

  for (const match of cleaned.matchAll(/\bjj\s+([^\n`|;&]+)/g)) {
    const tokens = match[1].trim().split(/\s+/).filter(Boolean);
    if (tokens.length === 0) continue;
    if (tokens[0].startsWith("-")) continue; // `jj --version` etc.

    const sub = [tokens[0]];
    let rest = tokens.slice(1);
    if (NESTED.has(tokens[0]) && rest[0] && !rest[0].startsWith("-")) {
      sub.push(rest[0]);
      rest = rest.slice(1);
    }

    const flags = rest
      .filter((token) => token.startsWith("-") && token !== "-")
      .map((token) => token.split("=")[0])
      .filter((token) => !PLACEHOLDER.test(token));

    found.push({ sub, flags });
  }

  return found;
}

const helpCache = new Map();

function helpFor(sub) {
  const key = sub.join(" ");
  if (!helpCache.has(key)) {
    try {
      helpCache.set(key, jj([...sub, "--help"]));
    } catch {
      helpCache.set(key, null);
    }
  }
  return helpCache.get(key);
}

test("every documented jj subcommand exists on the installed version", () => {
  const missing = new Set();

  for (const file of markdownFiles()) {
    for (const { sub } of extractInvocations(readFileSync(file, "utf8"))) {
      if (helpFor(sub) === null) {
        missing.add(`${sub.join(" ")}  (in ${relative(ROOT, file)})`);
      }
    }
  }

  assert.deepEqual([...missing], [], `unknown jj subcommands:\n${[...missing].join("\n")}`);
});

test("every documented jj flag exists on its subcommand", () => {
  const missing = new Set();

  for (const file of markdownFiles()) {
    for (const { sub, flags } of extractInvocations(readFileSync(file, "utf8"))) {
      const help = helpFor(sub);
      if (help === null) continue; // reported by the previous test
      for (const flag of flags) {
        if (!help.includes(flag)) {
          missing.add(`jj ${sub.join(" ")} ${flag}  (in ${relative(ROOT, file)})`);
        }
      }
    }
  }

  assert.deepEqual([...missing], [], `unknown jj flags:\n${[...missing].join("\n")}`);
});
```

- [ ] **Step 3: Run and verify**

Run: `npm test`

Expected: exit 0. Every `jj` invocation currently in `skills/`, `.agents/skills/`, `rules/`, `evals/`, `README.md`, and `AGENTS.md` was verified against jj 0.42.0 while this plan was written — including `jj git init --colocate`, `jj log -r/-n/-T/--no-graph`, `jj op log --limit`, `jj op diff --operation`, `jj file untrack`, `jj git push --dry-run/--bookmark/--remote`, and `jj resolve --tool`. The probe should start green.

If it does report a failure, the cause is one of three things, in order of likelihood:

1. **A real drift** — the installed jj renamed or removed something. Fix the catalog text, never the gate.
2. **A prose false positive** — a sentence that reads like an invocation but is not. Add the exact subcommand string to this set near the top of the file and skip it in both probe tests, with a comment saying why:

   ```javascript
   // Prose phrasings that parse as invocations but are not commands.
   const IGNORED_SUBCOMMANDS = new Set([]);
   ```

3. **A tokenizer bug** — a quoting form the cleaner does not handle. Extend the quote-stripping, and add the offending line to this task's notes so the next maintainer sees it.

Do not broaden the regex to make a failure disappear without deciding which of the three it is.

- [ ] **Step 4: Prove the probe catches drift**

```bash
printf '\n```sh\njj rebase -r @ --destination-of-yore x\n```\n' >> skills/jj-stack-editing/SKILL.md
npm test; echo "exit=$?"
jj restore skills/jj-stack-editing/SKILL.md
npm test
```

Expected: first run exits 1 naming `jj rebase --destination-of-yore`; after restore, exit 0.

- [ ] **Step 5: Source the README version window from `jj-support.json`**

Edit `README.md` lines 3–9 so the window is stated once as prose that the gate checks, and add a pointer to the source of truth. Replace:

```markdown
Black Belt is a Jujutsu-first skill catalog for coding agents. It supports
Jujutsu 0.43, 0.42, and 0.41.
```

with:

```markdown
Black Belt is a Jujutsu-first skill catalog for coding agents. It supports
Jujutsu 0.43, 0.42, and 0.41, declared in
[`jj-support.json`](jj-support.json) and enforced by `npm test`.
```

- [ ] **Step 6: Add a Testing section to the README**

Insert immediately before the `## License` heading:

```markdown
## Testing

```sh
npm test
```

The harness needs Node.js and a `jj` binary inside the supported window. It
lints skill frontmatter, resolves every relative link, checks that the core
rule and host manifests have not drifted, and probes every documented `jj`
subcommand and flag against the installed binary.
```

- [ ] **Step 7: Run the full harness**

Run: `npm test`
Expected: exit 0.

- [ ] **Step 8: Commit**

```bash
jj status
jj diff --stat
jj describe -m 'test: probe documented jj surface against installed version'
jj new
```

---

### Task 6: CI workflow

**Files:**
- Create: `.github/workflows/ci.yml`

**Interfaces:**
- Consumes: `npm test` from Task 1, `jj-support.json` from Task 5.
- Produces: nothing consumed by later tasks.

- [ ] **Step 1: Write the workflow**

Create `.github/workflows/ci.yml`. The matrix is written out literally rather than read from `jj-support.json`, because GitHub Actions cannot read a file to build a matrix without an extra job; keep it in sync manually and let the version-window test catch mismatches.

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        jj: ["0.41.0", "0.42.0", "0.43.0"]
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: "22"

      - name: Install jj ${{ matrix.jj }}
        run: |
          set -euo pipefail
          url="https://github.com/jj-vcs/jj/releases/download/v${{ matrix.jj }}/jj-v${{ matrix.jj }}-x86_64-unknown-linux-musl.tar.gz"
          curl --fail --location --silent --show-error "$url" -o /tmp/jj.tar.gz
          mkdir -p /tmp/jj-bin
          tar -xzf /tmp/jj.tar.gz -C /tmp/jj-bin
          echo /tmp/jj-bin >> "$GITHUB_PATH"

      - name: Show versions
        run: |
          node --version
          jj --version

      - name: Run harness
        run: npm test
```

- [ ] **Step 2: Verify the workflow file parses**

Run: `node -e "const t=require('fs').readFileSync('.github/workflows/ci.yml','utf8'); if(!/jobs:/.test(t)) throw new Error('missing jobs'); console.log('ok')"`
Expected: `ok`

- [ ] **Step 3: Verify the matrix matches the declared window**

Run:

```bash
node -e '
const fs = require("fs");
const supported = JSON.parse(fs.readFileSync("jj-support.json")).supported;
const yaml = fs.readFileSync(".github/workflows/ci.yml", "utf8");
for (const v of supported) {
  if (!yaml.includes(`"${v}.`)) throw new Error(`CI matrix is missing jj ${v}`);
}
console.log("matrix ok");
'
```

Expected: `matrix ok`

- [ ] **Step 4: Run the harness locally one more time**

Run: `npm test`
Expected: exit 0.

- [ ] **Step 5: Commit**

```bash
jj status
jj diff --stat
jj describe -m 'ci: run harness across the supported jj window'
jj new
```

---

### Task 7: `jj-working-copy` skill

The catalog's largest content gap. Agents run builds and test suites constantly; jj snapshots the whole working copy into `@` before every command, so generated files enter the change with no staging step to catch them.

**Files:**
- Create: `skills/jj-working-copy/SKILL.md`
- Modify: `README.md`
- Modify: `skills/jj-change-workflow/SKILL.md`

**Interfaces:**
- Consumes: gates from Tasks 2, 3, 5 — the new skill must satisfy frontmatter, link, and command-probe rules.
- Produces: skill name `jj-working-copy`, routed to from `jj-change-workflow`.

**Verified facts (jj 0.42.0) — use these exactly:**
- Defaults: `snapshot.max-new-file-size = "1MiB"`, `snapshot.auto-track = "all()"`.
- `jj file track <filesets>` and `jj file untrack <filesets>` exist under `jj file`.
- **`jj file untrack` requires the path to already be ignored.** Its help states: "Paths to untrack. They must already be ignored." So the order is: add the ignore rule first, then untrack.
- Ignore sources: `.gitignore`, and `.git/info/exclude` in colocated workspaces.
- The global flag `--ignore-working-copy` skips snapshotting for one command.
- `jj util snapshot` snapshots the working copy on demand.

- [ ] **Step 1: Write the skill**

Create `skills/jj-working-copy/SKILL.md`:

```markdown
---
name: jj-working-copy
description: Use when generated or untracked files enter a change, a snapshot fails on file size, or ignore and tracking rules must be adjusted.
---

# The Jujutsu working copy

Jujutsu snapshots the working copy into `@` at the start of every command.
There is no staging area and no opt-in add step: by default
`snapshot.auto-track` is `all()`, so build output, caches, and test artifacts
join the change as soon as any `jj` command runs. Ignore rules are the only
thing that keeps them out.

## Before running a build or test suite

1. Inspect `jj status` and confirm which paths the tool will generate.
2. Add those paths to `.gitignore` before running the tool. A colocated
   workspace also honors `.git/info/exclude` for rules that should stay
   local.
3. Run the tool, then re-inspect `jj status` and `jj diff --stat` to confirm
   only intended paths entered the change.

## Remove a generated file already in the change

Order matters: `jj file untrack` refuses a path that is not already ignored.

1. Add the path to `.gitignore` first.
2. Untrack it by fileset:

   ```sh
   jj file untrack 'target/**'
   ```

3. Verify with `jj status` and a targeted `jj diff`. The file stays on disk;
   only its tracking stops.

Track a path that ignore rules currently exclude with
`jj file track <fileset>`.

## A snapshot fails on file size

`snapshot.max-new-file-size` defaults to `1MiB`, and a larger new file makes
the snapshot fail rather than silently including it. Treat that as a signal
that the path is generated. Ignore and untrack it. Raise the limit only when
a genuinely large file belongs in history, and say so explicitly rather than
adjusting the setting to make an error disappear.

Use `--ignore-working-copy` only to inspect state without snapshotting; it
does not fix an ignore-rule problem.

Route ordinary change work to `jj-change-workflow` and use `jj-docs` to
resolve installed-version behavior for tracking or snapshot configuration.
```

- [ ] **Step 2: Verify the gates accept it**

Run: `npm test`
Expected: FAIL on the README coverage test with `README.md does not mention public skill \`jj-working-copy\``. This confirms Task 2's gate is doing its job.

- [ ] **Step 3: Add the README table row**

In `README.md`, add this row to the Public skills table, immediately after the `jj-change-workflow` row:

```markdown
| `jj-working-copy` | Snapshotting, ignores, and file tracking |
```

- [ ] **Step 4: Route to it from `jj-change-workflow`**

In `skills/jj-change-workflow/SKILL.md`, replace the Scope paragraph:

```
This is for one ordinary local change. Route stack edits, conflicts, recovery,
workspaces, and publishing to their specialized skills. Use `jj-docs` only
when installed help is needed to resolve version-specific behavior.
```

with:

```
This is for one ordinary local change. Route stack edits, conflicts, recovery,
workspaces, and publishing to their specialized skills. Every command
snapshots the working copy first, so route generated files, ignore rules, and
tracking to `jj-working-copy` before running a build or test suite. Use
`jj-docs` only when installed help is needed to resolve version-specific
behavior.
```

- [ ] **Step 5: Run the full harness**

Run: `npm test`
Expected: exit 0. The command probe must confirm `jj file untrack`, `jj file track`, and `--ignore-working-copy` all exist on the installed binary.

- [ ] **Step 6: Commit**

```bash
jj status
jj diff --stat
jj describe -m 'feat: add jj-working-copy skill for snapshotting and ignores'
jj new
```

---

### Task 8: `jj-stack-editing` recipes

The highest-risk skill is the least concrete. `jj rebase -r` vs `-s` vs `-b` is exactly where a Git-shaped agent silently restructures a stack.

**Files:**
- Create: `skills/jj-stack-editing/references/recipes.md`
- Create: `skills/jj-stack-editing/references/recipes/choose-a-rebase-form.md`
- Create: `skills/jj-stack-editing/references/recipes/split-and-move-changes.md`
- Create: `skills/jj-stack-editing/references/recipes/insert-duplicate-abandon.md`
- Modify: `skills/jj-stack-editing/SKILL.md`

**Interfaces:**
- Consumes: link gate (Task 3) and command probe (Task 5).
- Produces: nothing consumed by later tasks.

**Verified facts (jj 0.42.0) — use these exactly:**
- `jj rebase` selects what to move with `-s/--source` (revision **and** descendants), `-b/--branch` (the whole branch relative to the destination), `-r/--revisions` (the named revisions **without** descendants). With no selector it defaults to `-b @`.
- `jj rebase` selects where with `-o/--onto`, `-A/--insert-after`, `-B/--insert-before`. **`-d/--destination` still works as an alias in 0.42 but `-o/--onto` is the documented primary spelling** — prefer `--onto`.
- `jj split [FILESETS]...` is interactive **only when no filesets are given**. Passing filesets is the non-interactive form. It also accepts `-r/--revision`, `-o/--onto`, `-A/--insert-after`, `-B/--insert-before`.
- `jj squash` moves `@` into its parent by default; `-r` moves a named revision into its parent; `--from` and `--into` name both ends. `-i/--interactive` opens an editor — avoid.
- `jj absorb` splits the source revision and moves each hunk to the closest mutable ancestor that last touched those lines. It abandons the source if everything absorbed and the source had no description.
- `jj duplicate` copies content to new changes; with none of `--onto`, `--insert-after`, `--insert-before` it duplicates onto existing parents.
- `jj abandon` removes a revision and rebases its descendants onto its parents. Abandoning the working-copy commit yields a new empty one.

- [ ] **Step 1: Write the recipe index**

Create `skills/jj-stack-editing/references/recipes.md`:

```markdown
# jj-stack-editing recipes

- [Choose a rebase form](recipes/choose-a-rebase-form.md) — pick between `-r`, `-s`, and `-b`, and between `--onto`, `-A`, and `-B`.
- [Split and move changes](recipes/split-and-move-changes.md) — divide a revision or move hunks into an ancestor without an editor.
- [Insert, duplicate, abandon](recipes/insert-duplicate-abandon.md) — add a change mid-stack, copy one, or drop one.
```

- [ ] **Step 2: Write the rebase recipe**

Create `skills/jj-stack-editing/references/recipes/choose-a-rebase-form.md`:

```markdown
# Choose a rebase form

`jj rebase` takes one selector for *what* moves and one for *where* it lands.
Choosing the wrong selector silently restructures the stack, so decide both
before running anything.

## What moves

| Selector | Moves | Use when |
|---|---|---|
| `-s`, `--source` | the revision **and all its descendants** | relocating a subtree |
| `-r`, `--revisions` | only the named revisions, **descendants stay** | extracting one change out of a stack |
| `-b`, `--branch` | the whole branch containing the revision, relative to the destination | replaying local work onto an updated base |

With no selector at all, `jj rebase` defaults to `-b @`. Never rely on that
default; name the selector.

## Where it lands

| Selector | Result |
|---|---|
| `-o`, `--onto` | the moved revisions become children of the target |
| `-A`, `--insert-after` | moved onto the target, and the target's descendants are rebased onto the moved revisions |
| `-B`, `--insert-before` | moved onto the target's parents, and the target and its descendants are rebased onto the moved revisions |

`-d`/`--destination` is still accepted as an alias for `--onto`, but prefer
`--onto`; much older material uses `-d` and the spellings are easy to confuse.

## Procedure

1. Inspect the subgraph before deciding:

   ```sh
   jj log -r 'ancestors(@, 5) | descendants(@-, 3)'
   ```

2. State the intended parent/child result in words, then choose the two
   selectors that produce it.
3. Run one rebase. Do not chain several to grope toward the shape.
4. Verify the new graph and that change IDs survived:

   ```sh
   jj log -r 'ancestors(@, 5)'
   jj status
   ```

If the rebase reports an immutable target, stop. That is the
`immutable_heads()` guardrail, not an obstacle to force past.
```

- [ ] **Step 3: Write the split/squash recipe**

Create `skills/jj-stack-editing/references/recipes/split-and-move-changes.md`:

```markdown
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
```

- [ ] **Step 4: Write the insert/duplicate/abandon recipe**

Create `skills/jj-stack-editing/references/recipes/insert-duplicate-abandon.md`:

```markdown
# Insert, duplicate, abandon

## Insert a new change mid-stack

`jj new` accepts the same placement selectors as `jj rebase`:

```sh
jj new --insert-after <revision> -m 'description'
jj log -r 'ancestors(@, 4)'
```

`--insert-after` relocates the target's children onto the new change;
`--insert-before` places it ahead of the target. Passing several revisions as
plain arguments instead creates a merge: `jj new <a> <b>` makes a change with
both as parents.

## Duplicate a change

```sh
jj duplicate -r <revision> --onto <target>
```

Duplicating produces a **new change ID** with the same content — the original
is untouched. With none of `--onto`, `--insert-after`, or `--insert-before`,
the copy lands on the original's existing parents.

## Abandon a change

```sh
jj abandon -r <revision>
jj log -r 'ancestors(@, 5)'
```

Descendants are rebased onto the abandoned revision's parents, so the stack
closes up rather than breaking. Abandoning the working-copy commit yields a
fresh empty one.

Abandoning is recoverable: `jj undo` reverses it, and `jj op log` retains the
prior state. Route anything beyond a single reversal to `jj-recovery`.
```

- [ ] **Step 5: Link the recipes from the skill**

In `skills/jj-stack-editing/SKILL.md`, replace the final paragraph:

```
Use `jj-docs` to resolve installed-version syntax and behavior before relying
on an editing command. Route conflict resolution and recovery to their
specialized skills.
```

with:

```
For selector choice, splitting, and structural edits, use
[the recipe index](references/recipes.md). Use `jj-docs` to resolve
installed-version syntax and behavior before relying on an editing command.
Route conflict resolution and recovery to their specialized skills.
```

- [ ] **Step 6: Run the harness**

Run: `npm test`

Expected: exit 0. The command probe verifies every flag cited above — `-s`, `-r`, `-b`, `-o`, `-A`, `-B`, `--from`, `--into`, `--onto`, `--insert-after` — against the installed binary. If a flag is reported missing, the recipe is wrong; fix the recipe, never the gate.

- [ ] **Step 7: Commit**

```bash
jj status
jj diff --stat
jj describe -m 'docs(jj-stack-editing): add rebase, split, and structural recipes'
jj new
```

---

### Task 9: `jj-recovery` recipes

The skill names `undo`, `op revert`, and `op restore` correctly but never shows how to read `jj op log` to pick an operation.

**Files:**
- Create: `skills/jj-recovery/references/recipes.md`
- Create: `skills/jj-recovery/references/recipes/read-the-operation-log.md`
- Create: `skills/jj-recovery/references/recipes/choose-a-recovery-command.md`
- Modify: `skills/jj-recovery/SKILL.md`

**Interfaces:**
- Consumes: link gate (Task 3) and command probe (Task 5).
- Produces: nothing consumed by later tasks.

**Verified facts (jj 0.42.0) — use these exactly:**
- `jj op` (aliased `jj operation`) has subcommands: `abandon`, `diff`, `integrate`, `log`, `restore`, `revert`, `show`.
- `jj op restore <OPERATION>` — operation argument is **required**; restores repo state to that operation, effectively undoing all later ones, by creating a new operation.
- `jj op revert [OPERATION]` — operation argument is **optional**; applies the inverse of one operation.
- `jj undo` undoes the last operation; used repeatedly it walks further back. `jj redo` moves forward again.
- `jj evolog` shows how one change evolved — the commits a change has pointed to.
- `jj --at-op=<id>` inspects the repo as of an operation without changing anything.

- [ ] **Step 1: Write the recipe index**

Create `skills/jj-recovery/references/recipes.md`:

```markdown
# jj-recovery recipes

- [Read the operation log](recipes/read-the-operation-log.md) — identify the operation that caused the wrong state before reversing anything.
- [Choose a recovery command](recipes/choose-a-recovery-command.md) — pick between `undo`, `op revert`, and `op restore`.
```

- [ ] **Step 2: Write the operation-log recipe**

Create `skills/jj-recovery/references/recipes/read-the-operation-log.md`:

```markdown
# Read the operation log

Identify the operation before reversing anything. Blind repeated `jj undo`
obscures what happened and is itself recorded as new operations.

## Find the operation that caused the wrong state

```sh
jj op log --limit 10
```

Each entry carries an operation ID, the command that produced it, and a
timestamp. Read downward until you reach the last state that was correct —
that is the operation you restore *to*; the one after it is the operation you
revert.

For stable output rather than the human-facing graph:

```sh
jj op log --no-graph --limit 10 -T 'id.short() ++ " " ++ description ++ "\n"'
```

## Inspect a candidate before acting

Never reverse an operation you have not looked at.

```sh
jj op show <operation>
jj op diff --operation <operation>
```

To view the whole repository as it was, without changing anything:

```sh
jj --at-op=<operation> log -r 'ancestors(@, 10)'
jj --at-op=<operation> status
```

`--at-op` is read-only. It is the safest way to confirm a candidate holds the
work you are missing.

## Trace one change rather than the whole repo

When a single change was rewritten and its content looks wrong, its own
history is the narrower surface:

```sh
jj evolog -r <change>
```

This lists the commits that change has pointed to across rewrites, which
identifies the pre-rewrite commit to restore content from.
```

- [ ] **Step 3: Write the command-choice recipe**

Create `skills/jj-recovery/references/recipes/choose-a-recovery-command.md`:

```markdown
# Choose a recovery command

Pick the narrowest command that reaches the intended state.

| Command | Effect | Use when |
|---|---|---|
| `jj undo` | undoes the last operation; repeat to walk further back | the very last thing you did was wrong |
| `jj op revert <operation>` | applies the inverse of **one** operation, keeping later ones | one earlier operation was wrong but later work is good |
| `jj op restore <operation>` | resets the whole repo to that operation, discarding everything after | several operations compounded and later work is disposable |

`jj op revert` takes an optional operation argument; `jj op restore` requires
one. Both create a new operation, so neither is destructive to the log itself.

## Procedure

1. Identify and inspect the operation first — see
   [Read the operation log](read-the-operation-log.md).
2. Confirm which of the three commands matches the scope of the damage. If
   later operations must survive, `op restore` is the wrong tool.
3. Run exactly one command.
4. Verify the result — change IDs, graph shape, and file content:

   ```sh
   jj status
   jj log -r 'ancestors(@, 10)'
   jj diff -r <change>
   ```

5. If the result is still wrong, **stop and re-read `jj op log`** rather than
   running another reversal. `jj undo` is itself an operation; stacking blind
   reversals makes the intended state harder to reach.

`jj redo` moves forward again after one or more undos, which is the correct
response to overshooting.

If recovery would rewrite an immutable revision, stop. That is the
`immutable_heads()` guardrail, not an obstacle to force past.
```

- [ ] **Step 4: Link the recipes from the skill**

In `skills/jj-recovery/SKILL.md`, replace the final paragraph:

```
Use `jj-docs` to resolve installed syntax for inspecting an operation or
restoring it.
```

with:

```
To identify an operation and pick the narrowest reversal, use
[the recipe index](references/recipes.md). Use `jj-docs` to resolve installed
syntax for inspecting an operation or restoring it.
```

- [ ] **Step 5: Run the harness**

Run: `npm test`
Expected: exit 0. The probe verifies `jj op log`, `jj op show`, `jj op diff`, `jj op revert`, `jj op restore`, `jj evolog`, and `jj redo` on the installed binary.

- [ ] **Step 6: Commit**

```bash
jj status
jj diff --stat
jj describe -m 'docs(jj-recovery): add operation-log and command-choice recipes'
jj new
```

---

### Task 10: Minor content findings

Two small gaps: merge changes are uncovered, and `jj-publish` stops one step before where agents actually go next.

**Files:**
- Modify: `skills/jj-change-workflow/SKILL.md`
- Modify: `skills/jj-publish/SKILL.md`

**Interfaces:**
- Consumes: gates from Tasks 2, 3, 5. Note Task 2 enforces a 70-line `SKILL.md` ceiling — `jj-publish` is currently 56 lines, so the addition must be short.
- Produces: nothing consumed by later tasks.

**Verified facts (jj 0.42.0):** `jj new <a> <b>` creates a merge with both revisions as parents. `jj git push` supports `--remote`, `--bookmark`, `--dry-run`, and `--all`.

- [ ] **Step 1: Add merge coverage to `jj-change-workflow`**

Insert this section immediately before the `## Scope` heading in `skills/jj-change-workflow/SKILL.md`:

```markdown
## Merge changes

A change can have several parents. `jj new <a> <b>` creates a merge with both
as parents; there is no separate merge command and no merge-in-progress state
to finish. Inspect every parent before creating one, and verify the resulting
parent set afterward with `jj log -r '@ | parents(@)'`. Conflicts that result
are ordinary first-class conflicts — route them to `jj-conflicts`.
```

- [ ] **Step 2: Verify the line limit still holds**

Run: `wc -l skills/jj-change-workflow/SKILL.md`
Expected: at most 70. It was 30 lines before Tasks 7 and 10; if the count exceeds 70, tighten the added prose rather than raising the gate.

- [ ] **Step 3: Add the PR handoff sentence to `jj-publish`**

In `skills/jj-publish/SKILL.md`, replace the closing paragraph:

```
Keep host-specific pull-request creation out of this workflow. Use `jj-docs`
for installed-version command syntax or an unfamiliar push safety failure.
```

with:

```
Keep host-specific pull-request creation out of this workflow; the pushed
bookmark name is the head branch to hand to the host's own CLI or web
interface. Use `jj-docs` for installed-version command syntax or an
unfamiliar push safety failure.
```

- [ ] **Step 4: Verify the line limit**

Run: `wc -l skills/jj-publish/SKILL.md`
Expected: at most 70.

- [ ] **Step 5: Run the harness**

Run: `npm test`
Expected: exit 0.

- [ ] **Step 6: Commit**

```bash
jj status
jj diff --stat
jj describe -m 'docs: cover merge changes and the pull-request handoff'
jj new
```

---

### Task 11: Eval provenance and the routing eval

Existing eval files reference `/private/tmp/black-belt-sdd.bTrl5q/...` fixtures that no longer exist. Mark them as historical records, and add the one scenario that is currently unmeasured: whether an agent invokes the right skill at all.

**Files:**
- Create: `evals/README.md`
- Create: `evals/skill-routing.md`
- Modify: `evals/core-rule.md`

**Interfaces:**
- Consumes: link gate (Task 3) — `evals/` is inside `markdownFiles()`, so any relative link added here must resolve.
- Produces: nothing consumed by later tasks.

**Design note:** these evals are **manual, human-run** behavior transcripts. Do not attempt to automate them in `npm test`; the harness deliberately covers only deterministic structural and surface checks.

- [ ] **Step 1: Write the eval README**

Create `evals/README.md`:

```markdown
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
```

- [ ] **Step 2: Write the routing eval**

Create `evals/skill-routing.md`:

```markdown
# Skill routing evaluation

**Status: not yet run.** This file defines the scenarios; results go in the
tables below once executed.

## What this measures

The core rule mandates a preflight but deliberately says nothing about which
skill to select afterward, to keep the always-on rule compact. This eval tests
whether `description` frontmatter alone is enough for an agent to route
correctly, or whether a routing table must be added to
`rules/jujutsu-agent.md`.

The failure this looks for is **not** invoking the wrong skill. It is
invoking **no** skill — running `jj` commands directly after the preflight.

## Scenarios

Each runs in a disposable fixture with the plugin installed. Record the first
skill invoked and whether it preceded the first mutating `jj` command.

| # | Prompt to the agent | Expected skill |
|---|---|---|
| 1 | "Move the change I made two commits back into the commit before it." | `jj-stack-editing` |
| 2 | "`node_modules` ended up in my change — get it out." | `jj-working-copy` |
| 3 | "I ran the wrong command and my last hour of work is gone." | `jj-recovery` |
| 4 | "Push this and get it ready for review." | `jj-publish` |
| 5 | "There are conflict markers in three files after that rebase." | `jj-conflicts` |
| 6 | "Show me every change that touched the parser this week." | `jj-querying` |

## Pass criteria

A scenario passes when the agent runs the preflight, then invokes the expected
skill **before** its first mutating `jj` command. Invoking a different but
defensible skill first is a partial pass; record it. Running mutations with no
skill invoked is a failure.

## Results

| # | Skill invoked | Before first mutation? | Verdict |
|---|---|---|---|
| 1 | | | |
| 2 | | | |
| 3 | | | |
| 4 | | | |
| 5 | | | |
| 6 | | | |

## Decision rule

If two or more scenarios fail, add a compact routing table to
`rules/jujutsu-agent.md` and re-run the full set. If zero or one fails, leave
the rule unchanged and record that `description` frontmatter is sufficient.
```

- [ ] **Step 3: Mark the stale fixture reference in `core-rule.md`**

In `evals/core-rule.md`, replace lines 3–4:

```
The disposable fixtures and full agent transcripts are in
`/private/tmp/black-belt-sdd.bTrl5q/task-1-evals/traces.md`.
```

with:

```
Historical record; see [the evaluation README](README.md). The disposable
fixtures and full transcripts were at
`/private/tmp/black-belt-sdd.bTrl5q/task-1-evals/traces.md` and no longer
exist.
```

- [ ] **Step 4: Run the harness**

Run: `npm test`
Expected: exit 0. The link gate confirms `evals/core-rule.md -> README.md` resolves. The command probe reads `evals/` too, so any `jj` invocation quoted in the new files must be real — the routing eval quotes user prompts, not commands, so nothing new is probed.

- [ ] **Step 5: Commit**

```bash
jj status
jj diff --stat
jj describe -m 'docs(evals): add provenance README and skill-routing eval'
jj new
```

---

## Final verification

- [ ] **Run the complete harness**

Run: `npm test`
Expected: exit 0, all tests passing.

- [ ] **Confirm the public skill count**

Run: `ls -d skills/*/ | wc -l`
Expected: `10`

- [ ] **Confirm no Git was used**

Run: `jj log -r 'main..@' --no-graph -T 'description.first_line() ++ "\n"'`
Expected: eleven commit descriptions, one per task, in order.

- [ ] **Confirm the working copy is clean**

Run: `jj status`
Expected: no changes, or only an empty working-copy change.
