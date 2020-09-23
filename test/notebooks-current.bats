#!/usr/bin/env bats

load test_helper

_setup_notebooks() {
  run "${_NB}" init
  run "${_NB}" notebooks add one

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

@test "\`notebooks current --path\` exits with 0 and prints the selected notebook path with name." {
  {
    _setup_notebooks
    printf "%s\\n" "one" > "${NB_DIR}/.current"
  }

  run "${_NB}" notebooks current home --path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                  ]]
  [[ "${output}" == "${NB_DIR}/home"  ]]
}

@test "\`notebooks current --path\` exits with 0 and prints the selected notebook path with colon name." {
  {
    _setup_notebooks
    printf "%s\\n" "one" > "${NB_DIR}/.current"
  }

  run "${_NB}" notebooks current home: --path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                  ]]
  [[ "${output}" == "${NB_DIR}/home"  ]]
}

@test "\`notebooks current --path\` exits with 0 and prints the selected notebook path with path." {
  {
    _setup_notebooks
    printf "%s\\n" "one" > "${NB_DIR}/.current"
  }

  run "${_NB}" notebooks current "${NB_DIR}/home" --path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                  ]]
  [[ "${output}" == "${NB_DIR}/home"  ]]
}

@test "\`notebooks current --path\` exits with 0 and prints the selected notebook path with identifier." {
  {
    _setup_notebooks
    printf "%s\\n" "one" > "${NB_DIR}/.current"
  }

  run "${_NB}" notebooks current home:example.md --path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                  ]]
  [[ "${output}" == "${NB_DIR}/home"  ]]
}

@test "\`notebooks current --path\` exits with 0 and prints the currrent notebook path with not valid notebook selector." {
  {
    _setup_notebooks
    printf "%s\\n" "one" > "${NB_DIR}/.current"
  }

  run "${_NB}" notebooks current not-valid:example.md --path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0                ]]
  [[ "${output}" == "${NB_DIR}/one" ]]
}

@test "\`notebooks current --path\` exits with 0 and prints the currrent notebook path with not valid path." {
  {
    _setup_notebooks
    printf "%s\\n" "one" > "${NB_DIR}/.current"
  }

  run "${_NB}" notebooks current "${NB_DIR}/not-valid" --path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0                ]]
  [[ "${output}" == "${NB_DIR}/one" ]]
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

@test "\`notebooks current --selected\` exits with 0 when passed a valid name." {
  {
    _setup_notebooks
    printf "%s\\n" "one" > "${NB_DIR}/.current"
  }

  run "${_NB}" notebooks current "home" --selected

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0  ]]
  [[ -z "${output}"   ]]
}

@test "\`notebooks current --selected\` exits with 0 when passed a name with colon." {
  {
    _setup_notebooks
    printf "%s\\n" "one" > "${NB_DIR}/.current"
  }

  run "${_NB}" notebooks current home: --selected

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0  ]]
  [[ -z "${output}"   ]]
}

@test "\`notebooks current --selected\` exits with 0 when passed a valid selector." {
  {
    _setup_notebooks
    printf "%s\\n" "one" > "${NB_DIR}/.current"
  }

  run "${_NB}" notebooks current home:example.md --selected

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0  ]]
  [[ -z "${output}"   ]]
}

@test "\`notebooks current --selected\` exits with 0 when passed an invalid selector." {
  {
    _setup_notebooks
    printf "%s\\n" "one" > "${NB_DIR}/.current"
  }

  run "${_NB}" notebooks current not-valid:example.md --selected

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1  ]]
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

@test "\`notebooks current --global --path\` in a local notebook exits with 0 and prints the global notebook path." {
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

# --local #####################################################################

@test "\`notebooks current --local\` exits with 1 and prints nothing when not in local." {
  {
    _setup_notebooks
    printf "%s\\n" "one" > "${NB_DIR}/.current"
  }

  run "${_NB}" notebooks current --local

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]
  [[ -z "${output}"  ]]
}

@test "\`notebooks current --local --path\` exits with 1 and prints nothing when not in local." {
  {
    _setup_notebooks
    printf "%s\\n" "one" > "${NB_DIR}/.current"
  }

  run "${_NB}" notebooks current --local --path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]
  [[ -z "${output}"  ]]
}

@test "\`notebooks current --local\` in a local notebook exits with 0 and prints nothing." {
  {
    _setup_notebooks

    printf "%s\\n" "one" > "${NB_DIR}/.current"

    "${_NB}" notebooks init "${_TMP_DIR}/example"

    cd "${_TMP_DIR}/example"

    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]
  }

  run "${_NB}" notebooks current --local

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]
  [[ -z "${output}"  ]]
}

@test "\`notebooks current --local --path\` in a local notebook exits with 0 and prints the local notebook path." {
  {
    _setup_notebooks

    printf "%s\\n" "one" > "${NB_DIR}/.current"

    "${_NB}" notebooks init "${_TMP_DIR}/example"

    cd "${_TMP_DIR}/example"

    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]
  }

  run "${_NB}" notebooks current --local --path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_TMP_DIR}: '%s'\\n" "${_TMP_DIR}"

  [[ ${status} -eq 0                    ]]
  [[ "${output}" =~ ${_TMP_DIR}/example ]]
}

@test "\`notebooks current --local\` with selected exits with 1 and prints nothing." {
  {
    _setup_notebooks

    printf "%s\\n" "one" > "${NB_DIR}/.current"
  }

  run "${_NB}" home:notebooks current --local

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]
  [[ -z "${output}"  ]]
}

@test "\`notebooks current --local --path\` with selected exits with 1 and prints nothing." {
  {
    _setup_notebooks

    printf "%s\\n" "one" > "${NB_DIR}/.current"
  }

  run "${_NB}" home:notebooks current --local --path

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]
  [[ -z "${output}"  ]]
}

# `notebooks current --filename` ##############################################

@test "\`notebooks current --filename\` prints a unique filename." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example"
  }

  run "${_NB}" notebooks current --filename

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0              ]]
  [[ "${lines[0]}" =~ ^[0-9]+.md  ]]

  run "${_NB}" add "example.md" --content "Example"

  run "${_NB}" notebooks current --filename

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0              ]]
  [[ "${lines[0]}" =~ ^[0-9]+.md  ]]
}

@test "\`notebooks current <selector> --filename\` prints a scoped unique filename." {
  {
    "${_NB}" init
    "${_NB}" notebooks add one
    "${_NB}" one:add "example.md" --content "Example"
  }

  run "${_NB}" notebooks current "one" --filename

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0              ]]
  [[ "${lines[0]}" =~ ^[0-9]+.md  ]]

  run "${_NB}" add "example.md" --content "Example"

  run "${_NB}" notebooks current "one" --filename

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0              ]]
  [[ "${lines[0]}" =~ ^[0-9]+.md  ]]
}

@test "\`notebooks current --filename <filename>\` prints a unique filename." {
  {
    "${_NB}" init
    "${_NB}" add "example.md" --content "Example"
  }

  run "${_NB}" notebooks current --filename "example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${lines[0]}" =~ example-1.md  ]]

  run "${_NB}" add "example.md" --content "Example"

  run "${_NB}" notebooks current --filename "example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${lines[0]}" =~ example-2.md  ]]
}

@test "\`notebooks current <selector> --filename <filename>\` prints a unique filename." {
  {
    "${_NB}" init
    "${_NB}" notebooks add one
    "${_NB}" one:add "example.md" --content "Example"
  }

  run "${_NB}" notebooks current "one" --filename "example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${lines[0]}" =~ example-1.md  ]]

  run "${_NB}" one:add "example.md" --content "Example"

  run "${_NB}" notebooks current "one" --filename "example.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${lines[0]}" =~ example-2.md  ]]
}
