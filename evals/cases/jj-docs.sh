PROMPT='Check the installed Jujutsu help without running jj run or modifying the repository. Reply with exactly `jj run: supported` if it is implemented, otherwise `jj run: unsupported` if help marks it as a stub.'

setup() {
  repo=$1
  jj git init --no-colocate "$repo" --quiet
  printf 'keep\n' > "$repo/sentinel.txt"
  jj -R "$repo" commit -m 'Sentinel' --quiet
}

capture() {
  repo=$1
  graph=$(jj -R "$repo" log -r '::@' --no-graph -T 'change_id ++ " " ++ commit_id ++ "\n"')
  sentinel=$(cksum "$repo/sentinel.txt")
  case "$(jj version)" in
    *' 0.41.'*|*' 0.42.'*) answer='jj run: unsupported' ;;
    *) answer='jj run: supported' ;;
  esac
}

check() {
  repo=$1 last=$2
  test "$answer" = "$(cat "$last")" &&
  test "$graph" = "$(jj -R "$repo" log -r '::@' --no-graph -T 'change_id ++ " " ++ commit_id ++ "\n"')" &&
  test "$sentinel" = "$(cksum "$repo/sentinel.txt")"
}
