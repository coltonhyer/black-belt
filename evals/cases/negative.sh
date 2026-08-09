PROMPT='How many words are in note.txt? Reply with only the number. Do not modify any files.'

setup() {
  printf 'one two three four\n' > "$1/note.txt"
}

capture() {
  note=$(cksum "$1/note.txt")
}

check() {
  repo=$1 last=$2
  test "$note" = "$(cksum "$repo/note.txt")" &&
  test "$(cat "$last")" = 4 &&
  test "$(find "$repo" -mindepth 1 -maxdepth 1 -type f | wc -l)" = 1
}
