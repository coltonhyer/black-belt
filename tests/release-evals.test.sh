#!/bin/sh
set -eu

root=$(CDPATH= cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/black-belt-release.XXXXXX")
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

for version in 0.43.0 0.43.1 0.42.0 0.41.0; do
  file="$tmp/jj-$version"
  printf '#!/bin/sh\nprintf "jj %s\\n"\n' "$version" > "$file"
  chmod +x "$file"
done

cat > "$tmp/run" <<'SH'
#!/bin/sh
arm=plugin
[ "${EVAL_PLUGIN:-on}" = off ] && arm=bare
printf '%s %s %s\n' "$EVAL_HOST" "$arm" "$EVAL_JJ" >> "$RELEASE_LOG"
test "$arm" != bare
SH
chmod +x "$tmp/run"
printf '#!/bin/sh\nexit 0\n' > "$tmp/node"
chmod +x "$tmp/node"

export RELEASE_LOG="$tmp/release.log"
PATH="$tmp:$PATH" EVAL_RUN="$tmp/run" "$root/evals/release" \
  "$tmp/jj-0.43.0" "$tmp/jj-0.42.0" "$tmp/jj-0.41.0"

test "$(wc -l < "$RELEASE_LOG")" -eq 12
for host in codex claude agy; do
  for version in 0.43.0 0.42.0 0.41.0; do
    grep -Fx "$host plugin $tmp/jj-$version" "$RELEASE_LOG" >/dev/null
  done
  grep -Fx "$host bare $tmp/jj-0.43.0" "$RELEASE_LOG" >/dev/null
done

if PATH="$tmp:$PATH" EVAL_RUN="$tmp/run" "$root/evals/release" \
  "$tmp/jj-0.43.0" "$tmp/jj-0.43.1" "$tmp/jj-0.41.0" >/dev/null 2>&1; then
  echo 'release gate accepted duplicate Jujutsu minors' >&2
  exit 1
fi
