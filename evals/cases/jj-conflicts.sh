PROMPT="Resolve the current config.txt conflict to exactly 'color=purple'. Keep both parent changes and describe the resolution as 'Resolve color'."

setup() {
  repo=$1
  jj git init --no-colocate "$repo" --quiet
  printf 'color=base\n' > "$repo/config.txt"
  jj -R "$repo" commit -m 'Base color' --quiet
  base=$(jj -R "$repo" log -r @- --no-graph -T change_id)

  printf 'color=red\n' > "$repo/config.txt"
  jj -R "$repo" commit -m 'Red color' --quiet
  red=$(jj -R "$repo" log -r @- --no-graph -T change_id)

  jj -R "$repo" new "$base" -m 'Green color' --quiet
  printf 'color=green\n' > "$repo/config.txt"
  green=$(jj -R "$repo" log -r @ --no-graph -T change_id)
  jj -R "$repo" new "$red" "$green" -m 'Unresolved color' --quiet
}

capture() {
  parents=$(jj -R "$1" log -r 'parents(@)' --no-graph -T 'commit_id ++ "\n"' | sort)
}

check() {
  repo=$1
  test "$parents" = "$(jj -R "$repo" log -r 'parents(@)' --no-graph -T 'commit_id ++ "\n"' | sort)" &&
  test "$(cat "$repo/config.txt")" = 'color=purple' &&
  test "$(jj -R "$repo" log -r 'conflicts() & @' --count)" = 0 &&
  test "$(jj -R "$repo" log -r @ --no-graph -T 'description.first_line()')" = 'Resolve color'
}
