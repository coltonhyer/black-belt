setup() {
  repo=$1
  jj git init --no-colocate "$repo" --quiet
  printf 'base\n' > "$repo/base.txt"
  jj -R "$repo" commit -m 'Base' --quiet
  printf 'A\n' > "$repo/a.txt"
  jj -R "$repo" commit -m 'A' --quiet
  a_id=$(jj -R "$repo" log -r @- --no-graph -T change_id)
  printf 'B\n' > "$repo/b.txt"
  jj -R "$repo" commit -m 'B' --quiet
  b_id=$(jj -R "$repo" log -r @- --no-graph -T change_id)
  jj -R "$repo" abandon "$a_id" --quiet
  PROMPT="The immediately previous operation accidentally abandoned $a_id. Restore the repository to just before it without recreating files manually."
}

capture() {
  repo=$1
  b_content=$(cksum "$repo/b.txt")
  b_count=$(jj -R "$repo" log -r "all() & $b_id" --count)
}

check() {
  repo=$1
  test "$b_content" = "$(cksum "$repo/b.txt")" &&
  test "$b_count" = "$(jj -R "$repo" log -r "all() & $b_id" --count)" &&
  test "$(jj -R "$repo" log -r "all() & $a_id" --count)" = 1 &&
  test "$(cat "$repo/a.txt")" = A &&
  test "$(cat "$repo/b.txt")" = B &&
  test -z "$(jj -R "$repo" diff -r @ --summary)"
}
