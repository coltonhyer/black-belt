#!/bin/sh
set -eu

root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/black-belt-evals.XXXXXX")
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

mkdir -p "$tmp/bin" "$tmp/source-home/.codex" "$tmp/source-home/.claude" \
  "$tmp/source-home/.gemini/antigravity-cli"
printf '{}\n' > "$tmp/source-home/.codex/auth.json"
printf '{}\n' > "$tmp/source-home/.claude/.credentials.json"
printf 'token\n' > "$tmp/source-home/.gemini/antigravity-cli/antigravity-oauth-token"

cat > "$tmp/bin/agent" <<'SH'
#!/bin/sh
host=${0##*/}
printf '%s %s\n' "$host" "$*" >> "$FAKE_AGENT_LOG"
if [ "$1" = plugin ]; then
  printf '{}\n'
  exit
fi
if [ "$host" = agy ]; then
  # agy only honors flags when the prompt is $2, directly after -p; the
  # flags-first order silently drops --dangerously-skip-permissions.
  [ "$1" = -p ] || exit 2
  case $2 in ''|-*) exit 2 ;; esac
  add_dir=
  while [ "$#" -gt 0 ]; do
    if [ "$1" = --add-dir ]; then
      add_dir=$2
      break
    fi
    shift
  done
  [ -n "$add_dir" ] || exit 2
  cd "$add_dir" || exit
fi
/bin/bash -lc 'jj marker "$PWD" agent' || exit

last=
while [ "$#" -gt 0 ]; do
  if [ "$1" = "-o" ] || [ "$1" = "--output-last-message" ]; then
    last=$2
    shift 2
  else
    shift
  fi
done
[ -z "$last" ] || printf 'ok\n' > "$last"
touch agent-ran
printf '{"type":"turn.completed"}\n'
SH
chmod +x "$tmp/bin/agent"
ln -s agent "$tmp/bin/codex"
ln -s agent "$tmp/bin/claude"
ln -s agent "$tmp/bin/agy"

cat > "$tmp/eval-jj" <<'SH'
#!/bin/sh
test "$1" = marker
touch "$2/jj-$3"
SH
chmod +x "$tmp/eval-jj"

cat > "$tmp/case.sh" <<'SH'
PROMPT='Do the test work.'
[ "${EVAL_HOST:-}" != agy ] || FOLLOW_UP='Continue the test work.'

setup() {
  jj marker "$1" setup
  printf 'keep\n' > "$1/asset"
  mkdir "$1/../case-artifact"
}

capture() {
  before=$(cksum "$1/asset")
}

check() {
  test "$before" = "$(cksum "$1/asset")" &&
  test -e "$1/agent-ran" &&
  test -e "$1/jj-setup" &&
  test -e "$1/jj-agent"
}
SH

for host in codex claude agy; do
  export FAKE_AGENT_LOG="$tmp/$host.log"
  output=$(HOME="$tmp/source-home" CODEX_HOME="$tmp/source-home/.codex" \
    EVAL_HOST="$host" EVAL_JJ="$tmp/eval-jj" PATH="$tmp/bin:$PATH" \
    "$root/evals/run" "$tmp/case.sh")
  work=${output##* }

  case "$host" in
    codex)
      grep -F "codex plugin marketplace add $root --json" "$FAKE_AGENT_LOG" >/dev/null
      grep -F 'codex plugin add black-belt@black-belt --json' "$FAKE_AGENT_LOG" >/dev/null
      ;;
    claude)
      grep -F "claude plugin marketplace add $root --scope user" "$FAKE_AGENT_LOG" >/dev/null
      grep -F 'claude plugin install black-belt@black-belt --scope user' "$FAKE_AGENT_LOG" >/dev/null
      ;;
    agy)
      grep -F "agy plugin install $root" "$FAKE_AGENT_LOG" >/dev/null
      ;;
  esac
  test ! -e "$work/home"
  test -d "$work/repo"
  test -s "$work/commands.jsonl"
  test "$(find "$work" -mindepth 1 -maxdepth 1 -printf '%f\n' | sort | tr '\n' ' ')" = 'commands.jsonl repo '
done

export FAKE_AGENT_LOG="$tmp/bare.log"
output=$(HOME="$tmp/source-home" CODEX_HOME="$tmp/source-home/.codex" \
  EVAL_HOST=codex EVAL_PLUGIN=off EVAL_JJ="$tmp/eval-jj" PATH="$tmp/bin:$PATH" \
  "$root/evals/run" "$tmp/case.sh")
set -- $output
test "$1 $2 $3" = 'codex bare PASS'
if grep -F 'codex plugin ' "$FAKE_AGENT_LOG" >/dev/null; then
  echo 'bare eval installed the plugin' >&2
  exit 1
fi
