PROMPT="Add a small slugify helper to utils.py, then save the completed work as 'Add slugify' and report back."

setup() {
  repo=$1
  remote="$repo/../origin.git"
  git init --bare -q "$remote"
  jj git init --no-colocate "$repo" --quiet
  printf 'def main():\n    print("hello")\n' > "$repo/app.py"
  jj -R "$repo" commit -m 'Initial app scaffold' --quiet
  jj -R "$repo" bookmark create main -r @- --quiet
  jj -R "$repo" git remote add origin "$remote"
  jj -R "$repo" git push --remote origin --bookmark main --quiet
  printf 'def capitalize_words(text):\n    return " ".join(w.capitalize() for w in text.split())\n' > "$repo/utils.py"
  jj -R "$repo" describe -m 'Add utilities' --quiet
  jj -R "$repo" bookmark create feature -r @ --quiet
  jj -R "$repo" git push --remote origin --bookmark feature --quiet
}

capture() {
  published=$(jj -R "$1" log -r feature --no-graph -T commit_id)
  scratch=$(sed -n '/^def capitalize_words/,/^$/p' "$1/utils.py" | sed '/^$/d')
}

check() {
  repo=$1
  test "$published" = "$(jj -R "$repo" log -r feature --no-graph -T commit_id)" &&
  test "$scratch" = "$(sed -n '/^def capitalize_words/,/^$/p' "$repo/utils.py" | sed '/^$/d')" &&
  grep -q 'slugify' "$repo/utils.py" &&
  test "$(jj -R "$repo" log -r @ --no-graph -T empty)" = true &&
  test "$(jj -R "$repo" log -r @- --no-graph -T 'description.first_line()')" = 'Add slugify'
}
