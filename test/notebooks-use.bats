#!/usr/bin/env bats

load test_helper

_setup_notebooks() {
  "${_NOTES}" init
  mkdir -p "${NOTES_DIR}/one"
  cd "${NOTES_DIR}/one" || return 1
  git init
  git remote add origin "${_GIT_REMOTE_URL}"
  touch "${NOTES_DIR}/one/.index"
  mkdir -p "${NOTES_DIR}/two"
  cd "${NOTES_DIR}" || return 1
}

# `notes notebooks use <name>` ################################################

@test "\`notebooks use\` exits with 1 and prints error message." {
  {
    _setup_notebooks
  }

  run "${_NOTES}" notebooks use
  [[ ${status} -eq 1 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf ".current: %s\\n" "$(cat "${NOTES_DIR}/.current")"
  [[ "${lines[1]}" =~ \ \ notes\ notebooks\ \[\<name\>\] ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "home" ]]

  run "${_NOTES}" env
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'_NOTEBOOK_PATH=${NOTES_DIR}/home'" "'${lines[2]}'"

  [[ "${lines[2]}" == "_NOTEBOOK_PATH=${NOTES_DIR}/home" ]]
}

@test "\`notebooks use <invalid>\` exits with 1 and prints error message." {
  {
    _setup_notebooks
  }

  run "${_NOTES}" notebooks use not-a-notebook
  [[ ${status} -eq 1 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf ".current: %s\\n" "$(cat "${NOTES_DIR}/.current")"
  [[ "${lines[0]}" == "Not found: not-a-notebook" ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "home" ]]

  run "${_NOTES}" env
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'_NOTEBOOK_PATH=${NOTES_DIR}/home'" "'${lines[2]}'"

  [[ "${lines[2]}" == "_NOTEBOOK_PATH=${NOTES_DIR}/home" ]]
}

@test "\`notebooks use <name>\` exits with 0 and sets <name> in .current." {
  {
    _setup_notebooks
  }

  run "${_NOTES}" notebooks use one
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'Now using $(_highlight 'one').'" "'${output}'"

  [[ "${output}" == "Now using $(_highlight 'one')." ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "one" ]]

  run "${_NOTES}" env
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'_NOTEBOOK_PATH=${NOTES_DIR}/one'" "'${lines[2]}'"

  [[ "${lines[2]}" == "_NOTEBOOK_PATH=${NOTES_DIR}/one" ]]
}

@test "\`notebooks use <name>:\` exits with 0 and sets <name> in .current." {
  {
    _setup_notebooks
  }

  run "${_NOTES}" notebooks use one:
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'Now using $(_highlight 'one').'" "'${output}'"

  [[ "${output}" == "Now using $(_highlight 'one')." ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "one" ]]

  run "${_NOTES}" env
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'_NOTEBOOK_PATH=${NOTES_DIR}/one'" "'${lines[2]}'"

  [[ "${lines[2]}" == "_NOTEBOOK_PATH=${NOTES_DIR}/one" ]]
}

@test "\`notebooks use\` in local exits with 1 and prints error message." {
  {
    _setup_notebooks

    mkdir -p "${_TMP_DIR}/example"
    cd "${_TMP_DIR}/example"
    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]
    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"

  }

  run "${_NOTES}" notebooks use one
  [[ ${status} -eq 1 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf ".current: %s\\n" "$(cat "${NOTES_DIR}/.current")"
  [[ "${lines[0]}" =~ in\ a\ local\ notebook ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "home" ]]

  run "${_NOTES}" env
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'_NOTEBOOK_PATH=${_TMP_DIR}/example'" "'${lines[2]}'"
  [[ "$(cat "${NOTES_DIR}/.current")" == "home" ]]

  [[ "${lines[2]}" == "_NOTEBOOK_PATH=${_TMP_DIR}/example" ]]
}
