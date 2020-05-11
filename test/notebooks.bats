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

# `notebooks` #################################################################

@test "\`notebooks\` exits with 0 and prints all notebook names." {
  {
    _setup_notebooks
    _expected="$(_highlight 'home' --underline)
one (${_GIT_REMOTE_URL})"
  }

  NOTES_HIGHLIGHT_COLOR=3 run "${_NOTES}" notebooks
  [[ ${status} -eq 0 ]]


  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_expected}: '%s'\\n" "${_expected}"

  [[ "${output}" == "${_expected}" ]]
}

@test "\`notebooks <name>\` exits with 0 and prints the given notebook." {
  {
    _setup_notebooks
  }

  run "${_NOTES}" notebooks one
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="one (${_GIT_REMOTE_URL})"
  [[ "${output}" == "${_expected}" ]]
}

@test "\`notebooks <name> --names\` exits with 0 and prints the given notebook name." {
  {
    _setup_notebooks
    _expected="$(_highlight 'home')"
  }

  run "${_NOTES}" notebooks home --names
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_expected}: '%s'\\n" "${_expected}"

  [[ "${output}" == "${_expected}" ]]
}

@test "\`notebooks --names\` exits with 0 and prints all notebook names." {
  {
    _setup_notebooks
    _expected="$(_highlight 'home' --underline)
one"
  }

  run "${_NOTES}" notebooks --names
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_expected}: '%s'\\n" "${_expected}"

  [[ "${output}" == "${_expected}" ]]
}

@test "\`notebooks --no-color\` exits with 0 and prints all notebook names with no highlighting." {
  {
    _setup_notebooks
  }

  run "${_NOTES}" notebooks --no-color
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="home
one (${_GIT_REMOTE_URL})"
  [[ "${output}" == "${_expected}" ]]
}

@test "\`notebooks <name> --no-color\` exits with 0 and prints the given notebook name with no highlighting." {
  {
    _setup_notebooks
  }

  run "${_NOTES}" notebooks home --no-color
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="home"
  [[ "${output}" == "${_expected}" ]]
}

@test "\`notebooks --names --no-color\` exits with 0 and prints all notebook names with no highlighting." {
  {
    _setup_notebooks
  }

  run "${_NOTES}" notebooks --names --no-color
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="home
one"
  [[ "${output}" == "${_expected}" ]]
}

@test "\`notebooks --names --no-color --archived\` exits with 0 and prints archived." {
  {
    _setup_notebooks
    run "${_NOTES}" one:notebook archive
  }

  run "${_NOTES}" notebooks --names --no-color --archived
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="one"
  [[ "${output}" == "${_expected}" ]]
}

@test "\`notebooks --names --no-color --unarchived\` exits with 0 and prints unarchived." {
  {
    _setup_notebooks
    run "${_NOTES}" one:notebook archive
  }

  run "${_NOTES}" notebooks --names --no-color --unarchived
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="home"
  [[ "${output}" == "${_expected}" ]]
}

@test "\`notebooks --names --no-color\` prints local and global." {
  {
    _setup_notebooks
    run "${_NOTES}" notebooks init "${_TMP_DIR}/example-local"
    cd "${_TMP_DIR}/example-local"
    [[ "$(pwd)" == "${_TMP_DIR}/example-local" ]]
  }

  run "${_NOTES}" notebooks --names --no-color
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="local
home
one"
  [[ "${output}" == "${_expected}" ]]
}

@test "\`notebooks --names --no-color --local\` exits with 0 and prints local." {
  {
    _setup_notebooks
    run "${_NOTES}" notebooks init "${_TMP_DIR}/example-local"
    cd "${_TMP_DIR}/example-local"
    [[ "$(pwd)" == "${_TMP_DIR}/example-local" ]]
  }

  run "${_NOTES}" notebooks --names --no-color --local

  printf "\${PWD}: %s\\n" "${PWD}"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]
  _expected="local"
  [[ "${output}" == "${_expected}" ]]
}

@test "\`notebooks --names --no-color --local\` with no local exits with 1." {
  {
    _setup_notebooks
    run "${_NOTES}" notebooks init "${_TMP_DIR}/example-local"
    cd "${_TMP_DIR}"
    [[ "$(pwd)" == "${_TMP_DIR}" ]]
  }

  run "${_NOTES}" notebooks --names --no-color --local
  [[ ${status} -eq 1 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ -z "${output}" ]]
}

@test "\`notebooks --names --no-color --global\` exits with 0 and prints global." {
  {
    _setup_notebooks
    run "${_NOTES}" notebooks init "${_TMP_DIR}/example-local"
  }

  run "${_NOTES}" notebooks --names --no-color --global
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="home
one"
  [[ "${output}" == "${_expected}" ]]
}

# `notebooks --paths` #########################################################

@test "\`notebooks --paths\` prints local and global." {
  {
    _setup_notebooks
    run "${_NOTES}" notebooks init "${_TMP_DIR}/example-local"
    cd "${_TMP_DIR}/example-local"
    [[ "$(pwd)" == "${_TMP_DIR}/example-local" ]]
  }

  run "${_NOTES}" notebooks --paths
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="${_TMP_DIR}/example-local
${NOTES_DIR}/home
${NOTES_DIR}/one"
  [[ "${output}" == "${_expected}" ]]
}

@test "\`notebooks --paths --local\` exits with 0 and prints local." {
  {
    _setup_notebooks
    run "${_NOTES}" notebooks init "${_TMP_DIR}/example-local"
    cd "${_TMP_DIR}/example-local"
    [[ "$(pwd)" == "${_TMP_DIR}/example-local" ]]
  }

  run "${_NOTES}" notebooks --paths --local

  printf "\${PWD}: %s\\n" "${PWD}"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]
  _expected="${_TMP_DIR}/example-local"
  [[ "${output}" == "${_expected}" ]]
}

@test "\`notebooks --paths --local\` with no local exits with 1." {
  {
    _setup_notebooks
    run "${_NOTES}" notebooks init "${_TMP_DIR}/example-local"
    cd "${_TMP_DIR}"
    [[ "$(pwd)" == "${_TMP_DIR}" ]]
  }

  run "${_NOTES}" notebooks --paths --local
  [[ ${status} -eq 1 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ -z "${output}" ]]
}

@test "\`notebooks --paths --global\` exits with 0 and prints global." {
  {
    _setup_notebooks
    run "${_NOTES}" notebooks init "${_TMP_DIR}/example-local"
  }

  run "${_NOTES}" notebooks --paths --global
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _expected="${NOTES_DIR}/home
${NOTES_DIR}/one"
  [[ "${output}" == "${_expected}" ]]
}

# help ########################################################################

@test "\`help notebooks\` exits with status 0." {
  run "${_NOTES}" help notebooks
  [[ ${status} -eq 0 ]]
}

@test "\`help notebooks\` prints help information." {
  run "${_NOTES}" help notebooks
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" =~ \ \ notes\ notebooks\ \[\<name\>\] ]]
}
