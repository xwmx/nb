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

  printf "\${status}: %s\\n" "${status}"
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

  printf "\${status}: %s\\n" "${status}"
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

  printf "\${status}: %s\\n" "${status}"
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

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0        ]]
  [[ "${#lines[@]}" -eq 21  ]]
}

# `ls -n <number>` ############################################################

@test "\`ls -n 0\` exits with 0 and lists 0 files." {
  {
    _setup_ls
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" ls -n 0

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                        ]]
  [[ "${#lines[@]}" -eq 6                   ]]
  [[ "${lines[2]}" == "3 omitted. 3 total." ]]
}

@test "\`ls -n 1\` exits with 0 and lists 1 file." {
  {
    _setup_ls
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" ls -n 1

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

  [[ ${status} -eq 0                        ]]
  [[ "${#lines[@]}" -eq 7                   ]]
  [[ "${lines[2]}" =~ three                 ]]
  [[ "${lines[3]}" == "2 omitted. 3 total." ]]
}

@test "\`ls -n 2\` exits with 0 and lists 2 files." {
  {
    _setup_ls
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" ls -n 2

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

  [[ ${status} -eq 0                        ]]
  [[ "${#lines[@]}" -eq 8                   ]]
  [[ "${lines[2]}" =~ three                 ]]
  [[ "${lines[3]}" =~ two                   ]]
  [[ "${lines[4]}" == "1 omitted. 3 total." ]]
}

@test "\`ls -n 3\` exits with 0 and lists 3 files." {
  {
    _setup_ls
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" ls -n 3

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  _compare "${lines[0]}" "three"

  [[ ${status} -eq 0        ]]
  [[ "${#lines[@]}" -eq 8   ]]
  [[ "${lines[2]}" =~ three ]]
  [[ "${lines[3]}" =~ two   ]]
  [[ "${lines[4]}" =~ one   ]]
}

# `ls <selection>` ############################################################

@test "\`ls <selection>\` exits with 0 and displays the selection." {
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

  run "${_NB}" ls 1 --filenames

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${#lines[@]}" -eq 4           ]]
  [[ "${lines[0]}" =~ first.md      ]]
  [[ "${lines[0]}" =~ [*1*]         ]]
  [[ "${lines[0]}" =~ ${_files[0]}  ]]
}

@test "\`ls <query selection>\` exits with 0 and displays the selections." {
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

  run "${_NB}" ls 'r' --filenames

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${#lines[@]}" -eq 5           ]]
  [[ "${lines[0]}" =~ third.md      ]]
  [[ "${lines[0]}" =~ [*3*]         ]]
  [[ "${lines[0]}" =~ ${_files[2]}  ]]
  [[ "${lines[1]}" =~ first.md      ]]
  [[ "${lines[1]}" =~ [*1*]         ]]
  [[ "${lines[1]}" =~ ${_files[0]}  ]]
}

@test "\`ls <invalid-selection>\` exits with 1 and displays a message." {
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

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 1                      ]]
  [[ "${#lines[@]}" -eq 1                 ]]
  [[ "${lines[0]}" =~ Note\ not\ found\:  ]]
  [[ "${lines[0]}" =~ not-valid           ]]
}

# footer ######################################################################

@test "\`ls\` includes footer." {
  {
    _setup_ls
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" ls

  printf "\${status}: %s\\n" "${status}"
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


  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

  [[ ${status} -eq 0      ]]
  [[ ! "${lines[6]}" =~ ❯ ]]
}
