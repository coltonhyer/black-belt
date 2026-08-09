PROMPT="Squash change B into its parent A, name the result 'A+B', preserve C above it, and leave the empty working copy at the tip."

setup() {
  repo=$1
  jj git init --no-colocate "$repo" --quiet
  printf 'base\n' > "$repo/base.txt"
  jj -R "$repo" commit -m 'Base' --quiet
  printf 'A\n' > "$repo/a.txt"
  jj -R "$repo" commit -m 'A' --quiet
  printf 'B\n' > "$repo/b.txt"
  jj -R "$repo" commit -m 'B' --quiet
  b_id=$(jj -R "$repo" log -r @- --no-graph -T change_id)
  printf 'C\n' > "$repo/c.txt"
  jj -R "$repo" commit -m 'C' --quiet
  c_id=$(jj -R "$repo" log -r @- --no-graph -T change_id)
}

capture() {
  repo=$1
  c_content=$(cksum "$repo/c.txt")
  empty_id=$(jj -R "$repo" log -r @ --no-graph -T change_id)
}

check() {
  repo=$1
  test "$c_content" = "$(cksum "$repo/c.txt")" &&
  test "$(jj -R "$repo" log -r "all() & $c_id" --count)" = 1 &&
  ! jj -R "$repo" log -r 'all()' --no-graph -T 'change_id ++ "\n"' | grep -Fxq "$b_id" &&
  test "$(jj -R "$repo" log -r "$c_id-" --no-graph -T 'description.first_line()')" = 'A+B' &&
  test "$empty_id" = "$(jj -R "$repo" log -r @ --no-graph -T change_id)" &&
  test "$(jj -R "$repo" log -r @ --no-graph -T empty)" = true
}
