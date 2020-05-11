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
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

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
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

  [[ "${lines[0]}" =~ home                 ]]
  [[ "${lines[0]}" =~ .\ \[1\ archived\]   ]]
  [[ "${lines[1]}" =~ -------------------  ]]
  [[ "${lines[2]}" =~ three   ]]
  [[ "${lines[3]}" =~ two     ]]
  [[ "${lines[4]}" =~ one     ]]
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
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

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
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 21 ]]
}

# `ls -n <number>` ############################################################

@test "\`ls -n 0\` exits with 0 and lists 0 files." {
  {
    _setup_ls
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" ls -n 0
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${#lines[@]}" -eq 6 ]]

  [[ "${lines[2]}" == "3 omitted. 3 total." ]]
}

@test "\`ls -n 1\` exits with 0 and lists 1 file." {
  {
    _setup_ls
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" ls -n 1
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

  [[ "${#lines[@]}" -eq 7 ]]

  [[ "${lines[2]}" =~ three ]]
  [[ "${lines[3]}" == "2 omitted. 3 total." ]]
}

@test "\`ls -n 2\` exits with 0 and lists 2 files." {
  {
    _setup_ls
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" ls -n 2
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

  [[ "${#lines[@]}" -eq 8 ]]

  [[ "${lines[2]}" =~ three ]]
  [[ "${lines[3]}" =~ two   ]]
  [[ "${lines[4]}" == "1 omitted. 3 total." ]]
}

@test "\`ls -n 3\` exits with 0 and lists 3 files." {
  {
    _setup_ls
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" ls -n 3
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"
  _compare "${lines[0]}" "three"

  [[ "${#lines[@]}" -eq 8 ]]

  [[ "${lines[2]}" =~ three ]]
  [[ "${lines[3]}" =~ two   ]]
  [[ "${lines[4]}" =~ one   ]]
}
