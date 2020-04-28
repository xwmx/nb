#!/usr/bin/env bats

load test_helper

_setup_move() {
  run "${_NOTES}" init
  run "${_NOTES}" add
  run "${_NOTES}" notebooks add "destination"
}

# no argument #################################################################

@test "\`move\` with no arguments exits with status 1." {
  {
    _setup_move
    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" move --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # exits with 1
  [[ ${status} -eq 1 ]]

  # does not delete note file
  [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]

  # does not create git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ ! $(git log | grep '\[NOTES\] Delete') ]]

  # prints help
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" =~ notes\ move ]]
}

# <selector> ##################################################################

@test "\`move <selector> <notebook>\` with empty repo exits with 1 and prints help." {
  {
    run "${_NOTES}" init
  }

  run "${_NOTES}" move 0 "destination"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" =~ notes\ move ]]

}

@test "\`move <invalid> <notebook>\` exits with 1 and prints help." {
  {
    _setup_move
    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" move "invalid" "destination" --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" =~ notes\ move ]]
}

@test "\`move <selector> <invalid>\` exits with 1 and prints help." {
  {
    _setup_move
    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" move 0 "invalid" --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" =~ notes\ move ]]
}

@test "\`move <selector> <notebook> (no force)\` returns 0 and moves note." {
  skip "Determine how to test interactive prompt."
  {
    _setup_move
    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }
  [[ -e "${_NOTEBOOK_PATH}/${_filename}" ]]

  run "${_NOTES}" move "${_filename}" "destination"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}" ]]
}

# <scope>:<selector> ##########################################################

@test "\`move <scope>:<selector> <notebook>\` with <filename> argument moves note." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" notebooks add "one"
    run "${_NOTES}" use "one"
    run "${_NOTES}" add
    _filename=$("${_NOTES}" list -n 1 --no-id --filenames | head -1)
    echo "\${_filename:-}: ${_filename:-}"
    run "${_NOTES}" use "home"
  }
  [[ -n "${_filename}" ]]
  [[ -e "${NOTES_DIR}/one/${_filename}" ]]

  run "${_NOTES}" move one:"${_filename}" "home" --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${output}" =~ Moved\ to\ \[home:[A-Za-z0-9]*\]\ home:[A-Za-z0-9]+.md ]]
}

# <filename> ##################################################################

@test "\`move\` with <filename> argument successfully moves note." {
  {
    _setup_move
    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" move "${_filename}" "destination" --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # exits with status 0
  [[ ${status} -eq 0 ]]

  # moves note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  [[ -e "${NOTES_DIR}/destination/${_filename}" ]]

  # creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Delete') ]]

  # prints output
  [[ "${output}" =~ Moved\ to\ \[destination:[A-Za-z0-9]*\]\ destination:[A-Za-z0-9]+.md ]]
}

# <id> ########################################################################

@test "\`move\` with <id> argument successfully moves note." {
  {
    _setup_move
    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" move 1 "destination" --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # exits with status 0
  [[ ${status} -eq 0 ]]

  # moves note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  [[ -e "${NOTES_DIR}/destination/${_filename}" ]]

  # creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Delete') ]]

  # prints output
  [[ "${output}" =~ Moved\ to\ \[destination:[A-Za-z0-9]*\]\ destination:[A-Za-z0-9]+.md ]]
}

# <path> ######################################################################

@test "\`move\` with <path> argument successfully moves note." {
  {
    _setup_move
    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" move "${_NOTEBOOK_PATH}/${_filename}" "destination" --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # exits with status 0
  [[ ${status} -eq 0 ]]

  # moves note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  [[ -e "${NOTES_DIR}/destination/${_filename}" ]]

  # creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Delete') ]]

  # prints output
  [[ "${output}" =~ Moved\ to\ \[destination:[A-Za-z0-9]*\]\ destination:[A-Za-z0-9]+.md ]]
}

# <title> #####################################################################

@test "\`move\` with <title> argument successfully moves note." {
  {
    _setup_move
    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }
  _title="$(head -1 "${_NOTEBOOK_PATH}/${_filename}" | sed 's/^\# //')"

  run "${_NOTES}" move "${_title}" "destination" --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # exits with status 0
  [[ ${status} -eq 0 ]]

  # moves note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  [[ -e "${NOTES_DIR}/destination/${_filename}" ]]

  # creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Delete') ]]

  # prints output
  [[ "${output}" =~ Moved\ to\ \[destination:[A-Za-z0-9]*\]\ destination:[A-Za-z0-9]+.md ]]
}

# <folder> ####################################################################

@test "\`move\` with <folder> argument successfully moves note." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" notebooks add "destination"
    run "${_NOTES}" import "${BATS_TEST_DIRNAME}/fixtures/Example Folder"
    IFS= _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" move "${_filename}" "destination" --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # exits with status 0
  [[ ${status} -eq 0 ]]

  # moves note file
  [[ ! -e "${_NOTEBOOK_PATH}/${_filename}" ]]
  [[ -e "${NOTES_DIR}/destination/${_filename}" ]]

  # creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Delete') ]]

  # prints output
  [[ "${output}" =~ Moved\ to\ \[destination:[A-Za-z0-9]*\]\ destination:Example\ Folder ]]
}

# help ########################################################################

@test "\`help move\` exits with status 0." {
  run "${_NOTES}" help move
  [[ ${status} -eq 0 ]]
}

@test "\`help move\` prints help information." {
  run "${_NOTES}" help move
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" =~ notes\ move ]]
}
