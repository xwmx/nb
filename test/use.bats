#!/usr/bin/env bats

load test_helper

_setup_use() {
  "${_NOTES}" init
  mkdir -p "${NOTES_DIR}/one"
  cd "${NOTES_DIR}/one" || return 1
  git init
  mkdir -p "${NOTES_DIR}/two"
  cd "${NOTES_DIR}" || return 1
}

# `notes use <name>` #####################################################

@test "\`use\` exits with 1 and prints error message." {
  {
    _setup_use
  }

  run "${_NOTES}" use
  [[ ${status} -eq 1 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf ".current: %s\\n" "$(cat "${NOTES_DIR}/.current")"
  [[ "${lines[1]}" == "  notes use <notebook>" ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "home" ]]

  run "${_NOTES}" env
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'_NOTEBOOK_PATH=${NOTES_DIR}/home'" "'${lines[1]}'"

  [[ "${lines[2]}" == "_NOTEBOOK_PATH=${NOTES_DIR}/home" ]]
}

@test "\`use <invalid>\` exits with 1 and prints error message." {
  {
    _setup_use
  }

  run "${_NOTES}" use not-a-repo
  [[ ${status} -eq 1 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf ".current: %s\\n" "$(cat "${NOTES_DIR}/.current")"
  [[ "${lines[0]}" == "Not found: not-a-repo" ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "home" ]]

  run "${_NOTES}" env
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'_NOTEBOOK_PATH=${NOTES_DIR}/home'" "'${lines[2]}'"

  [[ "${lines[2]}" == "_NOTEBOOK_PATH=${NOTES_DIR}/home" ]]
}

@test "\`repo use <name>\` exits with 0 and sets <name> in .current." {
  {
    _setup_use
    _expected="Now using $(_highlight 'one')."
  }

  run "${_NOTES}" use one
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'${_expected}'" "'${output}'"

  [[ "${output}" == "${_expected}" ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "one" ]]

  run "${_NOTES}" env
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'_NOTEBOOK_PATH=${NOTES_DIR}/one'" "'${lines[2]}'"

  [[ "${lines[2]}" == "_NOTEBOOK_PATH=${NOTES_DIR}/one" ]]
}

# help ########################################################################

@test "\`help use\` exits with status 0." {
  run "${_NOTES}" help use
  [[ ${status} -eq 0 ]]
}

@test "\`help use\` prints help information." {
  run "${_NOTES}" help use
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${lines[0]}" =~ Usage ]]
  [[ "${lines[1]}" == "  notes use <notebook>" ]]
}
