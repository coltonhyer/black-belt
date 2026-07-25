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

// Every consumer of the window must name exactly the supported set — no
// missing entries and no stale extras. Inclusion checks let a dropped version
// linger in prose long after it left the window.
const WINDOW_RE = /\b0\.\d+(?:\.\d+)?\b/g;

function declaredVersions(text) {
  return new Set([...text.matchAll(WINDOW_RE)].map((m) => m[0].split(".").slice(0, 2).join(".")));
}

// The README states the window twice — the intro sentence and Prerequisites —
// so compare every version-shaped token in the file. Any `0.x` string that is
// not a supported jj version will fail this deliberately; the README is short
// and the window is the only thing in it shaped that way.
test("README advertises exactly the supported window", () => {
  assert.deepEqual(
    [...declaredVersions(readRoot("README.md"))].sort(),
    [...SUPPORTED].sort(),
    "README.md version mentions do not match jj-support.json exactly",
  );
});

// Guards the drift vector created by the matrix pinning patch versions
// (`0.41.0`) while jj-support.json declares minors (`0.41`).
test("the CI matrix covers exactly the supported window", () => {
  const workflow = readRoot(".github/workflows/ci.yml");
  const matrix = /jj:\s*\[([^\]]*)\]/.exec(workflow);
  assert.ok(matrix, ".github/workflows/ci.yml must declare a `jj:` matrix list");

  assert.deepEqual(
    [...declaredVersions(matrix[1])].sort(),
    [...SUPPORTED].sort(),
    "CI matrix does not match jj-support.json exactly",
  );
});

// --- command extraction -------------------------------------------------

// Subcommands that take a second word. Anything not listed is single-word.
const NESTED = new Set([
  "git", "op", "operation", "file", "bookmark", "util", "workspace", "config", "sparse",
]);

// Illustrative placeholders that are not real flags.
const PLACEHOLDER = /^-{1,2}[<{]/;

// Prose naming a binary version rather than invoking a subcommand — e.g.
// "used `jj 0.42.0`, a fresh colocated repository" in
// evals/host-state-refresh.md and evals/maintaining-jj-catalog.md. Matched by
// shape, not by literal value, so this survives a support-window bump.
const VERSION_LIKE = /^\d+\.\d+(\.\d+)?$/;

// Prose phrasings that parse as invocations but are not commands. Prefer a
// shape-based rule above; add a literal here only when one cannot express it.
const IGNORED_SUBCOMMANDS = new Set([]);

function extractInvocations(text) {
  // Strip quoted spans so revset operators are not parsed as flags.
  const cleaned = text.replaceAll(/'[^']*'/g, " ARG ").replaceAll(/"[^"]*"/g, " ARG ");
  const found = [];

  // Note: `]` is excluded from the capture so a Markdown link whose title
  // text starts with a real invocation (e.g. "[Run formatters with jj
  // fix](recipes/run-formatters-with-fix.md)" in
  // skills/jj-docs/references/recipes.md) does not bleed into the link
  // target. Without this, the capture swallowed the URL and produced the
  // bogus subcommand `fix](recipes/run-formatters-with-fix.md)`.
  for (const match of cleaned.matchAll(/\bjj\s+([^\n`|;&\]]+)/g)) {
    const tokens = match[1].trim().split(/\s+/).filter(Boolean);
    if (tokens.length === 0) continue;
    if (tokens[0].startsWith("-")) continue; // `jj --version` etc.
    if (VERSION_LIKE.test(tokens[0])) continue; // `jj 0.42.0` in prose

    const sub = [tokens[0]];
    let rest = tokens.slice(1);
    if (NESTED.has(tokens[0]) && rest[0] && !rest[0].startsWith("-")) {
      sub.push(rest[0]);
      rest = rest.slice(1);
    }

    if (IGNORED_SUBCOMMANDS.has(sub.join(" "))) continue;

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
