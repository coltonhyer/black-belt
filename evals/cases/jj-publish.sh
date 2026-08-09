PROMPT='Publish completed @- as feature/one to origin. Fetch first, show a dry run, then push. Do not publish empty @.'

setup() {
  repo=$1
  remote="$repo/../origin.git"
  git init --bare -q "$remote"
  jj git init --no-colocate "$repo" --quiet
  printf 'base\n' > "$repo/base.txt"
  jj -R "$repo" commit -m 'Base' --quiet
  jj -R "$repo" bookmark create main -r @- --quiet
  jj -R "$repo" git remote add origin "$remote"
  jj -R "$repo" git push --remote origin --bookmark main --quiet
  printf 'feature\n' > "$repo/feature.txt"
  jj -R "$repo" commit -m 'Feature one' --quiet
}

capture() {
  repo=$1
  feature=$(jj -R "$repo" log -r @- --no-graph -T commit_id)
  empty=$(jj -R "$repo" log -r @ --no-graph -T change_id)
  remote_main=$(git --git-dir "$remote" rev-parse refs/heads/main)
}

check() {
  repo=$1
  test "$remote_main" = "$(git --git-dir "$remote" rev-parse refs/heads/main)" &&
  test "$feature" = "$(git --git-dir "$remote" rev-parse refs/heads/feature/one)" &&
  test "$feature" = "$(jj -R "$repo" log -r 'feature/one@origin' --no-graph -T commit_id)" &&
  test "$empty" = "$(jj -R "$repo" log -r @ --no-graph -T change_id)" &&
  test "$(jj -R "$repo" log -r @ --no-graph -T empty)" = true
}
