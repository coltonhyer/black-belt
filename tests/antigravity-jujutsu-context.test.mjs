import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";

const root = fileURLToPath(new URL("..", import.meta.url));
const output = execFileSync("node", ["hooks/antigravity-jujutsu-context.mjs"], {
  cwd: root,
  encoding: "utf8",
});

assert.deepEqual(JSON.parse(output), {
  injectSteps: [{ ephemeralMessage: readFileSync(new URL("../rules/jujutsu-agent.md", import.meta.url), "utf8") }],
});
