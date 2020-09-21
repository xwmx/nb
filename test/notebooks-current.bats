#!/usr/bin/env bats

load test_helper

_setup_notebooks() {
  run "${_NB}" init
  mkdir -p "${NB_DIR}/one"
  cd "${NB_DIR}/one" || return 1
  git init
  git remote add origin "${_GIT_REMOTE_URL}"
  touch "${NB_DIR}/one/.index"
  mkdir -p "${NB_DIR}/two"
  cd "${NB_DIR}" || return 1
}

# `notebooks current` #########################################################

@test "\`notebooks current\` exits with 0 and prints the current notebook name." {
  {
    _setup_notebooks
    printf "%s\\n" "one" > "${NB_DIR}/.current"
  }

  run "${_NB}" notebooks current

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0    ]]
  [[ "${output}" =~ one ]]
}

@test "\`notebooks current --path\` exits with 0 and prints the notebook path." {
  {
    _setup_notebooks
    printf "%s\\n" "one" > "${NB_DIR}/.current"
  }

  run "${_NB}" notebooks current --path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0              ]]
  [[ "${output}" =~ ${NB_DIR}/one ]]
}

@test "\`notebooks current\` exits with 0 and prints the local notebook." {
  {
    _setup_notebooks

    printf "%s\\n" "one" > "${NB_DIR}/.current"

    mkdir -p "${_TMP_DIR}/example"

    cd "${_TMP_DIR}/example"

    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]

    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"
  }

  run "${_NB}" notebooks current

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0      ]]
  [[ "${output}" =~ local ]]
}

@test "\`notebooks current --path\` exits with 0 and prints the local notebook path." {
  {
    _setup_notebooks

    printf "%s\\n" "one" > "${NB_DIR}/.current"

    mkdir -p "${_TMP_DIR}/example"

    cd "${_TMP_DIR}/example"

    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]

    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"
  }

  run "${_NB}" notebooks current --path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_TMP_DIR}: '%s'\\n" "${_TMP_DIR}"

  [[ ${status} -eq 0                    ]]
  [[ "${output}" =~ ${_TMP_DIR}/example ]]
}

@test "\`notebooks current\` exits with 0 and prints the scoped notebook name." {
  {
    _setup_notebooks

    printf "%s\\n" "one" > "${NB_DIR}/.current"
  }

  run "${_NB}" home:notebooks current

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0      ]]
  [[ "${output}" =~ home  ]]
}

@test "\`notebooks current --path\` exits with 0 and prints the scoped notebook path." {
  {
    _setup_notebooks

    printf "%s\\n" "one" > "${NB_DIR}/.current"
  }

  run "${_NB}" home:notebooks current --path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                  ]]
  [[ "${output}" == "${NB_DIR}/home"  ]]
}

# --selected ####################################################################

@test "\`notebooks current --selected\` exits with 1 when unscoped." {
  {
    _setup_notebooks
    printf "%s\\n" "one" > "${NB_DIR}/.current"
  }

  run "${_NB}" notebooks current --selected

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1  ]]
  # TODO: This test fails. Review.
  # [[ -z "${output}"   ]]
}

@test "\`notebooks current --selected\` exits with 0 when scoped." {
  {
    _setup_notebooks
    printf "%s\\n" "one" > "${NB_DIR}/.current"
  }

  run "${_NB}" home:notebooks current --selected

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0  ]]
  [[ -z "${output}"   ]]

}

# --global ####################################################################

@test "\`notebooks current --global\` exits with 0 and prints the current global notebook name." {
  {
    _setup_notebooks
    printf "%s\\n" "one" > "${NB_DIR}/.current"
  }

  run "${_NB}" notebooks current --global

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0    ]]
  [[ "${output}" =~ one ]]
}

@test "\`notebooks current --global --path\` exits with 0 and prints the notebook path." {
  {
    _setup_notebooks
    printf "%s\\n" "one" > "${NB_DIR}/.current"
  }

  run "${_NB}" notebooks current --global --path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0              ]]
  [[ "${output}" =~ ${NB_DIR}/one ]]
}

@test "\`notebooks current --global\` in a local notebook exits with 0 and prints the global notebook." {
  {
    _setup_notebooks

    printf "%s\\n" "one" > "${NB_DIR}/.current"

    mkdir -p "${_TMP_DIR}/example"

    cd "${_TMP_DIR}/example"

    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]

    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"
  }

  run "${_NB}" notebooks current --global

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0    ]]
  [[ "${output}" =~ one ]]
}

@test "\`notebooks current --global --path\` in a local notebook exits with 0 and prints the local notebook path." {
  {
    _setup_notebooks

    printf "%s\\n" "one" > "${NB_DIR}/.current"

    mkdir -p "${_TMP_DIR}/example"

    cd "${_TMP_DIR}/example"

    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]

    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"
  }

  run "${_NB}" notebooks current --global --path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_TMP_DIR}: '%s'\\n" "${_TMP_DIR}"

  [[ ${status} -eq 0              ]]
  [[ "${output}" =~ ${NB_DIR}/one ]]
}

@test "\`notebooks current --global\` with selected exits with 0 and prints the global notebook name." {
  {
    _setup_notebooks

    printf "%s\\n" "one" > "${NB_DIR}/.current"
  }

  run "${_NB}" home:notebooks current --global

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0    ]]
  [[ "${output}" =~ one ]]
}

@test "\`notebooks current --global --path\` with selected exits with 0 and prints the scoped notebook path." {
  {
    _setup_notebooks

    printf "%s\\n" "one" > "${NB_DIR}/.current"
  }

  run "${_NB}" home:notebooks current --global --path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0              ]]
  [[ "${output}" =~ ${NB_DIR}/one ]]

}
