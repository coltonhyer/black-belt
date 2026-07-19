#!/bin/sh
set -eu

root=$(CDPATH= cd "$(dirname "$0")" && pwd)
out=$(mktemp -d "${TMPDIR:-/tmp}/jj-surface.XXXXXX")
trap 'rm -rf "$out"' EXIT HUP INT TERM

"$root/capture-jj-surface.sh" "$(command -v jj)" "$out"
for file in version.txt markdown-help.md config-schema.json revsets.txt filesets.txt templates.txt config.txt; do
  test -s "$out/$file"
done
python3 -m json.tool "$out/config-schema.json" >/dev/null
