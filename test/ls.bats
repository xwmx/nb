#!/usr/bin/env bats

load test_helper


_setup_ls() {
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
}

# `notes ls` ################################################################

@test "\`ls\` exits with 0 and lists files." {
  {
    _setup_ls
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "${_NOTES}" ls
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

  [[ "${lines[1]}" =~ ----    ]]
  [[ "${lines[2]}" =~ three   ]]
  [[ "${lines[3]}" =~ two     ]]
  [[ "${lines[4]}" =~ one     ]]
}

# `notes ls -e [<excerpt length>]` ############################################

@test "\`ls -e <excerpt length>\` exits with 0 and displays excerpts." {
  {
    _setup_ls
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "${_NOTES}" ls -e 5
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 18 ]]
}

# `notes ls -n <number>` ######################################################

@test "\`ls -n 0\` exits with 0 and lists 0 files." {
  {
    _setup_ls
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "${_NOTES}" ls -n 0
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${#lines[@]}" -eq 1 ]]

  [[ "${lines[0]}" == "3 omitted. 3 total." ]]
}

@test "\`ls -n 1\` exits with 0 and lists 1 file." {
  {
    _setup_ls
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "${_NOTES}" ls -n 1
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

  [[ "${#lines[@]}" -eq 2 ]]

  [[ "${lines[0]}" =~ three ]]
  [[ "${lines[1]}" == "2 omitted. 3 total." ]]
}

@test "\`ls -n 2\` exits with 0 and lists 2 files." {
  {
    _setup_ls
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "${_NOTES}" ls -n 2
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

  [[ "${#lines[@]}" -eq 3 ]]

  [[ "${lines[0]}" =~ three ]]
  [[ "${lines[1]}" =~ two   ]]
  [[ "${lines[2]}" == "1 omitted. 3 total." ]]
}

@test "\`ls -n 3\` exits with 0 and lists 3 files." {
  {
    _setup_ls
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "${_NOTES}" ls -n 3
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${lines[0]}" "three"

  [[ "${#lines[@]}" -eq 3 ]]

  [[ "${lines[0]}" =~ three ]]
  [[ "${lines[1]}" =~ two   ]]
  [[ "${lines[2]}" =~ one   ]]
}
