#!/usr/bin/env bats

load test_helper

_setup_use() {
  "${_NB}" init
  mkdir -p "${NB_DIR}/one"
  cd "${NB_DIR}/one" || return 1
  git init
  mkdir -p "${NB_DIR}/two"
  cd "${NB_DIR}" || return 1
}

# `use <name>` ################################################################

@test "\`use\` exits with 1 and prints error message." {
  {
    _setup_use
  }

  run "${_NB}" use

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf ".current: %s\\n" "$(cat "${NB_DIR}/.current")"

  [[ ${status} -eq 1                          ]]
  [[ "${lines[1]}" == "  nb use <notebook>"   ]]
  [[ "$(cat "${NB_DIR}/.current")" == "home"  ]]

  run "${_NB}" env

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'NB_NOTEBOOK_PATH=${NB_DIR}/home'" "'${lines[1]}'"

  [[ "${lines[2]}" == "NB_NOTEBOOK_PATH=${NB_DIR}/home" ]]
}

@test "\`use <invalid>\` exits with 1 and prints error message." {
  {
    _setup_use
  }

  run "${_NB}" use not-a-repo

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf ".current: %s\\n" "$(cat "${NB_DIR}/.current")"

  [[ ${status} -eq 1                                                                ]]
  [[ "${lines[0]}" == "${_ERROR_PREFIX} Not found: $(_color_primary "not-a-repo")"  ]]
  [[ "$(cat "${NB_DIR}/.current")" == "home"                                        ]]

  run "${_NB}" env

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'NB_NOTEBOOK_PATH=${NB_DIR}/home'" "'${lines[2]}'"

  [[ "${lines[2]}" == "NB_NOTEBOOK_PATH=${NB_DIR}/home" ]]
}

@test "\`repo use <name>\` exits with 0 and sets <name> in .current." {
  {
    _setup_use
    _expected="Now using: $(_color_primary 'one')"
  }

  run "${_NB}" use one

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'${_expected}'" "'${output}'"

  [[ ${status} -eq 0                        ]]
  [[ "${output}" == "${_expected}"          ]]
  [[ "$(cat "${NB_DIR}/.current")" == "one" ]]

  run "${_NB}" env
  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'NB_NOTEBOOK_PATH=${NB_DIR}/one'" "'${lines[2]}'"

  [[ "${lines[2]}" == "NB_NOTEBOOK_PATH=${NB_DIR}/one" ]]
}

# help ########################################################################

@test "\`help use\` exits with status 0." {
  run "${_NB}" help use

  [[ ${status} -eq 0 ]]
}

@test "\`help use\` prints help information." {
  run "${_NB}" help use

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Usage                 ]]
  [[ "${lines[1]}" == "  nb use <notebook>" ]]
}
