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
