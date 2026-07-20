#!/bin/sh
# Fail if the shared metadata fields drift across the host manifests.
# Host-specific fields (Antigravity has no version; each host adds its own
# interface block) are intentionally not compared.
set -eu

root=$(CDPATH= cd "$(dirname "$0")/../../../.." && pwd)

python3 - "$root" <<'PY'
import json, os, sys

root = sys.argv[1]
errors = []


def load(rel):
    with open(os.path.join(root, rel)) as fh:
        return json.load(fh)


manifests = {
    rel: load(rel)
    for rel in (
        "plugin.json",
        ".claude-plugin/plugin.json",
        ".codex-plugin/plugin.json",
        ".agents/plugins/marketplace.json",
        ".claude-plugin/marketplace.json",
    )
}


def agree(field_map, label):
    present = {k: v for k, v in field_map.items() if v is not None}
    if len(set(present.values())) > 1:
        detail = ", ".join(f"{k}={v!r}" for k, v in present.items())
        errors.append(f"{label} disagree: {detail}")


# Top-level plugin name must match everywhere it appears.
agree({rel: m.get("name") for rel, m in manifests.items()}, "top-level name")

# Nested plugin-entry names in the marketplaces.
for rel in (".agents/plugins/marketplace.json", ".claude-plugin/marketplace.json"):
    for entry in manifests[rel].get("plugins", []):
        if entry.get("name") != "black-belt":
            errors.append(f"{rel} plugin entry name {entry.get('name')!r} != 'black-belt'")

# Description across every manifest that carries a top-level one.
agree(
    {
        rel: manifests[rel].get("description")
        for rel in (
            "plugin.json",
            ".claude-plugin/plugin.json",
            ".codex-plugin/plugin.json",
            ".claude-plugin/marketplace.json",
        )
    },
    "description",
)

# Version between the two manifests that declare one.
agree(
    {
        rel: manifests[rel].get("version")
        for rel in (".claude-plugin/plugin.json", ".codex-plugin/plugin.json")
    },
    "version",
)

# Author / owner display name.
agree(
    {
        ".claude-plugin/plugin.json": manifests[".claude-plugin/plugin.json"]
        .get("author", {})
        .get("name"),
        ".codex-plugin/plugin.json": manifests[".codex-plugin/plugin.json"]
        .get("author", {})
        .get("name"),
        ".claude-plugin/marketplace.json": manifests[".claude-plugin/marketplace.json"]
        .get("owner", {})
        .get("name"),
    },
    "author/owner name",
)

# The hooks file referenced by the Claude manifest must exist.
hooks_rel = manifests[".claude-plugin/plugin.json"].get("hooks")
if hooks_rel:
    hooks_path = os.path.normpath(os.path.join(root, hooks_rel.lstrip("./")))
    if not os.path.isfile(hooks_path):
        errors.append(f".claude-plugin/plugin.json hooks path missing: {hooks_rel}")

if errors:
    for e in errors:
        sys.stderr.write("manifest drift: " + e + "\n")
    sys.exit(1)

print("manifest sync: shared fields agree across host manifests")
PY
