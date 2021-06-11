#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2063

load test_helper

# aliases ####################################################################

@test "'<notebook>:+' creates new note with editor." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
  }

  run "${_NB}" Example\ Notebook:+  \
    --title     "Example Title"     \
    --filename  "File One.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0                              ]]

  # Prints output:

  [[ "${output}" =~  \
Added:\ .*\[.*Example\ Notebook:1.*\].*\ .*Example\ Notebook:File\ One\.md.*\ \"Example\ Title\"  ]]

  # Creates a new file:

  [[ !  -f "${NB_DIR}/home/File One.md"             ]]
  [[    -f "${NB_DIR}/Example Notebook/File One.md" ]]


  diff                                              \
    <(cat "${NB_DIR}/Example Notebook/File One.md") \
    <(cat <<HEREDOC
# Example Title

# mock_editor ${NB_DIR}/Example Notebook/File One
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/Example Notebook" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)"           ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

@test "'<notebook>:+ --content <content>' creates new note without opening editor." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
  }

  run "${_NB}" Example\ Notebook:+  \
    --title     "Example Title"     \
    --filename  "File One.md"       \
    --content   "Content one."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0                              ]]

  # Prints output:

  [[ "${output}" =~  \
Added:\ .*\[.*Example\ Notebook:1.*\].*\ .*Example\ Notebook:File\ One\.md.*\ \"Example\ Title\"  ]]

  # Creates a new file:

  [[ !  -f "${NB_DIR}/home/File One.md"             ]]
  [[    -f "${NB_DIR}/Example Notebook/File One.md" ]]


  diff                                              \
    <(cat "${NB_DIR}/Example Notebook/File One.md") \
    <(cat <<HEREDOC
# Example Title

Content one.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/Example Notebook" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

@test "'+' creates new note." {
  {
    run "${_NB}" init
  }

  run "${_NB}" +                \
    --title     "Example Title" \
    --filename  "File One.md"   \
    --content   "Content one."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0                    ]]

  # Prints output:

  [[ "${output}" =~  \
Added:\ .*\[.*1.*\].*\ .*File\ One\.md.*\ \"Example\ Title\"  ]]

  # Creates a new file:

  [[ -f "${NB_DIR}/home/File One.md"      ]]


  diff                                    \
    <(cat "${NB_DIR}/home/File One.md")   \
    <(cat <<HEREDOC
# Example Title

Content one.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

@test "'a' with no arguments creates new note file created with \$EDITOR." {
  {
    run "${_NB}" init
  }

  run "${_NB}" a

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}"      -eq 0                     ]]

  # Prints output:

  [[ "${output}"      =~ Added:\ .*\[.*1.*\].*  ]]

  # Creates a new note file with $EDITOR:

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}"  -eq 1                     ]]

  grep -q '# mock_editor' "${NB_DIR}/home"/*

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)"       ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}


@test "'create' with no arguments creates new note file created with \$EDITOR." {
  {
    run "${_NB}" init
  }

  run "${_NB}" add

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}"      -eq 0                     ]]

  # Prints output:

  [[ "${output}"      =~ Added:\ .*\[.*1.*\].*  ]]

  # Creates a new note file with $EDITOR:

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}"  -eq 1                     ]]

  grep -q '# mock_editor' "${NB_DIR}/home"/*

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)"       ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}


@test "'new' with no arguments creates new note file created with \$EDITOR." {
  {
    run "${_NB}" init
  }

  run "${_NB}" new

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}"      -eq 0                     ]]

  # Prints output:

  [[ "${output}"      =~ Added:\ .*\[.*1.*\].*  ]]

  # Creates a new note file with $EDITOR:

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}"  -eq 1                     ]]

  grep -q '# mock_editor' "${NB_DIR}/home"/*

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)"       ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

# --browse ####################################################################

@test "'add --browse <item-selector>' creates new file with populated content and selector filename field." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type "folder"

    sleep 1
  }

  run "${_NB}" add --browse Example\ Folder/Example\ File.md --print  \
    --title     "Example Title"                                       \
    --content   "Example content."                                    \
    --tags      tag1,tag2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                                    ]]

  [[    "${output}"  =~  ❯.*nb.*\ .*·.*\ .*home.*\ .*:.*\ .*1 ]]

  printf "%s\\n" "${output}" | grep -q \
"<nav class=\"header-crumbs\"><h1><a rel=\"noopener noreferrer\" href=\"http://lo"

  printf "%s\\n" "${output}" | grep -q \
"calhost:6789/?--per-page=.*&--columns=.*\"><span class=\"dim\">❯</span>nb</a>"

  printf "%s\\n" "${output}" | grep -q \
" <span class=\"dim\">·</span> <a rel=\"noopener noreferrer\" href=\"http://lo"

  printf "%s\\n" "${output}" | grep -q \
"calhost:6789/home:?--per-page=.*&--columns=.*\">home</a>"

  printf "%s\\n" "${output}" | grep -q "cols=\".*\">"

  printf "%s\\n" "${output}" | grep -q \
"action=\"/home:Example%20Folder/Example%20File.md?--add&--per-page=.*&--columns=.*\""

  printf "%s\\n" "${output}" | grep -q \
"value=\"add\">"

  printf "%s\\n" "${output}" | grep -q \
"cols=\".*\"># Example Title${_NEWLINE}${_NEWLINE}#tag1 #tag2${_NEWLINE}${_NEWLINE}Example content.${_NEWLINE}</textarea>"

  printf "%s\\n" "${output}" | grep -q -v \
"<input type=\"hidden\" name=\"--title\""
}

# --title option ##############################################################

@test "'add --title' with .org file creates file with .org title." {
  {
    "${_NB}" init
  }

  run "${_NB}" add --title "Example Title" --filename "Example File.org"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0      ]]

  [[ -f "${NB_DIR}/home/Example File.org" ]]

  diff                                        \
    <(cat "${NB_DIR}/home/Example File.org")  \
    <(printf "\
#+TITLE: Example Title

# mock_editor %s/home/Example File\\n" "${NB_DIR}")

  cd "${NB_DIR}/home"

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

@test "'add' with --title option exits with 0, creates new note with \$EDITOR, creates commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" add \
    --title "Example Title: A*string•with/a\\bunch|of?invalid<filename\"characters>"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0      ]]

  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}" -eq 1  ]]

  cd "${NB_DIR}/home" || return 1

  [[ -n "$(
    ls example_title__a_string•with_a_bunch_of_invalid_filename_characters_.md
  )" ]]

  cat "${NB_DIR}/home/${_files[0]}"

  diff                                    \
    <(cat "${NB_DIR}/home/${_files[0]}")  \
    <(printf "\
# Example Title: A*string•with/a\\\\bunch|of?invalid<filename\"characters>

# mock_editor %s/home/%s\\n" "${NB_DIR}" "${_files[0]%.md}")

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

@test "'add' with empty --title option exits with 1" {
  {
    "${_NB}" init
  }

  run "${_NB}" add --title

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 1      ]]

  cd "${NB_DIR}/home" || return 1

  ls "${NB_DIR}/home/"

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 0  ]]
}

@test "'add --title <title> --content <content>' with colons successfully creates note without \$EDITOR." {
  {
    "${_NB}" init
  }

  run "${_NB}" add                                                                    \
    --title "Example Title: A*string•with/a\\bunch|of?invalid<filename\"characters>"  \
    --content "Example: content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0      ]]

  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}" -eq 1  ]]

  cd "${NB_DIR}/home" || return 1

  [[ -n "$(
    ls example_title__a_string•with_a_bunch_of_invalid_filename_characters_.md
  )" ]]

  cat "${NB_DIR}/home/${_files[0]}"

  diff                                    \
    <(cat "${NB_DIR}/home/${_files[0]}")  \
    <(printf "\
# Example Title: A*string•with/a\\\\bunch|of?invalid<filename\"characters>

Example: content.\\n")

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

# content #####################################################################

@test "'add' with piped content includes content from --title and multiple --tags, --content, and arguments separated by newlines." {
  skip "TODO"
  {
    "${_NB}" init
  }

  echo "Piped content." | {
    run "${_NB}" add                  \
      "Argument content one."         \
      --tags    tag1,tag2             \
      --title   "Example Title"       \
      --content "Option content one." \
      --tags    tag3,tag4             \
      --content "Option content two." \
      "Argument content two."

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    # Returns status 0:

    [[ "${status}" -eq 0      ]]

    # Creates new note file:

    [[ -f "${NB_DIR}/home/example_title.markdown"     ]]

    diff                                              \
      <(cat "${NB_DIR}/home/example_title.markdown")  \
      <(cat <<HEREDOC
# Example Title

#tag1 #tag2 #tag3 #tag4

Argument content one. Argument content two.

Option content one.

Option content two.

Piped content.
HEREDOC
)

    # Creates git commit:

    cd "${NB_DIR}/home" || return 1
    while [[ -n "$(git status --porcelain)" ]]
    do
      sleep 1
    done
    git log --stat
    git log | grep -q '\[nb\] Add: example_title.markdown'

    # Adds to index:

    [[ -e "${NB_DIR}/home/.index" ]]

    diff                          \
      <(ls "${NB_DIR}/home")      \
      <(cat "${NB_DIR}/home/.index")

    # Prints output:

    [[ "${lines[0]}" =~ Added:\ .*[.*1.*].*\ .*example_title.markdown.*\ \"Example\ Title\" ]]
  }
}

@test "'add' with piped content includes content from --title and multiple --tags, --content, and arguments separated by newlines and a specified file extension." {
  skip "TODO"

  {
    "${_NB}" init
  }

  echo "Piped content." | {
    run "${_NB}" add                  \
      "Argument content one."         \
      --tags    tag1,tag2             \
      --title   "Example Title"       \
      --content "Option content one." \
      --tags    tag3,tag4             \
      --content "Option content two." \
      "Argument content two."         \
      --filename ".markdown"

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    # Returns status 0:

    [[ "${status}" -eq 0      ]]

    # Creates new note file:

    [[ -f "${NB_DIR}/home/example_title.markdown" ]]

    diff                                              \
      <(cat "${NB_DIR}/home/example_title.markdown")  \
      <(cat <<HEREDOC
# Example Title

#tag1 #tag2 #tag3 #tag4

Argument content one. Argument content two.

Option content one.

Option content two.

Piped content.
HEREDOC
)

    # Creates git commit:

    cd "${NB_DIR}/home" || return 1
    while [[ -n "$(git status --porcelain)" ]]
    do
      sleep 1
    done
    git log --stat
    git log | grep -q '\[nb\] Add: example_title.markdown'

    # Adds to index:

    [[ -e "${NB_DIR}/home/.index" ]]

    diff                      \
      <(ls "${NB_DIR}/home")  \
      <(cat "${NB_DIR}/home/.index")

    # Prints output:

    [[ "${lines[0]}" =~ Added:\ .*[.*1.*].*\ .*example_title.markdown.*\ \"Example\ Title\" ]]
  }
}

# no argument #################################################################

@test "'add' with no arguments creates new note file created with \$EDITOR." {
  {
    "${_NB}" init
  }

  run "${_NB}" add

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0      ]]

  # Creates a new note file with $EDITOR:

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  grep -q '# mock_editor' "${NB_DIR}/home"/*

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

# --tags option ###############################################################

@test "'add --tags' with no argument exits with 1 and prints message." {
  {
    "${_NB}" init
  }

  run "${_NB}" add --tags --filename "example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 1:

  [[ "${status}" -eq 1 ]]

  # Does not create new note file with content:

  [[ ! -f "${NB_DIR}/home/example.md" ]]

  # Prints output:

  [[ "${lines[0]}" =~ !.*\ .*--tags.*\ requires\ a\ valid\ argument. ]]
}

@test "'add --tags <tag-list>' creates new note with tags." {
  {
    "${_NB}" init
  }

  run "${_NB}" add            \
    --tags    tag1,tag2       \
    --title   "Example Title" \
    --content "Example content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0 ]]

  # Creates new note file with content:

  [[ -f "${NB_DIR}/home/example_title.md"     ]]

  diff                                        \
    <(cat "${NB_DIR}/home/example_title.md")  \
    <(cat <<HEREDOC
# Example Title

#tag1 #tag2

Example content.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${lines[0]}" =~ Added:\ .*[.*1.*].*\ .*example_title.md ]]
}

@test "'add --tags <tag-list>' with tags formatted as hashtags creates new note with tags." {
  {
    "${_NB}" init
  }

  run "${_NB}" add              \
    --tags    '#tag1','#tag2'   \
    --title   "Example Title"   \
    --content "Example content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0 ]]

  # Creates new note file with content:

  [[ -f "${NB_DIR}/home/example_title.md" ]]

  diff                                        \
    <(cat "${NB_DIR}/home/example_title.md")  \
    <(cat <<HEREDOC
# Example Title

#tag1 #tag2

Example content.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${lines[0]}" =~ Added:\ .*[.*1.*].*\ .*example_title.md ]]
}

# piped #######################################################################

@test "'add' with piped content includes content from --title, --tags, --content, and arguments separated by newlines." {
  {
    "${_NB}" init
  }

  echo "Piped content." | {
    run "${_NB}" add              \
      "Argument content one."     \
      --tags    tag1,tag2         \
      --title   "Example Title"   \
      --content "Option content." \
      "Argument content two."

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    # Returns status 0:

    [[ "${status}" -eq 0          ]]

    # Creates new note file:

    [[ -f "${NB_DIR}/home/example_title.md" ]]

    diff                                        \
      <(cat "${NB_DIR}/home/example_title.md")  \
      <(cat <<HEREDOC
# Example Title

#tag1 #tag2

Argument content one. Argument content two.

Option content.

Piped content.
HEREDOC
)

    # Creates git commit:

    cd "${NB_DIR}/home" || return 1
    while [[ -n "$(git status --porcelain)" ]]
    do
      sleep 1
    done
    git log --stat
    git log | grep -q '\[nb\] Add: example_title.md'

    # Adds to index:

    [[ -e "${NB_DIR}/home/.index" ]]

    diff                      \
      <(ls "${NB_DIR}/home")  \
      <(cat "${NB_DIR}/home/.index")

    # Prints output:

    [[ "${lines[0]}" =~ Added:\ .*[.*1.*].*\ .*example_title.md.*\ \"Example\ Title\" ]]
  }
}

@test "'add' with piped content includes content from --title, and standard input separated by newlines." {
  {
    "${_NB}" init
  }

  run bash -c "echo 'Piped content.' | \"${_NB}\" add --title Example\ Title"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0      ]]

  # Creates new note file:

  [[ -f "${NB_DIR}/home/example_title.md" ]]

  diff                                        \
    <(cat "${NB_DIR}/home/example_title.md")  \
    <(cat <<HEREDOC
# Example Title

Piped content.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log --stat
  git log | grep -q '\[nb\] Add: example_title.md'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${lines[0]}" =~ Added:\ .*[.*1.*].*\ .*example_title.md.*\ \"Example\ Title\" ]]
}

@test "'add' with piped content includes content from --content, and standard input separated by newlines." {
  {
    "${_NB}" init
  }

  run bash -c "echo 'Piped content.' | \"${_NB}\" add --content \"Example content.\""

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0      ]]

  # Creates new note file:

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  [[ -f "${NB_DIR}/home/${_files[0]:-}" ]]

  diff                                      \
    <(cat "${NB_DIR}/home/${_files[0]:-}")  \
    <(cat <<HEREDOC
Example content.

Piped content.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log --stat
  git log | grep -q "\[nb\] Add: ${_files[0]:-}"

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${lines[0]}" =~ Added:\ .*[.*1.*].*\ .*${_files[0]:-} ]]
}

@test "'add' with piped content creates new note without errors." {
  {
    "${_NB}" init
  }

  run bash -c "echo '# Piped content.' | \"${_NB}\" add --filename example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0      ]]

  # Creates new note file:

  [[ -f "${NB_DIR}/home/example.md" ]]

  diff                                  \
    <(cat "${NB_DIR}/home/example.md")  \
    <(cat <<HEREDOC
# Piped content.
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add: example.md'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${lines[0]}" =~ Added:\ .*[.*1.*].*\ .*example.md.*\ \"Piped\ content.\" ]]
}

@test "'add --type org' with piped content creates a new .org note file." {
  {
    "${_NB}" init
  }

  run bash -c "echo '# Piped' | \"${_NB}\" add --type org"

  [[ "${status}" -eq 0      ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  grep -q '# Piped' "${NB_DIR}/home"/*

  [[ "${_files[0]}" =~ org$ ]]
}

@test "'add --type ''' with piped content exits with 1." {
  {
    "${_NB}" init
  }

  run bash -c "echo '# Piped' | \"${_NB}\" add --type"

  [[ ${status} -eq 1        ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 0  ]]
}

# notebook: scoped ############################################################

@test "'add notebook:' creates new note without errors." {
  {
    "${_NB}" init
    "${_NB}" notebooks add example
  }

  run "${_NB}" add example:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0      ]]

  # Creates new note file with $EDITOR:

  _files=($(ls "${NB_DIR}/example"))

  [[ "${#_files[@]}" -eq 1  ]]

  [[ "$(cat "${NB_DIR}/example/${_files[0]}")" =~ mock_editor ]]

  # Creates git commit:

  cd "${NB_DIR}/example" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/example/.index"          ]]

  diff                        \
    <(ls "${NB_DIR}/example") \
    <(cat "${NB_DIR}/example/.index")

  # Prints output:

  [[ "${output}" =~ Added:                  ]]
  [[ "${output}" =~ example:[A-Za-z0-9]+    ]]
  [[ "${output}" =~ example:[A-Za-z0-9]+.md ]]
}

@test "'notebook:add' creates new note without errors." {
  {
    "${_NB}" init
    "${_NB}" notebooks add example
  }

  run "${_NB}" example:add

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0        ]]

  # Creates new note file with $EDITOR:

  _files=($(ls "${NB_DIR}/example"))

  [[ "${#_files[@]}" -eq 1  ]]

  [[ "$(cat "${NB_DIR}/example/${_files[0]}")" =~ mock_editor ]]

  # Creates git commit:

  cd "${NB_DIR}/example" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/example/.index"          ]]

  diff                        \
    <(ls "${NB_DIR}/example") \
    <(cat "${NB_DIR}/example/.index")

  # Prints output:

  [[ "${output}" =~ Added:                  ]]
  [[ "${output}" =~ example:[A-Za-z0-9]+    ]]
  [[ "${output}" =~ example:[A-Za-z0-9]+.md ]]
}

@test "'add notebook: <filename>' (space) creates new note with <filename>." {
  {
    "${_NB}" init
    "${_NB}" notebooks add example
  }

  run "${_NB}" add example: "Example Filename.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0      ]]

  # Creates new note file with $EDITOR:

  cat "${NB_DIR}/example/Example Filename.md"

  [[ -f "${NB_DIR}/example/Example Filename.md"                         ]]
  [[    "$(cat "${NB_DIR}/example/Example Filename.md")" =~ mock_editor ]]

  # Creates git commit:

  cd "${NB_DIR}/example" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add: Example Filename.md'

  # Adds to index:

  [[ -e "${NB_DIR}/example/.index"          ]]

  diff                        \
    <(ls "${NB_DIR}/example") \
    <(cat "${NB_DIR}/example/.index")

  # Prints output:

  [[ "${output}" =~ Added:                        ]]
  [[ "${output}" =~ example:[A-Za-z0-9]+          ]]
  [[ "${output}" =~ example:Example\ Filename.md  ]]
}

@test "'add notebook:<filename>' (no space) creates new note with <filename>." {
  {
    "${_NB}" init
    "${_NB}" notebooks add example
  }

  run "${_NB}" add example:Example\ Filename.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0      ]]

  # Creates new note file with $EDITOR:

  [[ -f "${NB_DIR}/example/Example Filename.md"                         ]]
  [[    "$(cat "${NB_DIR}/example/Example Filename.md")" =~ mock_editor ]]

  # Creates git commit:

  cd "${NB_DIR}/example" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add: Example Filename.md'

  # Adds to index:

  [[ -e "${NB_DIR}/example/.index"          ]]

  diff                        \
    <(ls "${NB_DIR}/example") \
    <(cat "${NB_DIR}/example/.index")

  # Prints output:

  [[ "${output}" =~ Added:                        ]]
  [[ "${output}" =~ example:[A-Za-z0-9]+          ]]
  [[ "${output}" =~ example:Example\ Filename.md  ]]
}

@test "'add notebook:<string>' (no space) creates new note with <string> as filename." {
  {
    "${_NB}" init
    "${_NB}" notebooks add example
  }

  run "${_NB}" add example:Example\ String

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0      ]]

  # Creates new note file with $EDITOR:

  [[ -f "${NB_DIR}/example/Example String"                          ]]
  [[    "$(cat "${NB_DIR}/example/Example String")" =~ mock_editor  ]]

  # Creates git commit:

  cd "${NB_DIR}/example" || return 1
  while [[ -n "$(git status --porcelain)"     ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/example/.index"            ]]

  diff                        \
    <(ls "${NB_DIR}/example") \
    <(cat "${NB_DIR}/example/.index")

  # Prints output:

  [[ "${output}" =~ Added:                  ]]
  [[ "${output}" =~ example:[A-Za-z0-9]+    ]]
  [[ "${output}" =~ example:Example\ String ]]
}


@test "'add notebook: <string>' (space) creates new note with <string> as content." {
  {
    "${_NB}" init
    "${_NB}" notebooks add example
  }

  run "${_NB}" add example: Example\ String

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0      ]]

  # Creates new note file with $EDITOR:

  _files=($(ls "${NB_DIR}/example"))

  [[ "${#_files[@]}" -eq 1  ]]

  [[ "$(cat "${NB_DIR}/example/${_files[0]}")" =~ Example\ String ]]

  # Creates git commit:

  cd "${NB_DIR}/example" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/example/.index"          ]]

  diff                        \
    <(ls "${NB_DIR}/example") \
    <(cat "${NB_DIR}/example/.index")

  # Prints output:

  [[ "${output}" =~ Added:                  ]]
  [[ "${output}" =~ example:[A-Za-z0-9]+    ]]
  [[ "${output}" =~ example:[A-Za-z0-9]+.md ]]
}

# <filename> argument #########################################################

@test "'add' with filename argument creates new note without errors." {
  {
    "${_NB}" init
  }

  run "${_NB}" add "example-filename.md" --content "# Example Title"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0 ]]

  # Creates new note file with content:

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" == 1                     ]]
  [[ "${_files[0]}" == "example-filename.md"  ]]

  grep -q '# Example Title' "${NB_DIR}/home"/*

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${output}" =~ Added:              ]]
  [[ "${output}" =~ example-filename.md ]]
}

@test "'add' with .org filename argument creates new note without errors." {
  {
    "${_NB}" init
  }

  run "${_NB}" add "example-filename.org" --content "Example content."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0 ]]

  # Creates new note file with content:

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}"  == 1                      ]]
  [[ "${_files[0]}"   == "example-filename.org" ]]

  grep -q 'Example content.' "${NB_DIR}/home"/*

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${output}" =~ Added:                ]]
  [[ "${output}" =~ example-filename.org  ]]
}

# <content> argument ##########################################################

@test "'add' with content argument creates new note without errors." {
  {
    "${_NB}" init
  }

  run "${_NB}" add "# Content"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0      ]]

  # Creates new note file with content:

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  grep -q '# Content' "${NB_DIR}/home"/*

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${output}" =~ Added:          ]]
  [[ "${output}" =~ [A-Za-z0-9]+    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

@test "'add' with scope and content argument creates new note without errors." {
  {
    "${_NB}" init
    "${_NB}" notebooks add Example
  }

  run "${_NB}" Example:add "# Content"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0      ]]

  # Creates new note file with content:

  _files=($(ls "${NB_DIR}/Example/"))

  [[ "${#_files[@]}" -eq 1  ]]

  grep -q '# Content' "${NB_DIR}/Example"/*

  # Creates git commit:

  cd "${NB_DIR}/Example" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/Example/.index" ]]

  diff                        \
    <(ls "${NB_DIR}/Example") \
    <(cat "${NB_DIR}/Example/.index")

  # Prints output:

  [[ "${output}" =~ Added:                  ]]
  [[ "${output}" =~ Example:[A-Za-z0-9]+    ]]
  [[ "${output}" =~ Example:[A-Za-z0-9]+.md ]]
}

@test "'add' with URL content argument creates new note without errors." {
  {
    "${_NB}" init
  }

  run "${_NB}" add "${_BOOKMARK_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0      ]]

  # Creates new note file with content:

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  cat "${NB_DIR}/home/${_files[0]}"

  [[ "$(cat "${NB_DIR}/home/${_files[0]}")" == "${_BOOKMARK_URL}" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${output}" =~ Added:          ]]
  [[ "${output}" =~ [A-Za-z0-9]+    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

@test "'add' with scope and URL content argument creates new note without errors." {
  {
    "${_NB}" init
    "${_NB}" notebooks add Example
  }

  run "${_NB}" Example:add "${_BOOKMARK_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0      ]]

  # Creates new note file with content:

  _files=($(ls "${NB_DIR}/Example/"))

  [[ "${#_files[@]}" -eq 1  ]]

  [[ "$(cat "${NB_DIR}/Example/${_files[0]}")" == "${_BOOKMARK_URL}" ]]

  # Creates git commit:

  cd "${NB_DIR}/Example" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/Example/.index" ]]

  diff                        \
    <(ls "${NB_DIR}/Example") \
    <(cat "${NB_DIR}/Example/.index")

  # Prints output:

  [[ "${output}" =~ Added:                  ]]
  [[ "${output}" =~ Example:[A-Za-z0-9]+    ]]
  [[ "${output}" =~ Example:[A-Za-z0-9]+.md ]]
}

@test "'add' with email address content argument creates new note without errors." {
  {
    "${_NB}" init
  }

  run "${_NB}" add "example@example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0      ]]

  # Creates new note file with content:

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  cat "${NB_DIR}/home/${_files[0]}"

  [[ "$(cat "${NB_DIR}/home/${_files[0]}")" == "example@example.com" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${output}" =~ Added:          ]]
  [[ "${output}" =~ [A-Za-z0-9]+    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

@test "'add' with 'http:' non-URL content argument creates new note without errors." {
  {
    "${_NB}" init
  }

  run "${_NB}" add "http: this is not a URL"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0      ]]

  # Creates new note file with content:

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  cat "${NB_DIR}/home/${_files[0]}"

  [[ "$(cat "${NB_DIR}/home/${_files[0]}")" == "http: this is not a URL" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${output}" =~ Added:          ]]
  [[ "${output}" =~ [A-Za-z0-9]+    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

@test "'add' with 'example.com' common TLD domain content argument creates new note without errors." {
  {
    "${_NB}" init
  }

  run "${_NB}" add "example.com"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0      ]]

  # Creates new note file with content:

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  cat "${NB_DIR}/home/${_files[0]}"

  [[ "$(cat "${NB_DIR}/home/${_files[0]}")" == "example.com" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${output}" =~ Added:          ]]
  [[ "${output}" =~ [A-Za-z0-9]+    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.md ]]
}

# --content option ############################################################

@test "'add' with --content option exits with 0, creates new note, creates commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" add --content "# Content"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0      ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  grep -q '# Content' "${NB_DIR}/home"/*

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

@test "'add' with URL --content option exits with 0, creates new note, creates commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" add --content "${_BOOKMARK_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0      ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  cat "${NB_DIR}/home/${_files[0]}"

  grep -q 'file' "${NB_DIR}/home"/*
  grep -q 'fixtures' "${NB_DIR}/home"/*

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

@test "'add' with empty --content option exits with 1" {
  {
    "${_NB}" init
  }

  run "${_NB}" add --content

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 1      ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 0  ]]
}

# --filename option ###########################################################

@test "'add' with --filename option exits with 0, creates new note, creates commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" add --filename example.org

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0      ]]

  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}" -eq 1  ]]

  cd "${NB_DIR}/home" || return 1

  [[ -n "$(ls example.org)" ]]

  grep -q '# mock_editor' "${NB_DIR}/home"/*

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

@test "'add' with --filename option overrides content or filename argument." {
  {
    "${_NB}" init
  }

  run "${_NB}" add "sample.md" --filename example.org

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0      ]]

  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}" -eq 1  ]]

  cd "${NB_DIR}/home" || return 1

  [[ -n "$(ls example.org)" ]]
  ! grep -q '# mock_editor' "${NB_DIR}/home"/*
  grep -q 'sample.md' "${NB_DIR}/home"/*

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

@test "'add' with extensionless --filename option creates file without extension." {
  {
    "${_NB}" init
  }

  run "${_NB}" add --filename example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0     ]]

  _files=($(ls "${NB_DIR}/home/"))

  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}" -eq 1 ]]

  cd "${NB_DIR}/home" || return 1

  [[   -n "$(ls example)"             ]]
  [[   -e "${NB_DIR}/home/example"    ]]
  [[ ! -e "${NB_DIR}/home/example.md" ]]

  grep -q '# mock_editor' "${NB_DIR}/home"/*

  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

@test "'add' with empty --filename option exits with 1" {
  {
    "${_NB}" init
  }

  run "${_NB}" add --filename

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 1      ]]

  cd "${NB_DIR}/home" || return 1

  ls "${NB_DIR}/home/"

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 0  ]]
}

# --type option ###############################################################

@test "'add --type org' with content argument creates a new .org note file." {
  {
    "${_NB}" init
  }

  run "${_NB}" add  "* Content" --type org

  [[ "${status}" -eq 0      ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1  ]]

  grep -q '* Content' "${NB_DIR}/home"/*

  [[ "${_files[0]}" =~ org$ ]]
}

@test "'add --type ''' without argument exits with 1." {
  {
    "${_NB}" init
  }

  run "${_NB}" add  "* Content" --type

  [[ "${status}" -eq 1      ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 0  ]]
}

# --encrypt option ############################################################

@test "'add --encrypt' with content argument creates a new .enc note file." {
  {
    "${_NB}" init
  }

  run "${_NB}" add  "* Content" --encrypt --password=example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${status}"      -eq 0                                                     ]]
  [[ "${#_files[@]}"  -eq 1                                                     ]]
  [[ "${_files[0]}"   =~  enc$                                                  ]]
  [[ "$(file "${NB_DIR}/home/${_files[0]}" | cut -d: -f2)" =~ encrypted|openssl ]]
}

@test "'add --encrypt' with invalid encryption tool displays error message." {
  {
    "${_NB}" init
  }

  NB_ENCRYPTION_TOOL="not-valid" run "${_NB}" add  "* Content" --encrypt --password=example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${status}"      -eq 1                             ]]
  [[ "${#_files[@]}"  -eq 0                             ]]
  [[ "${output}"      =~  Encryption\ tool\ not\ found: ]]
  [[ "${output}"      =~  not-valid                     ]]
}

# --password option ###########################################################

@test "'add --password' without argument exits with 1." {
  {
    "${_NB}" init
  }

  run "${_NB}" add  "* Content" --encrypt --password

  [[ "${status}"    -eq 1   ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 0  ]]
}

# help ########################################################################

@test "'help add' exits with status 0 and prints help information." {
  run "${_NB}" help add

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0         ]]

  [[ "${lines[0]}"  =~  Usage.*:  ]]
  [[ "${lines[1]}"  =~  nb\ add   ]]
}

@test "'help a' exits with status 0 and prints help information." {
  run "${_NB}" help a

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0         ]]

  [[ "${lines[0]}"  =~  Usage.*:  ]]
  [[ "${lines[1]}"  =~  nb\ add   ]]
}

@test "'help +' exits with status 0 and prints help information." {
  run "${_NB}" help +

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0         ]]

  [[ "${lines[0]}"  =~  Usage.*:  ]]
  [[ "${lines[1]}"  =~  nb\ add   ]]
}

@test "'help create' exits with status 0 and prints help information." {
  run "${_NB}" help create

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0         ]]

  [[ "${lines[0]}"  =~  Usage.*:  ]]
  [[ "${lines[1]}"  =~  nb\ add   ]]
}

@test "'help new' exits with status 0 and prints help information." {
  run "${_NB}" help new

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0         ]]

  [[ "${lines[0]}"  =~  Usage.*:  ]]
  [[ "${lines[1]}"  =~  nb\ add   ]]
}
