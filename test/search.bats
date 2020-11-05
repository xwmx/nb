#!/usr/bin/env bats

load test_helper

_setup_search() {
  "${_NB}" init &>/dev/null
  cat <<HEREDOC | "${_NB}" add "first.md"
# one
idyl
HEREDOC
  cat <<HEREDOC | "${_NB}" add "second.md"
# two
sweetish
HEREDOC
  cat <<HEREDOC | "${_NB}" add "third.md"
# three
sweetish
HEREDOC
}

_search_all_setup() {
  _setup_search
  run "${_NB}" notebooks add one
  run "${_NB}" use one
  run "${_NB}" add example.md --title "sweetish"
  run "${_NB}" notebooks add two
  run "${_NB}" use two
  run "${_NB}" add example.md --title "sweetish"
  run "${_NB}" notebooks archive two
  [[ -e "${NB_DIR}/two/.archived" ]]
}

# `search` ####################################################################

@test "'search' exits with status 1 and prints help information." {
  {
    _setup_search

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NB}" search

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                        ]]
  [[ "${lines[0]}" =~ Usage\:               ]]
  [[ "${lines[1]}" =~ nb\ search\ \<query\> ]]
}

# `search <no match>` #########################################################

@test "'search <no match>' exits with status 1 and prints output." {
  {
    _setup_search

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NB}" search 'no match'

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}    -eq 1         ]]
  [[ "${output}"  =~ Not\ found ]]
  [[ "${output}"  =~ home       ]]
  [[ "${output}"  =~ no\ match  ]]
}

# `search <one match> [--path] [--list]` ######################################

@test "'search <one match>' exits with status 0 and prints output." {
  {
    _setup_search

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NB}" search 'idyl'

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[ ${status}        -eq 0         ]]
  [[ ! "${lines[0]}"  =~ first\.md  ]]
  [[ "${lines[0]}"    =~ one        ]]
  [[ "${lines[1]}"    =~ -*-        ]]
  [[ "${lines[2]}"    =~ idyl       ]]
}

@test "'search <one match>' includes emoji indicator." {
  {
    _setup_search

    run "${_NB}" add                        \
      --filename  "example.bookmark.md"     \
      --content   "<http://example.test/>"  \
      --title     "Example Title"

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NB}" search 'example.test' --no-color

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[ ${status}        -eq 0                   ]]
  [[ ! "${lines[0]}"  =~ example.bookmark.md  ]]
  [[ "${lines[0]}"    =~ Example\ Title       ]]
  [[ "${lines[0]}"    =~ \]\ 🔖               ]]
  [[ "${lines[1]}"    =~ -*-                  ]]
  [[ "${lines[2]}"    =~ example.test         ]]
}

@test "'search <one match> --path' exits with status 0 and prints path." {
  {
    _setup_search

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NB}" search 'idyl' --path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}      -eq 0                           ]]
  [[ "${lines[0]}"  =~ ${_NOTEBOOK_PATH}/first\.md  ]]
  [[ "${#lines[@]}" -eq 1                           ]]
}

@test "'search <one match> --list' exits with status 0 and prints listing." {
  {
    _setup_search

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NB}" search 'idyl' --list

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}        -eq 0         ]]
  [[ ! "${lines[0]}"  =~ first\.md  ]]
  [[ "${lines[0]}"    =~ one        ]]
  [[ "${#lines[@]}"   -eq 1         ]]
}

@test "'search <one filename match>' exits with status 0 and prints output." {
  {
    "${_NB}" init &>/dev/null
    cat <<HEREDOC | "${_NB}" add "1-example.md"
# one
idyl
HEREDOC
    cat <<HEREDOC | "${_NB}" add "sample.md"
# two
sweetish
HEREDOC
    cat <<HEREDOC | "${_NB}" add "third.md"
# three
sweetish
HEREDOC

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NB}" search '1-example.md'

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[ ${status}      -eq 0               ]]
  [[ "${lines[0]}"  =~ 1-example.md     ]]
  [[ "${lines[0]}"  =~ one              ]]
  [[ "${lines[1]}"  =~ -*-              ]]
  [[ "${lines[2]}"  =~ Filename\ Match  ]]
  [[ "${lines[2]}"  =~ 1-example.md     ]]
}

# `search` spacing and alignment ##############################################

@test "'search --list' / 'search -l' includes extra spacing to align with max notebook id length." {
  {
    _setup_search

    run "${_NB}" add                            \
      --filename  "example-1.bookmark.md"       \
      --content   "<http://example.test/>"      \
      --title     "Example Title One"

    for ((_i=0; _i < 11; _i++))
    do
      run "${_NB}" add "note ${_i}"
    done

    run "${_NB}" add                            \
      --filename  "example-2.bookmark.md"       \
      --content   "<http://example.test/>"      \
      --title     "Example Title Two"

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NB}" search 'example.test' --no-color --use-grep --list

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[ ${status}        -eq 0                     ]]
  [[ ! "${lines[0]}"  =~ example-1.bookmark.md  ]]
  [[ "${lines[0]}"    =~ Example\ Title\ One    ]]
  [[ "${lines[0]}"    =~ \]\ \ 🔖               ]]

  [[ ! "${lines[1]}"  =~ example-2.bookmark.md  ]]
  [[ "${lines[1]}"    =~ Example\ Title\ Two    ]]
  [[ "${lines[1]}"    =~ \]\ 🔖                 ]]
}

@test "'search' (no '--list' / '-l') does not include extra spacing." {
  {
    _setup_search

    run "${_NB}" add                            \
      --filename  "example-1.bookmark.md"       \
      --content   "<http://example.test/>"      \
      --title     "Example Title One"

    for ((_i=0; _i < 11; _i++))
    do
      run "${_NB}" add "note ${_i}"
    done

    run "${_NB}" add                            \
      --filename  "example-2.bookmark.md"       \
      --content   "<http://example.test/>"      \
      --title     "Example Title Two"

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NB}" search 'example.test' --no-color --use-grep

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[ ${status}        -eq 0                     ]]
  [[ ! "${lines[0]}"  =~ example-1.bookmark.md  ]]
  [[ "${lines[0]}"    =~ Example\ Title\ One    ]]
  [[ "${lines[0]}"    =~ \]\ 🔖                 ]]
  [[ ! "${lines[0]}"  =~ \]\ \ 🔖               ]]
  [[ "${lines[1]}"    =~ -*-                    ]]
  [[ "${lines[2]}"    =~ example.test           ]]

  [[ ! "${lines[3]}"  =~ example-2.bookmark.md  ]]
  [[ "${lines[3]}"    =~ Example\ Title\ Two    ]]
  [[ "${lines[3]}"    =~ \]\ 🔖                 ]]
  [[ "${lines[4]}"    =~ -*-                    ]]
  [[ "${lines[5]}"    =~ example.test           ]]
}

# `search <multiple matches> [--path] [--list]` ###############################

@test "'search <multiple matches>' exits with status 0 and prints output." {
  {
    _setup_search

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NB}" search 'sweetish' --use-grep

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${lines[3]}: '%s'\\n" "${lines[3]}"

  [[ ${status}        -eq 0             ]]
  [[ ! "${lines[0]}"  =~ second\.md     ]]
  [[ "${lines[0]}"    =~ two            ]]
  [[ "${lines[1]}"    =~ -*-            ]]
  [[ "${lines[2]}"    =~ sweetish       ]]
  [[ ! "${lines[3]}"  =~ third\.md      ]]
  [[ "${lines[3]}"    =~ three          ]]
  [[ "${lines[4]}"    =~ -*-            ]]
  [[ "${lines[5]}"    =~ sweetish       ]]
  [[ "${lines[0]}"    != "${lines[3]}"  ]]
}

@test "'search <multiple matches> --path' exits with 0 and prints paths." {
  {
    _setup_search

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NB}" search 'sweetish' --path --use-grep

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[ ${status} -eq 0                                ]]
  [[ "${lines[0]}" =~ ${_NOTEBOOK_PATH}/second\.md  ]]
  [[ "${lines[1]}" =~ ${_NOTEBOOK_PATH}/third\.md   ]]
  [[ "${#lines[@]}" -eq 2                           ]]
}

@test "'search <multiple matches> --list' exits with 0 and prints listings." {
  {
    _setup_search

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NB}" search 'sweetish' --list --use-grep

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[ ${status}        -eq 0         ]]
  [[ ! "${lines[0]}"  =~ second\.md ]]
  [[ "${lines[0]}"    =~ two        ]]
  [[ ! "${lines[1]}"  =~ third\.md  ]]
  [[ "${lines[1]}"    =~ three      ]]
  [[ "${#lines[@]}"   -eq 2         ]]
}

@test "'search <multiple filename match>' exits with status 0 and prints output." {
  {
    "${_NB}" init &>/dev/null
    cat <<HEREDOC | "${_NB}" add "1-example.md"
# one
idyl
HEREDOC
    cat <<HEREDOC | "${_NB}" add "sample.md"
# two
sweetish
HEREDOC
    cat <<HEREDOC | "${_NB}" add "2-example.md"
# three
sweetish
HEREDOC

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NB}" search 'example.md'

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[ ${status}      -eq 0               ]]
  [[ "${lines[0]}"  =~ example.md       ]]
  [[ "${lines[0]}"  =~ 1                ]]
  [[ "${lines[0]}"  =~ one              ]]
  [[ "${lines[1]}"  =~ -*-              ]]
  [[ "${lines[2]}"  =~ Filename\ Match  ]]
  [[ "${lines[2]}"  =~ example.md       ]]
  [[ "${lines[2]}"  =~ 1                ]]
  [[ "${lines[3]}"  =~ example.md       ]]
  [[ "${lines[3]}"  =~ 2                ]]
  [[ "${lines[3]}"  =~ three            ]]
  [[ "${lines[4]}"  =~ -*-              ]]
  [[ "${lines[5]}"  =~ Filename\ Match  ]]
  [[ "${lines[5]}"  =~ example.md       ]]
  [[ "${lines[5]}"  =~ 2                ]]
}

@test "'search' output includes indicators." {
  {
    _setup_search

  cat <<HEREDOC | "${_NB}" add "fourth.bookmark.md"
# four

<https://example.com/>

sweetish
HEREDOC
    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NB}" search 'sweetish' --use-grep

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_filename}: '%s'\\n" "${_filename}"
  printf "\${lines[3]}: '%s'\\n"  "${lines[3]}"

  [[ ${status}        -eq 0                   ]]
  [[ "${output}"      =~ 🔖                   ]]
  [[ ! "${lines[0]}"  =~ fourth\.bookmark\.md ]]
  [[ "${lines[0]}"    =~ four                 ]]
  [[ "${lines[1]}"    =~ -*-                  ]]
  [[ "${lines[2]}"    =~ sweetish             ]]
}

# `search --bookmarks` #################################################

@test "'search --bookmarks' exits with status 0 and prints output." {
  {
    _setup_search

  cat <<HEREDOC | "${_NB}" add "fourth.bookmark.md"
# four

<https://example.com/>

sweetish
HEREDOC
  cat <<HEREDOC | "${_NB}" add "fifth.bookmark.md"
# five

<https://example.com/>

idyl
HEREDOC
  cat <<HEREDOC | "${_NB}" add "sixth.bookmark.md"
# six

<https://example.com/>

sweetish
HEREDOC
    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NB}" search 'sweetish' --bookmarks --use-grep

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_filename}: '%s'\\n" "${_filename}"
  printf "\${lines[3]}: '%s'\\n"  "${lines[3]}"

  [[ ${status}        -eq 0                   ]]
  [[ ! "${lines[0]}"  =~ fourth\.bookmark\.md ]]
  [[ "${lines[0]}"    =~ four                 ]]
  [[ "${lines[1]}"    =~ -*-                  ]]
  [[ "${lines[2]}"    =~ sweetish             ]]
  [[ ! "${lines[3]}"  =~ sixth\.bookmark\.md  ]]
  [[ "${lines[3]}"    =~ six                  ]]
  [[ "${lines[4]}"    =~ -*-                  ]]
  [[ "${lines[5]}"    =~ sweetish             ]]
  [[ "${lines[0]}"    != "${lines[3]}"        ]]
}

# `search <query> --all [--path]` #############################################

@test "'search <query> --all' exits with status 0 and prints output." {
  {
    _search_all_setup
  }

  run "${_NB}" search 'sweetish' --all --use-grep

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  "${_NB}" notebooks --paths --unarchived
  "${_NB}" notebooks --paths --unarchived
  "${_NB}" two:notebooks status

  [[ ${status}        -eq 0           ]]
  [[ "${lines[0]}"    =~ home:2       ]]
  [[ ! "${lines[0]}"  =~ second\.md   ]]
  [[ "${lines[0]}"    =~ two          ]]
  [[ "${lines[1]}"    =~ -*-          ]]
  [[ "${lines[2]}"    =~ sweetish     ]]
  [[ "${lines[3]}"    =~ home:3       ]]
  [[ "${lines[4]}"    =~ -*-          ]]
  [[ ! "${lines[3]}"  =~ third\.md    ]]
  [[ "${lines[3]}"    =~ three        ]]
  [[ "${lines[5]}"    =~ sweetish     ]]
  [[ "${lines[6]}"    =~ one:1        ]]
  [[ ! "${lines[6]}"  =~ example\.md  ]]
  [[ "${lines[6]}"    =~ sweetish     ]]
  [[ "${#lines[@]}"   -eq 9           ]]
}

@test "'search <query> -a' exits with status 0 and prints output." {
  {
    _search_all_setup &>/dev/null
  }

  run "${_NB}" search 'sweetish' -a --use-grep

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status}        -eq 0           ]]
  [[ "${lines[0]}"    =~ home:2       ]]
  [[ ! "${lines[0]}"  =~ second\.md   ]]
  [[ "${lines[0]}"    =~ two          ]]
  [[ "${lines[1]}"    =~ -*-          ]]
  [[ "${lines[2]}"    =~ sweetish     ]]
  [[ "${lines[3]}"    =~ home:3       ]]
  [[ ! "${lines[3]}"  =~ third\.md    ]]
  [[ "${lines[3]}"    =~ three        ]]
  [[ "${lines[4]}"    =~ -*-          ]]
  [[ "${lines[5]}"    =~ sweetish     ]]
  [[ "${lines[6]}"    =~ one:1        ]]
  [[ ! "${lines[6]}"  =~ example\.md  ]]
  [[ "${lines[6]}"    =~ sweetish     ]]
  [[ "${#lines[@]}"   -eq 9           ]]
}

@test "'search <no matching query> --all' exits with status 1 and prints output." {
  {
    _search_all_setup  &>/dev/null
  }

  run "${_NB}" search 'no match' --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${lines[3]}: '%s'\\n" "${lines[3]}"

  [[ ${status}    -eq 1                 ]]
  [[ "${output}"  =~ Not\ found         ]]
  [[ "${output}"  =~ in\ any\ notebook  ]]
  [[ "${output}"  =~ no\ match          ]]
}

@test "'search <multiple matches> --all --path' exits with 0 and prints paths." {
  {
    _search_all_setup  &>/dev/null
  }

  run "${_NB}" search 'sweetish' --all --path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[ ${status} -eq 0 ]]
  echo "${output}" | grep -q '/home/third\.md'
  echo "${output}" | grep -q '/home/second\.md'
  echo "${output}" | grep -q '/one/example\.md'
  [[ "${#lines[@]}" -eq 3 ]]
}

@test "'search <no matching query> --all --path' exits with 1 and and prints output." {
  {
    _search_all_setup  &>/dev/null
  }

  run "${_NB}" search 'no match' --all --path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"

  [[ ${status}    -eq 1                 ]]
  [[ "${output}"  =~ Not\ found         ]]
  [[ "${output}"  =~ in\ any\ notebook  ]]
  [[ "${output}"  =~ no\ match          ]]
}

# `search <query> [--all]` local ##############################################

@test "'search <query>' in local notebook exits with status 0 and prints output." {
  {
    _search_all_setup &>/dev/null

    mkdir -p "${_TMP_DIR}/example"

    cd "${_TMP_DIR}/example"

    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]

    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"

    "${_NB}" add example-1.md --title "one" --content "sweetish"
    "${_NB}" add example-2.md --title "two"
  }

  run "${_NB}" search 'sweetish' --use-grep

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status}        -eq 0           ]]
  [[ "${lines[0]}"    =~ 1            ]]
  [[ ! "${lines[0]}"  =~ example-1.md ]]
  [[ "${lines[0]}"    =~ one          ]]
  [[ "${lines[1]}"    =~ -*-          ]]
  [[ "${lines[2]}"    =~ sweetish     ]]
  [[ "${#lines[@]}"   -eq 3           ]]
}

@test "'search <query> --all' in local notebook exits with status 0 and prints output." {
  {
    _search_all_setup &>/dev/null
    "${_NB}" notebooks init "${_TMP_DIR}/example"

    cd "${_TMP_DIR}/example"

    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]

    "${_NB}" add example-1.md --title "one" --content "sweetish"
    "${_NB}" add example-2.md --title "two"
  }

  run "${_NB}" search 'sweetish' --all --use-grep

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  printf "\${lines[0]}: '%s'\\n" "${lines[0]}"
  printf "\${lines[1]}: '%s'\\n" "${lines[1]}"
  printf "\${lines[2]}: '%s'\\n" "${lines[2]}"
  printf "\${lines[3]}: '%s'\\n" "${lines[3]}"
  printf "\${lines[4]}: '%s'\\n" "${lines[4]}"
  printf "\${lines[5]}: '%s'\\n" "${lines[5]}"
  printf "\${lines[6]}: '%s'\\n" "${lines[6]}"
  printf "\${lines[7]}: '%s'\\n" "${lines[7]}"
  printf "\${lines[8]}: '%s'\\n" "${lines[8]}"

  [[ ${status}        -eq 0           ]]
  [[ "${lines[0]}"    =~ local:1      ]]
  [[ ! "${lines[0]}"  =~ example-1.md ]]
  [[ "${lines[0]}"    =~ one          ]]
  [[ "${lines[1]}"    =~ -*-          ]]
  [[ "${lines[2]}"    =~ sweetish     ]]
  [[ "${lines[3]}"    =~ home:2       ]]
  [[ ! "${lines[3]}"  =~ second\.md   ]]
  [[ "${lines[3]}"    =~ two          ]]
  [[ "${lines[4]}"    =~ -*-          ]]
  [[ "${lines[5]}"    =~ sweetish     ]]
  [[ "${lines[6]}"    =~ home:3       ]]
  [[ ! "${lines[6]}"  =~ third\.md    ]]
  [[ "${lines[6]}"    =~ three        ]]
  [[ "${lines[7]}"    =~ -*-          ]]
  [[ "${lines[8]}"    =~ sweetish     ]]
  [[ "${lines[9]}"    =~ one:1        ]]
  [[ ! "${lines[9]}"  =~ example\.md  ]]
  [[ "${lines[9]}"    =~ sweetish     ]]
  [[ "${#lines[@]}"   -eq 12          ]]
}

# help ########################################################################

@test "'help search' exits with status 0." {
  run "${_NB}" help search

  [[ ${status} -eq 0 ]]
}

@test "'help search' prints help information." {
  run "${_NB}" help search

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Usage\:               ]]
  [[ "${lines[1]}" =~ nb\ search\ \<query\> ]]
}
