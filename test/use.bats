#!/usr/bin/env bats

load test_helper

_setup_use() {
  "${_NOTES}" init
  mkdir -p "${NOTES_DIR}/one"
  cd "${NOTES_DIR}/one"
  git init
  mkdir -p "${NOTES_DIR}/two"
  cd "${NOTES_DIR}"
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
  _compare "'NOTES_DATA_DIR=${NOTES_DIR}/home'" "'${lines[1]}'"

  [[ "${lines[1]}" == "NOTES_DATA_DIR=${NOTES_DIR}/home" ]]
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
  _compare "'NOTES_DATA_DIR=${NOTES_DIR}/home'" "'${lines[1]}'"

  [[ "${lines[1]}" == "NOTES_DATA_DIR=${NOTES_DIR}/home" ]]
}

@test "\`repo use <name>\` exits with 0 and sets <name> in .current." {
  {
    _setup_use
  }

  run "${_NOTES}" use one
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'Now using $(tput setaf 3)one$(tput sgr0).'" "'${output}'"

  [[ "${output}" == "Now using $(tput setaf 3)one$(tput sgr0)." ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "one" ]]

  run "${_NOTES}" env
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'NOTES_DATA_DIR=${NOTES_DIR}/one'" "'${lines[1]}'"

  [[ "${lines[1]}" == "NOTES_DATA_DIR=${NOTES_DIR}/one" ]]
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
