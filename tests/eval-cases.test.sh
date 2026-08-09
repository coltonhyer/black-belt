#!/bin/sh
set -u
export EVAL_RECORD=0

root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
export JJ_CONFIG=/dev/null JJ_USER='Eval Agent' JJ_EMAIL=eval@example.com

rejects_inaction() (
  case_file=$1
  fixture=$(mktemp -d "${TMPDIR:-/tmp}/black-belt-case.XXXXXX")
  trap 'rm -rf "$fixture"' EXIT HUP INT TERM
  repo="$fixture/repo"
  mkdir -p "$repo"
  # shellcheck source=/dev/null
  . "$case_file"
  setup "$repo"
  capture "$repo"
  : > "$fixture/last"
  : > "$fixture/commands"
  if check "$repo" "$fixture/last" "$fixture/commands" >/dev/null 2>&1; then
    echo "untouched fixture passed: $(basename "$case_file")" >&2
    exit 1
  fi
)

pids=
for case_file in "$root"/evals/cases/*.sh; do
  rejects_inaction "$case_file" &
  pids="$pids $!"
done

status=0
for pid in $pids; do
  wait "$pid" || status=1
done

accepts_preserved_scratch() (
  fixture=$(mktemp -d "${TMPDIR:-/tmp}/black-belt-scratch.XXXXXX")
  trap 'rm -rf "$fixture"' EXIT HUP INT TERM
  repo="$fixture/repo"
  mkdir -p "$repo"
  # shellcheck source=/dev/null
  . "$root/evals/cases/jj-change-workflow.sh"
  setup "$repo"
  capture "$repo"
  jj -R "$repo" new --quiet
  sed -i '1i import re\n' "$repo/utils.py"
  printf '\n\ndef slugify(text):\n    return text.lower().replace(" ", "-")\n' >> "$repo/utils.py"
  jj -R "$repo" commit -m 'Add slugify' --quiet
  : > "$fixture/last"
  : > "$fixture/commands"
  check "$repo" "$fixture/last" "$fixture/commands"
)

accepts_preserved_scratch || status=1

accepts_removed_stack_change() (
  fixture=$(mktemp -d "${TMPDIR:-/tmp}/black-belt-stack.XXXXXX")
  trap 'rm -rf "$fixture"' EXIT HUP INT TERM
  repo="$fixture/repo"
  mkdir -p "$repo"
  # shellcheck source=/dev/null
  . "$root/evals/cases/jj-stack-editing.sh"
  setup "$repo"
  capture "$repo"
  jj -R "$repo" squash --from "$b_id" --into "$b_id-" -m 'A+B' --quiet
  : > "$fixture/last"
  : > "$fixture/commands"
  check "$repo" "$fixture/last" "$fixture/commands"
)

accepts_removed_stack_change || status=1

workspace_has_scratch_asset() (
  fixture=$(mktemp -d "${TMPDIR:-/tmp}/black-belt-workspace.XXXXXX")
  trap 'rm -rf "$fixture"' EXIT HUP INT TERM
  repo="$fixture/repo"
  mkdir -p "$repo"
  # shellcheck source=/dev/null
  . "$root/evals/cases/jj-workspaces.sh"
  setup "$repo"
  test "$(cat "$repo/draft.txt")" = draft
)

workspace_has_scratch_asset || status=1
exit "$status"
