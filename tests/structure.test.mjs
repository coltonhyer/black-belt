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
