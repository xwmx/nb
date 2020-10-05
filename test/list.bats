#!/usr/bin/env bats

load test_helper

# `list` (empty) ##############################################################

@test "\`list\` (empty) exits with 0 and lists files." {
  {
    run "${_NB}" init
  }

  run "${_NB}" list

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="0 notes.

Add a note:
  $(_color_primary 'nb add')
Add a bookmark:
  $(_color_primary "nb <url>")
Import a file:
  $(_color_primary "nb import (<path> | <url>)")
Help information:
  $(_color_primary 'nb help')"

  [[ ${status} -eq 0                ]]
  [[ "${_expected}" == "${output}"  ]]
}

# `list` ######################################################################

@test "\`list\` exits with 0 and lists files in reverse order." {
  {
    "${_NB}" init
    "${_NB}" add "one.md" --title "one"
    "${_NB}" add "two.md" --title "two"
    "${_NB}" add "three.md" --title "three"
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${_files[@]}" "${lines[@]}"

  [[ ${status} -eq 0        ]]
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
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${_files[@]}" "${lines[@]}"

  [[ ${status} -eq 0                ]]
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
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list --no-id

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'${_files[2]}'" "'${lines[0]}'"

  [[ ${status} -eq 0          ]]
  [[ "${lines[0]}" =~ three   ]]
  [[ "${lines[1]}" =~ two     ]]
  [[ "${lines[2]}" =~ one     ]]
}

# `list --no-color` ###########################################################

@test "\`list --no-color\` exits with 0 and lists files in reverse order." {
  {
    "${_NB}" init
    "${_NB}" add "one.md" --title "one"
    "${_NB}" add "two.md" --title "two"
    "${_NB}" add "three.md" --title "three"
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list --no-color

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'[3] ${_files[2]}'" "'${lines[0]}'"

  [[ ${status} -eq 0          ]]
  [[ "${lines[0]}" =~ three   ]]
  [[ "${lines[1]}" =~ two     ]]
  [[ "${lines[2]}" =~ one     ]]
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
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list -e

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0        ]]
  [[ "${#lines[@]}" -eq 15  ]]
}

@test "\`list -e 2\` exits with 0 and displays 4 line list items." {
  {
    _setup_list_excerpt
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list -e 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0        ]]
  [[ "${#lines[@]}" -eq 12  ]]
}

@test "\`list -e 0\` exits with 0 and displays 1 line list items." {
  {
    _setup_list_excerpt
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list -e 0

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0      ]]
  [[ "${#lines[@]}" -eq 3 ]]
}

@test "\`list --excerpt\` exits with 0 and displays 5 line list items." {
  {
    _setup_list_excerpt
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list --excerpt

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0        ]]
  [[ "${#lines[@]}" -eq 15  ]]
}

@test "\`list --excerpt 2\` exits with 0 and displays 4 line list items." {
  {
    _setup_list_excerpt
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list --excerpt 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0        ]]
  [[ "${#lines[@]}" -eq 12  ]]
}

@test "\`list --excerpt 0\` exits with 0 and displays 1 line list items." {
  {
    _setup_list_excerpt
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list --excerpt 0

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0      ]]
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
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list -n

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0      ]]
  [[ "${#lines[@]}" -eq 3 ]]
}

@test "\`list -n 2\` exits with 0 and displays list with 2 items." {
  {
    _setup_list_limit
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list -n 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                            ]]
  [[ "${#lines[@]}" -eq 3                       ]]
  [[ "${lines[2]}" =~ 1\ omitted\.\ 3\ total\.  ]]
}

@test "\`list --limit 2\` exits with 0 and displays list with 2 items." {
  {
    _setup_list_limit
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list --limit 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                            ]]
  [[ "${#lines[@]}" -eq 3                       ]]
  [[ "${lines[2]}" =~ 1\ omitted\.\ 3\ total\.  ]]

}

@test "\`list --2\` exits with 0 and displays list with 2 items." {
  {
    _setup_list_limit
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list --2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                            ]]
  [[ "${#lines[@]}" -eq 3                       ]]
  [[ "${lines[2]}" =~ 1\ omitted\.\ 3\ total\.  ]]

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
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list --titles

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"
  printf "\${lines[1]}: '%s'\\n" "${lines[1]}"
  printf "\${lines[2]}: '%s'\\n" "${lines[2]}"

  [[ ${status} -eq 0            ]]
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
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list --filenames

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0            ]]
  [[ "${lines[0]}" =~ third.md  ]] && [[ "${lines[0]}" =~ 3 ]]
  [[ "${lines[1]}" =~ second.md ]] && [[ "${lines[1]}" =~ 2 ]]
  [[ "${lines[2]}" =~ first.md  ]] && [[ "${lines[2]}" =~ 1 ]]
}

# `list --paths` ##############################################################

@test "\`list --paths\` exits with 0 and displays a list of paths." {
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
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list --paths

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  printf "\${NB_NOTEBOOK_PATH}: '%s'\\n" "${NB_NOTEBOOK_PATH}"

  [[ ${status} -eq 0            ]]
  [[ "${lines[0]}" =~ third.md  ]] && [[ "${lines[0]}" =~ 3 ]]
  [[ "${lines[0]}" =~ ${NB_NOTEBOOK_PATH}                   ]]

  [[ "${lines[1]}" =~ second.md ]] && [[ "${lines[1]}" =~ 2 ]]
  [[ "${lines[1]}" =~ ${NB_NOTEBOOK_PATH}                   ]]

  [[ "${lines[2]}" =~ first.md  ]] && [[ "${lines[2]}" =~ 1 ]]
  [[ "${lines[2]}" =~ ${NB_NOTEBOOK_PATH}                   ]]
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
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list --bookmarks

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                      ]]
  [[ "${lines[0]}" =~ fourth.bookmark.md  ]] && [[ "${lines[0]}" =~ 4 ]]
  [[ "${lines[1]}" =~ second.bookmark.md  ]] && [[ "${lines[1]}" =~ 2 ]]
}

# `list --type` ###############################################################

@test "\`list --document\` exits with 0 and displays a list of documents." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first.md"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "second.doc"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "third.md"
line one
line two
line three
line four
HEREDOC
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list --document

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0              ]]
  [[ "${#lines[@]}" == 1          ]]
  [[ "${lines[0]}" =~ second.doc  ]]
  [[ "${lines[0]}" =~ 2           ]]
}

@test "\`list --documents\` exits with 0 and displays a list of documents." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first.md"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "second.doc"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "third.md"
line one
line two
line three
line four
HEREDOC
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list --documents

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0              ]]
  [[ "${#lines[@]}" == 1          ]]
  [[ "${lines[0]}" =~ second.doc  ]]
  [[ "${lines[0]}" =~ 2           ]]
}

@test "\`list --document\` exits with 0 and displays empty list." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first.md"
line one
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
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list --document

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                        ]]
  [[ "${#lines[@]}" == 5                    ]]
  [[ "${lines[0]}" =~ 0\ document\ files\.  ]]
}


@test "\`list --documents\` exits with 0 and displays empty list." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first.md"
line one
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
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list --documents

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                        ]]
  [[ "${#lines[@]}" == 5                    ]]
  [[ "${lines[0]}" =~ 0\ document\ files\.  ]]
}

@test "\`list --js\` exits with 0, displays empty list, and retains trailing 's'." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first.md"
line one
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
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list --js

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                  ]]
  [[ "${#lines[@]}" == 5              ]]
  [[ "${lines[0]}" =~ 0\ js\ files\.  ]]
}

# `list <selector>` ###########################################################

@test "\`list <selector>\` exits with 0 and displays the selector." {
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
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list 1 --filenames

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${#lines[@]}" -eq 1           ]]
  [[ "${lines[0]}" =~ first.md      ]]
  [[ "${lines[0]}" =~ [*1*]         ]]
  [[ "${lines[0]}" =~ ${_files[0]}  ]]
}

@test "\`list <query selector>\` exits with 0 and displays the selectors." {
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
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list 'r' --filenames

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${#lines[@]}" -eq 2           ]]
  [[ "${lines[0]}" =~ third.md      ]]
  [[ "${lines[0]}" =~ [*3*]         ]]
  [[ "${lines[0]}" =~ ${_files[2]}  ]]
  [[ "${lines[1]}" =~ first.md      ]]
  [[ "${lines[1]}" =~ [*1*]         ]]
  [[ "${lines[1]}" =~ ${_files[0]}  ]]
}

@test "\`list <query selector> --limit\` exits with 0 and displays results and singular omitted message." {
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
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list 'r' --filenames --limit 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                                  ]]
  [[ "${#lines[@]}" -eq 2                             ]]
  [[ "${lines[0]}" =~ third.md                        ]]
  [[ "${lines[0]}" =~ [*3*]                           ]]
  [[ "${lines[0]}" =~ ${_files[2]}                    ]]
  [[ "${lines[1]}" =~ 1\ match\ omitted\.\ 2\ total\. ]]
}

@test "\`list <query selector> --limit\` exits with 0 and displays results and plural omitted message." {
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
    cat <<HEREDOC | "${_NB}" add 'fourth.md'
# four
line two
line three
line four
HEREDOC
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list 'r' --filenames --limit 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                                    ]]
  [[ "${#lines[@]}" -eq 2                               ]]
  [[ "${lines[0]}" =~ fourth.md                         ]]
  [[ "${lines[0]}" =~ [*4*]                             ]]
  [[ "${lines[1]}" =~ 2\ matches\ omitted\.\ 3\ total\. ]]
}

@test "\`list <invalid-selector>\` exits with 1 and displays a message." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add
# one
line two
line three
line four
HEREDOC
    sleep 1
    _files=($(ls "${NB_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" list invalid

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 1                      ]]
  [[ "${#lines[@]}" -eq 1                 ]]
  [[ "${lines[0]}" =~ Not\ found\:  ]]
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

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${_files[@]}" "${lines[@]}"

  [[ ${status} -eq 0          ]]
  [[ "${lines[0]}" =~ one:3   ]]
  [[ "${lines[0]}" =~ three   ]]
  [[ "${lines[1]}" =~ one:2   ]]
  [[ "${lines[1]}" =~ two     ]]
  [[ "${lines[2]}" =~ one:1   ]]
  [[ "${lines[2]}" =~ one     ]]
}


@test "\`scoped:list\` with empty notebook prints help info." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
  }

  run "${_NB}" one:list
  [[ ${status} -eq 0 ]]

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="0 notes.

Add a note:
  $(_color_primary 'nb one:add')
Add a bookmark:
  $(_color_primary 'nb one: <url>')
Import a file:
  $(_color_primary 'nb one:import (<path> | <url>)')
Help information:
  $(_color_primary 'nb help')"

  [[ ${status} -eq 0                ]]
  [[ "${_expected}" == "${output}"  ]]
}

@test "\`scoped:list --bookmarks\` with empty notebook prints help info." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
  }

  run "${_NB}" one:list --bookmarks

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="0 bookmarks.

Add a bookmark:
  $(_color_primary 'nb one: <url>')
Help information:
  $(_color_primary 'nb help bookmark')"

  [[ ${status} -eq 0                ]]
  [[ "${_expected}" == "${output}"  ]]
}

@test "\`scoped:list --documents\` with empty notebook prints help info." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
  }

  run "${_NB}" one:list --documents

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="0 document files.

Import a file:
  $(_color_primary 'nb one:import (<path> | <url>)')
Help information:
  $(_color_primary 'nb help import')"

  [[ ${status} -eq 0                ]]
  [[ "${_expected}" == "${output}"  ]]
}

# `list --error-on-empty` #####################################################

@test "\`list --error-on-empty\` with empty notebook returns 1." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "one"
  }

  run "${_NB}" one:list
  [[ ${status} -eq 0 ]]

  run "${_NB}" one:list --error-on-empty
  [[ ${status} -eq 1 ]]

  "${_NB}" one:add "one.md" --title "one"

  run "${_NB}" one:list --error-on-empty
  [[ ${status} -eq 0 ]]
}

# `list <notebook>` ###########################################################

@test "\`list <notebook>\` exits with 1 and prints not found." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "example"
    "${_NB}" example:add "one.md" --title "one"
    "${_NB}" example:add "two.md" --title "two"
    "${_NB}" example:add "three.md" --title "three"
    _files=($(ls "${NB_DIR}/example/"))

    [[ "$("${_NB}" notebooks current)" == "home" ]]
  }

  run "${_NB}" list example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${_files[@]}" "${lines[@]}"

  [[ ${status} -eq 1              ]]
  [[ "${lines[0]}" =~ Not\ found  ]]
  [[ "${lines[0]}" =~ example     ]]
}

@test "\`list <notebook>:\` exits with 0 and lists files in reverse order." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "example"
    "${_NB}" example:add "one.md" --title "one"
    "${_NB}" example:add "two.md" --title "two"
    "${_NB}" example:add "three.md" --title "three"
    _files=($(ls "${NB_DIR}/example/"))
  }

  run "${_NB}" list example:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${_files[@]}" "${lines[@]}"

  [[ ${status} -eq 0              ]]
  [[ "${lines[0]}" =~ example:3   ]]
  [[ "${lines[0]}" =~ three       ]]
  [[ "${lines[1]}" =~ example:2   ]]
  [[ "${lines[1]}" =~ two         ]]
  [[ "${lines[2]}" =~ example:1   ]]
  [[ "${lines[2]}" =~ one         ]]
}

# help ########################################################################

@test "\`help list\` exits with status 0." {
  run "${_NB}" help list

  [[ ${status} -eq 0 ]]
}

@test "\`help list\` prints help information." {
  run "${_NB}" help list

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" =~ nb\ list ]]
}
