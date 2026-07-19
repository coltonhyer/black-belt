#!/bin/sh
set -eu

if [ "$#" -ne 2 ]; then
  echo "usage: capture-jj-surface.sh JJ_BIN OUTPUT_DIR" >&2
  exit 2
fi

jj_bin=$1
out=$2
mkdir -p "$out"

"$jj_bin" version > "$out/version.txt"
"$jj_bin" util markdown-help > "$out/markdown-help.md"
"$jj_bin" util config-schema > "$out/config-schema.json"
for topic in revsets filesets templates config; do
  "$jj_bin" help -k "$topic" > "$out/$topic.txt"
done
