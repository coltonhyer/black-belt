PROMPT='Return only <full-change-id><TAB><description> for the nearest non-working-copy ancestor that modified src/payments.ts. Do not modify anything.'

setup() {
  repo=$1
  jj git init --no-colocate "$repo" --quiet
  mkdir -p "$repo/src"
  printf 'payments A\n' > "$repo/src/payments.ts"
  jj -R "$repo" commit -m 'A payments' --quiet
  printf 'docs\n' > "$repo/README.md"
  jj -R "$repo" commit -m 'B docs' --quiet
  printf 'payments C\n' > "$repo/src/payments.ts"
  jj -R "$repo" commit -m 'C payments' --quiet
}

capture() {
  repo=$1
  change=$(jj -R "$repo" log -r @- --no-graph -T change_id)
  expected=$(printf '%s\tC payments' "$change")
  graph=$(jj -R "$repo" log -r '::@' --no-graph -T 'change_id ++ " " ++ commit_id ++ "\n"')
  payments=$(cksum "$repo/src/payments.ts")
}

check() {
  repo=$1 last=$2
  test "$expected" = "$(cat "$last")" &&
  test "$graph" = "$(jj -R "$repo" log -r '::@' --no-graph -T 'change_id ++ " " ++ commit_id ++ "\n"')" &&
  test "$payments" = "$(cksum "$repo/src/payments.ts")"
}
