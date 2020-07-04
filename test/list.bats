#!/usr/bin/env bats

load test_helper

# `list` (empty) ##############################################################

@test "\`list\` (empty) exits with 0 and lists files." {
  run "${_NB}" init
  run "${_NB}" list

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="0 notes.

Add a note:
  $(_highlight 'nb add')
Add a bookmark:
  $(_highlight "nb <url>")
Import a file:
  $(_highlight "nb import (<path> | <url>)")
Help information:
  $(_highlight 'nb help')"
  [[ ${status} -eq 0 ]]
  [[ "${_expected}" == "${output}" ]]
}

# `list` ######################################################################

@test "\`list\` exits with 0 and lists files in reverse order." {
  {
    "${_NB}" init
    "${_NB}" add "one.md" --title "one"
    "${_NB}" add "two.md" --title "two"
    "${_NB}" add "three.md" --title "three"
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${_files[@]}" "${lines[@]}"

  [[ "${lines[0]}" =~ three ]]
  [[ "${lines[1]}" =~ two   ]]
  [[ "${lines[2]}" =~ one   ]]
}

@test "\`list\` includes indicators." {
  {
    "${_NB}" init
    "${_NB}" add "one.bookmark.md" --content "<https://example.com>"
    "${_NB}" add "two.md" --content "Example Content."
    "${_NB}" add "three.md" --title "Three" --encrypt --password=example
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${_files[@]}" "${lines[@]}"

  [[ "${lines[0]}" =~ three.md.enc  ]]
  [[ "${lines[0]}" =~ 🔒            ]]
  [[ "${lines[1]}" =~ two.md        ]]
  [[ "${lines[2]}" =~ bookmark      ]]
  [[ "${lines[2]}" =~ 🔖            ]]
}

# `list --no-id` ##############################################################

@test "\`list --no-id\` exits with 0 and lists files in reverse order." {
  {
    "${_NB}" init
    "${_NB}" add "one.md" --title "one"
    "${_NB}" add "two.md" --title "two"
    "${_NB}" add "three.md" --title "three"
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list --no-id
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'${_files[2]}'" "'${lines[0]}'"

  [[ "${lines[0]}" =~ three  ]]
  [[ "${lines[1]}" =~ two    ]]
  [[ "${lines[2]}" =~ one    ]]
}

# `list --no-color` ###########################################################

@test "\`list --no-color\` exits with 0 and lists files in reverse order." {
  {
    "${_NB}" init
    "${_NB}" add "one.md" --title "one"
    "${_NB}" add "two.md" --title "two"
    "${_NB}" add "three.md" --title "three"
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list --no-color
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'[3] ${_files[2]}'" "'${lines[0]}'"

  [[ "${lines[0]}" =~ three  ]]
  [[ "${lines[1]}" =~ two    ]]
  [[ "${lines[2]}" =~ one    ]]
}

# `list (-e | --excerpt)` #####################################################

_setup_list_excerpt() {
  "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "one.md"
# one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "two.md"
# two
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "three.md"
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

  run "${_NB}" list -e
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

  run "${_NB}" list -e 2
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

  run "${_NB}" list -e 0
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

  run "${_NB}" list --excerpt
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

  run "${_NB}" list --excerpt 2
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

  run "${_NB}" list --excerpt 0
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 3 ]]
}

# `list -n <limit>` ###########################################################

_setup_list_limit() {
  "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "one.md"
# one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "two.md"
# two
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "three.md"
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

  run "${_NB}" list -n
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

  run "${_NB}" list -n 2
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 3 ]]

  [[ "${lines[2]}" == "1 omitted. 3 total." ]]
}

@test "\`list --limit 2\` exits with 0 and displays list with 2 items." {
  {
    _setup_list_limit
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list --limit 2
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

  run "${_NB}" list --2
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 3 ]]

  [[ "${lines[2]}" == "1 omitted. 3 total." ]]
}

# `list --titles` #############################################################

@test "\`list --titles\` exits with 0 and displays a list of titles." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first.md"
# one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "second.md"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "third.md"
# three
line two
line three
line four
HEREDOC
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list --titles
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"
  printf "\${lines[1]}: '%s'\\n" "${lines[1]}"
  printf "\${lines[2]}: '%s'\\n" "${lines[2]}"

  [[ "${lines[0]}" =~ three     ]] && [[ "${lines[0]}" =~ 3 ]]
  [[ "${lines[1]}" =~ second.md ]] && [[ "${lines[1]}" =~ 2 ]]
  [[ "${lines[2]}" =~ one       ]] && [[ "${lines[2]}" =~ 1 ]]
}

# `list --filenames` ##########################################################

@test "\`list --filenames\` exits with 0 and displays a list of filenames." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first.md"
# one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "second.md"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "third.md"
# three
line two
line three
line four
HEREDOC
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list --filenames
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${lines[0]}" =~ third.md  ]] && [[ "${lines[0]}" =~ 3 ]]
  [[ "${lines[1]}" =~ second.md ]] && [[ "${lines[1]}" =~ 2 ]]
  [[ "${lines[2]}" =~ first.md  ]] && [[ "${lines[2]}" =~ 1 ]]
}

# `list --bookmarks` ##########################################################

@test "\`list --bookmarks\` exits with 0 and displays a list of bookmarks." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first.md"
# one
line two
line three
line four
HEREDOC
    "${_NB}" add "second.bookmark.md" -c "<${_BOOKMARK_URL}>"
    cat <<HEREDOC | "${_NB}" add "third.md"
line one
line two
line three
line four
HEREDOC
    "${_NB}" add "fourth.bookmark.md" -c "<${_BOOKMARK_URL}>"
    cat <<HEREDOC | "${_NB}" add "fifth.md"
# fifth
line two
line three
line four
HEREDOC
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list --bookmarks

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ fourth.bookmark.md  ]] && [[ "${lines[0]}" =~ 4 ]]
  [[ "${lines[1]}" =~ second.bookmark.md  ]] && [[ "${lines[1]}" =~ 2 ]]
}

# `list <selection>` ##########################################################

@test "\`list <selection>\` exits with 0 and displays the selection." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first.md"
# one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "second.md"
# two
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "third.md"
# three
line two
line three
line four
HEREDOC
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list 1 --filenames

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0 ]]

  [[ "${#lines[@]}" -eq 1 ]]
  [[ "${lines[0]}" =~ first.md ]]
  [[ "${lines[0]}" =~ [*1*] ]]
  [[ "${lines[0]}" =~ ${_files[0]} ]]
}


@test "\`list <query selection>\` exits with 0 and displays the selections." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add 'first.md'
# one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add 'second.md'
# two
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add 'third.md'
# three
line two
line three
line four
HEREDOC
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list 'r' --filenames
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 2 ]]
  [[ "${lines[0]}" =~ third.md ]]
  [[ "${lines[0]}" =~ [*3*] ]]
  [[ "${lines[0]}" =~ ${_files[2]} ]]
  [[ "${lines[1]}" =~ first.md ]]
  [[ "${lines[1]}" =~ [*1*] ]]
  [[ "${lines[1]}" =~ ${_files[0]} ]]
}

@test "\`list <invalid-selection>\` exits with 1 and displays a message." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add
# one
line two
line three
line four
HEREDOC
    sleep 1
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list invalid
  [[ ${status} -eq 1 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 1 ]]
  [[ "${lines[0]}" =~ Note\ not\ found\:  ]]
  [[ "${lines[0]}" =~ invalid             ]]
}

# `scoped:list` ###############################################################

@test "\`scoped:list\` exits with 0 and lists files in reverse order." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
    "${_NB}" one:add "one.md" --title "one"
    "${_NB}" one:add "two.md" --title "two"
    "${_NB}" one:add "three.md" --title "three"
    _files=($(ls "${NB_DIR}/one/"))
  }

  run "${_NB}" one:list
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${_files[@]}" "${lines[@]}"

  [[ "${lines[0]}" =~ one:3   ]]
  [[ "${lines[0]}" =~ three   ]]
  [[ "${lines[1]}" =~ one:2   ]]
  [[ "${lines[1]}" =~ two     ]]
  [[ "${lines[2]}" =~ one:1   ]]
  [[ "${lines[2]}" =~ one     ]]
}

# help ########################################################################

@test "\`help list\` exits with status 0." {
  run "${_NB}" help list
  [[ ${status} -eq 0 ]]
}

@test "\`help list\` prints help information." {
  run "${_NB}" help list
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" =~ nb\ list ]]
}
