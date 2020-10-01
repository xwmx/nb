#!/usr/bin/env bats

load test_helper

_setup_ls() {
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
}

# `ls` ########################################################################

@test "\`ls\` exits with 0 and lists files." {
  {
    _setup_ls
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "three" "${lines[0]}"

  [[ ${status} -eq 0          ]]
  [[ "${lines[0]}" =~ home    ]]
  [[ "${lines[1]}" =~ ----    ]]
  [[ "${lines[2]}" =~ three   ]]
  [[ "${lines[3]}" =~ two     ]]
  [[ "${lines[4]}" =~ one     ]]
}

@test "\`ls\` exits with 0 and includes archive count." {
  {
    _setup_ls
    "${_NB}" notebooks add one
    "${_NB}" one:notebook archive
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "three" "${lines[0]}"

  [[ ${status} -eq 0                        ]]
  [[ "${lines[0]}" =~ home                  ]]
  [[ "${lines[0]}" =~ .\ \[1\ archived\]    ]]
  [[ "${lines[1]}" =~ -------------------   ]]
  [[ "${lines[2]}" =~ three                 ]]
  [[ "${lines[3]}" =~ two                   ]]
  [[ "${lines[4]}" =~ one                   ]]
}

@test "\`ls\` with local includes it in notebook list." {
  {
    _setup_ls
    mkdir -p "${_TMP_DIR}/example"
    cd "${_TMP_DIR}/example"
    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]
    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"

    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "three" "${lines[0]}"

  [[ ${status} -eq 0                ]]
  [[ "${lines[0]}" =~ local         ]]
  [[ "${lines[0]}" =~ home          ]]
  [[ "${lines[1]}" =~ ------------  ]]
  [[ "${lines[2]}" =~ 0\ notes\.    ]]
}

# `ls -e [<excerpt length>]` ##################################################

@test "\`ls -e <excerpt length>\` exits with 0 and displays excerpts." {
  {
    _setup_ls
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" ls -e 5

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0        ]]
  [[ "${#lines[@]}" -eq 18  ]]
}

# `ls -n <number>`, ls --limit <number>, ls --<number> ########################

@test "\`ls -n 0\` exits with 0 and lists 0 files." {
  {
    _setup_ls
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" ls -n 0

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                            ]]
  [[ "${#lines[@]}" -eq 6                       ]]
  [[ "${lines[2]}" =~ 3\ omitted\.\ 3\ total\.  ]]
}

@test "\`ls -n 1\` exits with 0 and lists 1 file." {
  {
    _setup_ls
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" ls -n 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

  [[ ${status} -eq 0                            ]]
  [[ "${#lines[@]}" -eq 7                       ]]
  [[ "${lines[2]}" =~ three                     ]]
  [[ "${lines[3]}" =~ 2\ omitted\.\ 3\ total\.  ]]
}

@test "\`ls -n 2\` exits with 0 and lists 2 files." {
  {
    _setup_ls
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" ls -n 2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

  [[ ${status} -eq 0                            ]]
  [[ "${#lines[@]}" -eq 8                       ]]
  [[ "${lines[2]}" =~ three                     ]]
  [[ "${lines[3]}" =~ two                       ]]
  [[ "${lines[4]}" =~ 1\ omitted\.\ 3\ total\.  ]]
}

@test "\`ls -n 3\` exits with 0 and lists 3 files." {
  {
    _setup_ls
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" ls -n 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  _compare "${lines[0]}" "three"

  [[ ${status} -eq 0        ]]
  [[ "${#lines[@]}" -eq 8   ]]
  [[ "${lines[2]}" =~ three ]]
  [[ "${lines[3]}" =~ two   ]]
  [[ "${lines[4]}" =~ one   ]]
}

@test "\`ls --limit 3\` exits with 0 and lists 3 files." {
  {
    _setup_ls
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" ls -n 3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  _compare "${lines[0]}" "three"

  [[ ${status} -eq 0        ]]
  [[ "${#lines[@]}" -eq 8   ]]
  [[ "${lines[2]}" =~ three ]]
  [[ "${lines[3]}" =~ two   ]]
  [[ "${lines[4]}" =~ one   ]]
}

@test "\`ls --3\` exits with 0 and lists 3 files." {
  {
    _setup_ls
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" ls --3

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  _compare "${lines[0]}" "three"

  [[ ${status} -eq 0        ]]
  [[ "${#lines[@]}" -eq 8   ]]
  [[ "${lines[2]}" =~ three ]]
  [[ "${lines[3]}" =~ two   ]]
  [[ "${lines[4]}" =~ one   ]]
}

# `ls -s` / `ls --sort` / `ls -r` / `ls --reverse` ############################

@test "\`ls --sort\` sorts items." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first-home.md"
# title one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "second-home.md"
# title two
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "third-example.md"
# title three
line two
line three
line four
HEREDOC
  }

  run "${_NB}" ls --sort

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${#lines[@]}" -eq 3           ]]
  [[ "${lines[0]}" =~ title\ one    ]]
  [[ "${lines[0]}" =~ [*1*]         ]]
  [[ "${lines[1]}" =~ title\ two    ]]
  [[ "${lines[1]}" =~ [*2*]         ]]
  [[ "${lines[2]}" =~ title\ three  ]]
  [[ "${lines[2]}" =~ [*3*]         ]]
}

@test "\`ls --sort --reverse\` reverse sorts items." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first-home.md"
# title one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "second-home.md"
# title two
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "third-example.md"
# title three
line two
line three
line four
HEREDOC
  }

  run "${_NB}" ls --sort --reverse

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${#lines[@]}" -eq 3           ]]
  [[ "${lines[0]}" =~ title\ three  ]]
  [[ "${lines[0]}" =~ [*3*]         ]]
  [[ "${lines[1]}" =~ title\ two    ]]
  [[ "${lines[1]}" =~ [*2*]         ]]
  [[ "${lines[2]}" =~ title\ one    ]]
  [[ "${lines[2]}" =~ [*1*]         ]]
}

@test "\`ls --sort\` retains limit." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first-home.md"
# title one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "second-home.md"
# title two
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "third-example.md"
# title three
line two
line three
line four
HEREDOC

  "${_NB}" set limit 2
  }

  run "${_NB}" ls --sort

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                        ]]
  [[ "${#lines[@]}" -eq 3                   ]]
  [[ "${lines[0]}" =~ title\ one            ]]
  [[ "${lines[0]}" =~ [*1*]                 ]]
  [[ "${lines[1]}" =~ title\ two            ]]
  [[ "${lines[1]}" =~ [*2*]                 ]]
  [[ "${lines[2]}" == "1 omitted. 3 total." ]]
}

# `ls -a` / `ls --all` ########################################################

_setup_ls_all() {
  "${_NB}" init

  for (( _i=1; _i<31; _i++ ))
  do
    cat <<HEREDOC | "${_NB}" add "${_i}.md"
# ${_i}
line two
line three
line four
HEREDOC
  done
}

@test "\`ls --2\` exits with 0 and lists 2 items." {
  {
    _setup_ls_all
  }

  run "${_NB}" ls --2

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0        ]]
  [[ "${#lines[@]}" -eq 8   ]]
  [[ "${lines[2]}" =~ '30'  ]]
  [[ "${lines[3]}" =~ '29'  ]]
}

@test "\`ls\` exits with 0 and lists 20 items." {
  {
    _setup_ls_all
  }

  run "${_NB}" ls

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[@]}: '%s'\\n" "${lines[@]}"
  printf "\${lines[3]}: '%s'\\n" "${lines[3]}"

  [[ ${status} -eq 0              ]]
  [[ "${#lines[@]}" -eq 26        ]]
  [[ "${lines[2]}"  =~ '30'       ]]
  [[ "${lines[3]}"  =~ '29'       ]]
  [[ "${lines[21]}" =~ '11'       ]]
  [[ "${lines[22]}" =~ 'omitted'  ]]
}

@test "\`ls -a\` exits with 0 and lists all items." {
  {
    _setup_ls_all
  }

  run "${_NB}" ls -a

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[@]}: '%s'\\n" "${lines[@]}"
  printf "\${lines[3]}: '%s'\\n" "${lines[3]}"

  [[ ${status} -eq 0        ]]
  [[ "${#lines[@]}" -eq 35  ]]
  [[ "${lines[2]}"  =~ '30' ]]
  [[ "${lines[3]}"  =~ '29' ]]
  [[ "${lines[21]}" =~ '11' ]]
  [[ "${lines[22]}" =~ '10' ]]
  [[ "${lines[32]}" =~ \-\- ]]
}

@test "\`ls --all\` exits with 0 and lists all items." {
  {
    _setup_ls_all
  }

  run "${_NB}" ls --all

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[@]}: '%s'\\n" "${lines[@]}"
  printf "\${lines[3]}: '%s'\\n" "${lines[3]}"

  [[ ${status} -eq 0        ]]
  [[ "${#lines[@]}" -eq 35  ]]
  [[ "${lines[2]}"  =~ '30' ]]
  [[ "${lines[3]}"  =~ '29' ]]
  [[ "${lines[21]}" =~ '11' ]]
  [[ "${lines[22]}" =~ '10' ]]
  [[ "${lines[32]}" =~ \-\- ]]
}

# `ls <selector>` #############################################################

@test "\`ls <selector>\` exits with 0 and displays the selector." {
  {
    _setup_ls
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" ls 1 --filenames

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${#lines[@]}" -eq 1           ]]
  [[ "${lines[0]}" =~ first.md      ]]
  [[ "${lines[0]}" =~ [*1*]         ]]
  [[ "${lines[0]}" =~ ${_files[0]}  ]]
}

@test "\`ls <query selector>\` exits with 0 and displays the selectors." {
  {
    _setup_ls
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" ls 'r' --filenames

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

@test "\`ls <invalid-selector>\` exits with 1 and displays a message." {
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

  run "${_NB}" ls not-valid

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 1                ]]
  [[ "${#lines[@]}" -eq 1           ]]
  [[ "${lines[0]}" =~ Not\ found\:  ]]
  [[ "${lines[0]}" =~ not-valid     ]]
}

@test "\`ls <notebook>\` exits with 0 and runs ls in the notebook." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first-home.md"
# one home
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "second-home.md"
# two home
line two
line three
line four
HEREDOC
    "${_NB}" notebooks add example
    cat <<HEREDOC | "${_NB}" example:add "first-example.md"
# one example
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" example:add "second-example.md"
# two example
line two
line three
line four
HEREDOC
  }

  run "${_NB}" ls example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${#lines[@]}" -eq 8           ]]
  [[ "${lines[3]}" =~ one\ example  ]]
  [[ "${lines[3]}" =~ [*1*]         ]]
}

@test "\`ls <notebook>:\` (with colon) exits with 0 and runs ls in the notebook." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first-home.md"
# one home
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "second-home.md"
# two home
line two
line three
line four
HEREDOC
    "${_NB}" notebooks add example
    cat <<HEREDOC | "${_NB}" example:add "first-example.md"
# one example
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" example:add "second-example.md"
# two example
line two
line three
line four
HEREDOC
  }

  run "${_NB}" ls example:

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${#lines[@]}" -eq 8           ]]
  [[ "${lines[3]}" =~ one\ example  ]]
  [[ "${lines[3]}" =~ [*1*]         ]]
}

@test "\`ls <notebook> --sort\` exits with 0 and runs ls in the notebook." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first-home.md"
# one home
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" add "second-home.md"
# two home
line two
line three
line four
HEREDOC
    "${_NB}" notebooks add example
    cat <<HEREDOC | "${_NB}" example:add "first-example.md"
# one example
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NB}" example:add "second-example.md"
# two example
line two
line three
line four
HEREDOC
  }

  run "${_NB}" ls example --sort

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${#lines[@]}" -eq 2           ]]
  [[ "${lines[0]}" =~ one\ example  ]]
  [[ "${lines[0]}" =~ [*1*]         ]]
}

# footer ######################################################################

@test "\`ls\` includes footer." {
  {
    _setup_ls
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

  [[ ${status} -eq 0    ]]
  [[ "${lines[6]}" =~ ❯ ]]
}

@test "\`NB_FOOTER=0 ls\` does not include footer." {
  {
    _setup_ls
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  NB_FOOTER=0 run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

  [[ ${status} -eq 0      ]]
  [[ ! "${lines[6]}" =~ ❯ ]]
}

# header ######################################################################

@test "\`ls\` includes header." {
  {
    _setup_ls
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

  [[ ${status} -eq 0        ]]
  [[ "${lines[0]}" =~ home  ]]
}

@test "\`NB_HEADER=0 ls\` does not include header." {
  {
    _setup_ls
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  NB_HEADER=0 run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

  [[ ${status} -eq 0          ]]
  [[ ! "${lines[0]}" =~ home  ]]
}
