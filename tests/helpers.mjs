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
