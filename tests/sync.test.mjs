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

// `plugin.json` (Antigravity) is deliberately excluded: its schema allows only
// `name` and `description`, so adding `version` there makes the manifest
// invalid. Assert its absence rather than its agreement.
test("the Antigravity manifest declares no version", () => {
  assert.equal(
    load("plugin.json").version,
    undefined,
    "plugin.json must not declare a version; the Antigravity schema forbids it",
  );
});

test("version agrees across every manifest that declares one", () => {
  const rels = [
    ".claude-plugin/plugin.json",
    ".codex-plugin/plugin.json",
    "package.json",
  ];
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
