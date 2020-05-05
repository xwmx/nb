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

# `notes notebooks current` ###################################################

@test "\`notebooks current\` exits with 0 and prints the current notebook name." {
  {
    _setup_notebooks
    printf "%s\\n" "one" > "${NOTES_DIR}/.current"
  }

  run "${_NOTES}" notebooks current
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${output}" =~ one ]]
}

@test "\`notebooks current --path\` exits with 0 and prints the notebook path." {
  {
    _setup_notebooks
    printf "%s\\n" "one" > "${NOTES_DIR}/.current"
  }

  run "${_NOTES}" notebooks current --path
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${output}" =~ ${NOTES_DIR}/one ]]
}

@test "\`notebooks current\` exits with 0 and prints the local notebook." {
  {
    _setup_notebooks
    printf "%s\\n" "one" > "${NOTES_DIR}/.current"

    mkdir -p "${_TMP_DIR}/example"
    cd "${_TMP_DIR}/example"
    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]
    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"
  }

  run "${_NOTES}" notebooks current
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${output}" =~ local ]]
}

@test "\`notebooks current --path\` exits with 0 and prints the local notebook path." {
  {
    _setup_notebooks
    printf "%s\\n" "one" > "${NOTES_DIR}/.current"

    mkdir -p "${_TMP_DIR}/example"
    cd "${_TMP_DIR}/example"
    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]
    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"
  }

  run "${_NOTES}" notebooks current --path
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_TMP_DIR}: '%s'\\n" "${_TMP_DIR}"

  [[ "${output}" =~ ${_TMP_DIR}/example ]]
}

@test "\`notebooks current\` exits with 0 and prints the scoped notebook name." {
  {
    _setup_notebooks
    printf "%s\\n" "one" > "${NOTES_DIR}/.current"
  }

  run "${_NOTES}" home:notebooks current
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${output}" =~ home ]]
}

@test "\`notebooks current --path\` exits with 0 and prints the scoped notebook path." {
  {
    _setup_notebooks
    printf "%s\\n" "one" > "${NOTES_DIR}/.current"
  }

  run "${_NOTES}" home:notebooks current --path
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${output}" == "${NOTES_DIR}/home" ]]
}
