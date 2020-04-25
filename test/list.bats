#!/usr/bin/env bats

load test_helper

# `notes list` (empty) ########################################################

@test "\`list\` (empty) exits with 1 and lists files." {
  run "${_NOTES}" init
  run "${_NOTES}" list
  [[ ${status} -eq 1 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="0 notes.

Add a note:
  $(tput setaf 3)notes add$(tput sgr0)
Help information:
  $(tput setaf 3)notes help$(tput sgr0)"
  [[ "${_expected}" == "${output}" ]]
}

# `notes list` ################################################################

@test "\`list\` exits with 0 and lists files in reverse order." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "one.md" --title "one"
    "${_NOTES}" add "two.md" --title "two"
    "${_NOTES}" add "three.md" --title "three"
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NOTES}" list
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${_files[@]}" "${lines[@]}"

  [[ "${lines[0]}" =~ three ]]
  [[ "${lines[1]}" =~ two    ]]
  [[ "${lines[2]}" =~ one    ]]
}

# `notes list --no-id` ########################################################

@test "\`list --no-id\` exits with 0 and lists files in reverse order." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "one.md" --title "one"
    "${_NOTES}" add "two.md" --title "two"
    "${_NOTES}" add "three.md" --title "three"
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NOTES}" list --no-id
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'${_files[2]}'" "'${lines[0]}'"

  [[ "${lines[0]}" =~ three  ]]
  [[ "${lines[1]}" =~ two    ]]
  [[ "${lines[2]}" =~ one    ]]
}

# `notes list --no-color` #####################################################

@test "\`list --no-color\` exits with 0 and lists files in reverse order." {
  {
    "${_NOTES}" init
    "${_NOTES}" add "one.md" --title "one"
    "${_NOTES}" add "two.md" --title "two"
    "${_NOTES}" add "three.md" --title "three"
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NOTES}" list --no-color
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'[3] ${_files[2]}'" "'${lines[0]}'"

  [[ "${lines[0]}" =~ three  ]]
  [[ "${lines[1]}" =~ two    ]]
  [[ "${lines[2]}" =~ one    ]]
}

# `notes list (-e | --excerpt)` ###############################################

_setup_list_excerpt() {
  "${_NOTES}" init
    cat <<HEREDOC | "${_NOTES}" add "one.md"
# one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "two.md"
# two
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "three.md"
# three
line two
line three
line four
HEREDOC
}

@test "\`list -e\` exits with 0 and displays 5 line list items." {
  {
    _setup_list_excerpt
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NOTES}" list -e
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 15 ]]
}

@test "\`list -e 2\` exits with 0 and displays 4 line list items." {
  {
    _setup_list_excerpt
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NOTES}" list -e 2
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 12 ]]
}

@test "\`list -e 0\` exits with 0 and displays 1 line list items." {
  {
    _setup_list_excerpt
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NOTES}" list -e 0
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 3 ]]
}

@test "\`list --excerpt\` exits with 0 and displays 5 line list items." {
  {
    _setup_list_excerpt
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NOTES}" list --excerpt
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 15 ]]
}

@test "\`list --excerpt 2\` exits with 0 and displays 4 line list items." {
  {
    _setup_list_excerpt
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NOTES}" list --excerpt 2
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 12 ]]
}

@test "\`list --excerpt 0\` exits with 0 and displays 1 line list items." {
  {
    _setup_list_excerpt
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NOTES}" list --excerpt 0
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 3 ]]
}

# `notes list -n <limit>` #####################################################

_setup_list_limit() {
  "${_NOTES}" init
    cat <<HEREDOC | "${_NOTES}" add "one.md"
# one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "two.md"
# two
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "three.md"
# three
line two
line three
line four
HEREDOC
}

@test "\`list -n\` exits with 0 and displays full list." {
  {
    _setup_list_limit
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NOTES}" list -n
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 3 ]]
}

@test "\`list -n 2\` exits with 0 and displays list with 2 items." {
  {
    _setup_list_limit
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NOTES}" list -n 2
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 3 ]]

  [[ "${lines[2]}" == "1 omitted. 3 total." ]]
}

@test "\`list --2\` exits with 0 and displays list with 2 items." {
  {
    _setup_list_limit
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NOTES}" list --2
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 3 ]]

  [[ "${lines[2]}" == "1 omitted. 3 total." ]]
}

# `notes list --titles` #######################################################

@test "\`list --titles\` exits with 0 and displays a list of titles." {
  {
    "${_NOTES}" init
    cat <<HEREDOC | "${_NOTES}" add "first.md"
# one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "second.md"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "third.md"
# three
line two
line three
line four
HEREDOC
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NOTES}" list --titles
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${lines[0]}" =~ three$    ]] && [[ "${lines[0]}" =~ 3 ]]
  [[ "${lines[1]}" =~ second.md ]] && [[ "${lines[1]}" =~ 2 ]]
  [[ "${lines[2]}" =~ one$      ]] && [[ "${lines[2]}" =~ 1 ]]
}

# `notes list --filenames` ####################################################

@test "\`list --filenames\` exits with 0 and displays a list of filenames." {
  {
    "${_NOTES}" init
    cat <<HEREDOC | "${_NOTES}" add "first.md"
# one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "second.md"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "third.md"
# three
line two
line three
line four
HEREDOC
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NOTES}" list --filenames
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${lines[0]}" =~ third.md  ]] && [[ "${lines[0]}" =~ 3 ]]
  [[ "${lines[1]}" =~ second.md ]] && [[ "${lines[1]}" =~ 2 ]]
  [[ "${lines[2]}" =~ first.md  ]] && [[ "${lines[2]}" =~ 1 ]]
}

# `notes list --bookmarks` #######################################################

@test "\`list --bookmarks\` exits with 0 and displays a list of bookmarks." {
  {
    "${_NOTES}" init
    cat <<HEREDOC | "${_NOTES}" add "first.md"
# one
line two
line three
line four
HEREDOC
    "${_NOTES}" add "second.bookmark.md" -c "<${_BOOKMARK_URL}>"
    cat <<HEREDOC | "${_NOTES}" add "third.md"
line one
line two
line three
line four
HEREDOC
    "${_NOTES}" add "fourth.bookmark.md" -c "<${_BOOKMARK_URL}>"
    cat <<HEREDOC | "${_NOTES}" add "fifth.md"
# fifth
line two
line three
line four
HEREDOC
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NOTES}" list --bookmarks

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ fifth$               ]] && [[ "${lines[0]}" =~ 4 ]]
  [[ "${lines[1]}" =~ second.bookmark.md$  ]] && [[ "${lines[1]}" =~ 2 ]]
}

# `notes list <selection>` ####################################################

@test "\`list <selection>\` exits with 0 and displays the selection." {
  {
    "${_NOTES}" init
    cat <<HEREDOC | "${_NOTES}" add "first.md"
# one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "second.md"
# two
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "third.md"
# three
line two
line three
line four
HEREDOC
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NOTES}" list 1 --filenames

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0 ]]

  [[ "${#lines[@]}" -eq 1 ]]
  [[ "${lines[0]}" =~ first.md$ ]]
  [[ "${lines[0]}" =~ [*1*] ]]
  [[ "${lines[0]}" =~ ${_files[0]} ]]
}


@test "\`list <query selection>\` exits with 0 and displays the selections." {
  {
    "${_NOTES}" init
    cat <<HEREDOC | "${_NOTES}" add 'first.md'
# one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add 'second.md'
# two
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add 'third.md'
# three
line two
line three
line four
HEREDOC
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NOTES}" list 'r' --filenames
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 2 ]]
  [[ "${lines[0]}" =~ third.md$ ]]
  [[ "${lines[0]}" =~ [*3*] ]]
  [[ "${lines[0]}" =~ ${_files[2]} ]]
  [[ "${lines[1]}" =~ first.md$ ]]
  [[ "${lines[1]}" =~ [*1*] ]]
  [[ "${lines[1]}" =~ ${_files[0]} ]]
}

@test "\`list <invalid-selection>\` exits with 1 and displays a message." {
  {
    "${_NOTES}" init
    cat <<HEREDOC | "${_NOTES}" add
# one
line two
line three
line four
HEREDOC
    sleep 1
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NOTES}" list invalid
  [[ ${status} -eq 1 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 3 ]]
  [[ "${lines[0]}" == "Note not found: 'invalid'." ]]
}

# help ########################################################################

@test "\`help list\` exits with status 0." {
  run "${_NOTES}" help list
  [[ ${status} -eq 0 ]]
}

@test "\`help list\` prints help information." {
  run "${_NOTES}" help list
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" =~ notes\ list ]]
}
