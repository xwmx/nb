#!/usr/bin/env bats

load test_helper

_setup_rename() {
  run "${_NOTES}" init
  run "${_NOTES}" add
}

# no argument #################################################################

@test "\`rename\` with no arguments exits with 1, does nothing, and prints help." {
  _setup_rename
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" rename
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 1
  [[ ${status} -eq 1 ]]

  # Does not rename note file
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  # Does not create git commit
  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ ! $(git log | grep '\[NOTES\] Rename') ]]

  # Prints help
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" =~ "  notes rename" ]]
}

# <filename> ##################################################################

@test "\`rename\` with <filename> argument renames without errors." {
  {
    _setup_rename
    _filename=$("${_NOTES}" list -n 1 --no-id | head -1)
    echo "\${_filename:-}: ${_filename:-}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" rename "${_filename}" "EXAMPLE.org"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${NOTES_DATA_DIR}/${_filename}" ]]
  [[ -e "${NOTES_DATA_DIR}/EXAMPLE.org" ]]

  # Creates git commit
  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Rename') ]]

  # Updates index
  [[ "$("${_NOTES}" index get_id 'EXAMPLE.org')" == '1' ]]

  # Prints output
  [[ "${output}" =~ [A-Za-z0-9]+.md\ renamed\ to\ EXAMPLE.org ]]
}


@test "\`rename\` with existing <filename> exits with status 1." {
  {
    _setup_rename
    run "${_NOTES}" add "EXAMPLE.org"
    _filename=$("${_NOTES}" list -n 1 --no-id | head -1)
    echo "\${_filename:-}: ${_filename:-}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" rename "${_filename}" "EXAMPLE.org"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" =~ 'File already exists' ]]
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]
}

# <filename> --reset ##########################################################

@test "\`rename --reset\` with <filename> argument renames without errors." {
  {
    _setup_rename
    _original=$("${_NOTES}" list -n 1 --no-id | head -1)
    _filename="test.md"
    "${_NOTES}" rename "${_original}" "${_filename}"
    echo "\${_filename:-}: ${_filename:-}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" rename "${_filename}" --reset
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

# Returns status 0
  [[ ${status} -eq 0 ]]

  # Renames note file
  [[ ! -e "${NOTES_DATA_DIR}/${_filename}" ]]
  _files=($(ls "${NOTES_DATA_DIR}/"))
  [[ "${_files[0]}" =~ [A-Za-z0-9]+.md ]]
  printf "\${_files[0]}: '%s'\\n" "${_files[0]}"

  # Creates git commit
  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Rename') ]]

  # Updates index
  cat "${NOTES_DATA_DIR}/.index"
  "${_NOTES}" index get_id "${_files[0]}"
  [[ "$("${_NOTES}" index get_id "${_files[0]}")" == '1' ]]

  # Prints output
  [[ "${output}" =~ test.md\ renamed\ to\ [A-Za-z0-9]+.md ]]
}

# help ########################################################################

@test "\`help rename\` exits with status 0." {
  run "${_NOTES}" help rename
  [[ ${status} -eq 0 ]]
}

@test "\`help rename\` prints help information." {
  run "${_NOTES}" help rename
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes rename (<id> | <filename> | <path> | <title>) (<name> | --reset)" ]]
}
