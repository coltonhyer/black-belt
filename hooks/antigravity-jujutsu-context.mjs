import { readFileSync } from "node:fs";

const rule = readFileSync(new URL("../rules/jujutsu-agent.md", import.meta.url), "utf8");
process.stdout.write(JSON.stringify({ injectSteps: [{ ephemeralMessage: rule }] }));
