import { readFileSync } from "node:fs";
import { join } from "node:path";

const root = process.env.PLUGIN_ROOT || process.env.CLAUDE_PLUGIN_ROOT;
if (!root) process.exit(0);

const event = process.argv[2] === "SubagentStart" ? "SubagentStart" : "SessionStart";
const additionalContext = readFileSync(join(root, "rules", "jujutsu-agent.md"), "utf8");

if (process.env.PLUGIN_DATA || event === "SubagentStart") {
  process.stdout.write(JSON.stringify({ hookSpecificOutput: { hookEventName: event, additionalContext } }));
} else {
  process.stdout.write(additionalContext);
}
