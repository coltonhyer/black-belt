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
