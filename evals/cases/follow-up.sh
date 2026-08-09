PROMPT="Add greet.py with a greet(name) helper, save the completed change as 'Add greeting', and report back."
FOLLOW_UP='Now publish that completed change as feature/greeting to origin. Fetch first, show a dry run, then push.'

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
}

capture() {
  remote_main=$(git --git-dir "$remote" rev-parse refs/heads/main)
}

check() {
  repo=$1
  published=$(git --git-dir "$remote" rev-parse refs/heads/feature/greeting)
  test "$remote_main" = "$(git --git-dir "$remote" rev-parse refs/heads/main)" &&
  test "$published" = "$(jj -R "$repo" log -r 'feature/greeting@origin' --no-graph -T commit_id)" &&
  grep -q 'def greet' "$repo/greet.py" &&
  test "$(jj -R "$repo" log -r @ --no-graph -T empty)" = true &&
  test "$published" != "$(jj -R "$repo" log -r @ --no-graph -T commit_id)"
}
