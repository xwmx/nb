#!/usr/bin/env bats

load test_helper

_setup_rename() {
  run "${_NOTES}" init
  run "${_NOTES}" add
}

# no argument #################################################################

@test "\`rename\` with no arguments exits with status 1." {
  _setup_rename

  run "${_NOTES}" rename
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
}

@test "\`rename\` with no arguments does not rename note file." {
  _setup_rename
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" rename
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]
}

@test "\`rename\` with no arguments does not create git commit." {
  _setup_rename

  run "${_NOTES}" rename

  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ ! $(git log | grep '\[NOTES\] Rename') ]]
}

@test "\`rename\` with no argument prints help information." {
  _setup_rename

  run "${_NOTES}" rename
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" =~ "  notes rename" ]]
}

# <filename> ##################################################################

@test "\`rename\` with <filename> argument exits with status 0." {
  {
    _setup_rename
    _filename=$("${_NOTES}" list -n 1 --no-id | head -1)
    echo "\${_filename:-}: ${_filename:-}"
  }

  run "${_NOTES}" rename "${_filename}" "EXAMPLE.org"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
}

@test "\`rename\` with <filename> argument renames note file." {
  {
    _setup_rename
    _filename=$("${_NOTES}" list -n 1 --no-id | head -1)
    echo "\${_filename:-}: ${_filename:-}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" rename "${_filename}" "EXAMPLE.org"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ! -e "${NOTES_DATA_DIR}/${_filename}"  ]]
  [[ -e "${NOTES_DATA_DIR}/EXAMPLE.org"    ]]
}

@test "\`rename\` with <filename> argument creates git commit." {
  {
    _setup_rename
    _filename=$("${_NOTES}" list -n 1 --no-id | head -1)
    echo "\${_filename:-}: ${_filename:-}"
  }

  run "${_NOTES}" rename "${_filename}" "EXAMPLE.org"

  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Rename') ]]
}

@test "\`rename\` with <filename> argument updates index." {
  {
    _setup_rename
    _filename=$("${_NOTES}" list -n 1 --no-id | head -1)
    echo "\${_filename:-}: ${_filename:-}"
  }

  run "${_NOTES}" rename "${_filename}" "EXAMPLE.org"

  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ "$("${_NOTES}" index get_id 'EXAMPLE.org')" == '1' ]]
}

@test "\`rename\` with <filename> argument prints output." {
  {
    _setup_rename
    _filename=$("${_NOTES}" list -n 1 --no-id | head -1)
    echo "\${_filename:-}: ${_filename:-}"
  }
  [[ -e "${NOTES_DATA_DIR}/${_filename}" ]]

  run "${_NOTES}" rename "${_filename}" "EXAMPLE.org"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${output}" =~ [A-Za-z0-9]+.md\ renamed\ to\ EXAMPLE.org ]]
}

# <filename> --reset ##########################################################

@test "\`rename --reset\` with <filename> argument exits with status 0." {
  {
    _setup_rename
    _original=$("${_NOTES}" list -n 1 --no-id | head -1)
    _filename="test.md"
    "${_NOTES}" rename "${_original}" "${_filename}"
    echo "\${_filename:-}: ${_filename:-}"
  }

  run "${_NOTES}" rename "${_filename}" --reset
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
}

@test "\`rename --reset\` with <filename> argument renames note file." {
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
  [[ ! -e "${NOTES_DATA_DIR}/${_filename}"  ]]
  [[ $("${_NOTES}" list -n 1 --no-id | head -1) =~  [A-Za-z0-9]+.md ]]
}

@test "\`rename --reset\` with <filename> argument creates git commit." {
  {
    _setup_rename
    _original=$("${_NOTES}" list -n 1 --no-id | head -1)
    _filename="test.md"
    "${_NOTES}" rename "${_original}" "${_filename}"
    echo "\${_filename:-}: ${_filename:-}"
  }

  run "${_NOTES}" rename "${_filename}" --reset

  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Rename') ]]
}

@test "\`rename --reset\` with <filename> argument updates index." {
  {
    _setup_rename
    _filename=$("${_NOTES}" list -n 1 --no-id | head -1)
    echo "\${_filename:-}: ${_filename:-}"
  }

  run "${_NOTES}" rename "${_filename}" "EXAMPLE.org"

  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ "$(ls "${NOTES_DATA_DIR}")" == "$(cat "${NOTES_DATA_DIR}/.index")" ]]
}

@test "\`rename --reset\` with <filename> argument prints output." {
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
