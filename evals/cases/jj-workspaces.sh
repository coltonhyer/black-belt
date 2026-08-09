PROMPT='Create a sibling ../review Jujutsu workspace named review on the same parent, with a distinct empty working-copy change. Preserve the primary workspace.'

setup() {
  repo=$1
  jj git init --no-colocate "$repo" --quiet
  printf 'base\n' > "$repo/base.txt"
  jj -R "$repo" commit -m 'Base' --quiet
  printf 'draft\n' > "$repo/draft.txt"
}

capture() {
  repo=$1
  primary=$(jj -R "$repo" log -r @ --no-graph -T change_id)
  parent=$(jj -R "$repo" log -r @- --no-graph -T commit_id)
  base=$(cksum "$repo/base.txt")
  draft=$(cksum "$repo/draft.txt")
}

check() {
  repo=$1 review="$1/../review"
  test "$primary" = "$(jj -R "$repo" log -r @ --no-graph -T change_id)" &&
  test "$base" = "$(cksum "$repo/base.txt")" &&
  test "$draft" = "$(cksum "$repo/draft.txt")" &&
  test "$primary" != "$(jj -R "$review" log -r @ --no-graph -T change_id)" &&
  test "$parent" = "$(jj -R "$review" log -r @- --no-graph -T commit_id)" &&
  test "$(jj -R "$review" log -r @ --no-graph -T empty)" = true &&
  jj -R "$repo" workspace list | grep -q '^review:'
}
