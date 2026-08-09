PROMPT='Initialize this existing Git repository as colocated Jujutsu. Preserve .git, its history, and main.'

setup() {
  repo=$1
  git -C "$repo" init -q
  git -C "$repo" config user.name 'Eval Agent'
  git -C "$repo" config user.email eval@example.com
  printf 'keep\n' > "$repo/sentinel.txt"
  git -C "$repo" add sentinel.txt
  git -C "$repo" commit -qm 'Initial Git history'
  git -C "$repo" branch -M main
}

capture() {
  git_head=$(git -C "$1" rev-parse HEAD)
  sentinel=$(cksum "$1/sentinel.txt")
}

check() {
  repo=$1
  test -d "$repo/.git" &&
  test -d "$repo/.jj" &&
  test "$git_head" = "$(git -C "$repo" rev-parse HEAD)" &&
  test "$git_head" = "$(jj -R "$repo" log -r main --no-graph -T commit_id)" &&
  test "$sentinel" = "$(cksum "$repo/sentinel.txt")" &&
  test -z "$(jj -R "$repo" diff --summary)"
}
