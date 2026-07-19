import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { fileURLToPath } from "node:url";

const script = fileURLToPath(new URL("../hooks/antigravity-jujutsu-context.mjs", import.meta.url));
const output = execFileSync("node", [script], {
  cwd: tmpdir(),
  encoding: "utf8",
});

assert.deepEqual(JSON.parse(output), {
  injectSteps: [{ ephemeralMessage: readFileSync(new URL("../rules/jujutsu-agent.md", import.meta.url), "utf8") }],
});
