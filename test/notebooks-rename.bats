#!/usr/bin/env bats

load test_helper

_setup_notebooks() {
  "${_NB}" init

  mkdir -p "${NB_DIR}/one"

  cd "${NB_DIR}/one" || return 1

  git init

  git remote add origin "${_GIT_REMOTE_URL}"

  touch "${NB_DIR}/one/.index"

  mkdir -p "${NB_DIR}/two"

  cd "${NB_DIR}/two" || return 1

  git init

  touch "${NB_DIR}/two/.index"

  cd "${NB_DIR}" || return 1
}

# aliases #####################################################################

@test "'notebooks move <valid-old> <valid-new>' exits with 0 and renames notebook." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks move "one" "new-name"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[        "${status}" -eq 0                       ]]
  [[        "${output}" =~  one                     ]]
  [[        "${output}" =~  is\ now\ named          ]]
  [[        "${output}" =~  new-name                ]]
  [[    -e  "${NB_DIR}/new-name/.git"               ]]
  [[ !  -e  "${NB_DIR}/one"                         ]]
  [[        "$(cat "${NB_DIR}/.current")" == "home" ]]
}

@test "'notebooks mv <valid-old> <valid-new>' exits with 0 and renames notebook." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks mv "one" "new-name"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[        "${status}" -eq 0                       ]]
  [[        "${output}" =~  one                     ]]
  [[        "${output}" =~  is\ now\ named          ]]
  [[        "${output}" =~  new-name                ]]
  [[    -e  "${NB_DIR}/new-name/.git"               ]]
  [[ !  -e  "${NB_DIR}/one"                         ]]
  [[        "$(cat "${NB_DIR}/.current")" == "home" ]]
}

# <name> validation ###########################################################

@test "'notebooks rename <reserved> <new>' exits with 1 and prints error message." {
  {
    "${_NB}" init

    cd "${_TMP_DIR}"

    _names=(
      ".cache"
      ".current"
      ".plugins"
      ".readme"
      "readme"
      "readme.md"
    )
  }

  for __name in "${_names[@]}"
  do
    run "${_NB}" notebooks rename "${__name}" "example"

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    [[ ${status} -eq 1                  ]]
    [[ "${lines[0]}" =~ Name\ reserved  ]]
    [[ "${lines[0]}" =~ ${__name}       ]]
  done
}

@test "'notebooks rename <old> <reserved>' exits with 1 and prints error message." {
  {
    "${_NB}" init
    "${_NB}" notebooks add "example"

    cd "${_TMP_DIR}"

    _names=(
      ".cache"
      ".current"
      ".plugins"
      ".readme"
      "readme"
      "readme.md"
    )
  }

  for __name in "${_names[@]}"
  do
    run "${_NB}" notebooks rename "example" "${__name}"

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    [[ ${status} -eq 1                  ]]
    [[ "${lines[0]}" =~ Name\ reserved  ]]
    [[ "${lines[0]}" =~ ${__name}       ]]
  done
}

# `notebooks rename` ##########################################################

@test "'notebooks rename <valid-old> <valid-new>' exits with 0 and renames notebook." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks rename "one" "new-name"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                          ]]
  [[ "${output}" =~ one                       ]]
  [[ "${output}" =~ is\ now\ named            ]]
  [[ "${output}" =~ new-name                  ]]
  [[ -e "${NB_DIR}/new-name/.git"             ]]
  [[ ! -e "${NB_DIR}/one"                     ]]
  [[ "$(cat "${NB_DIR}/.current")" == "home"  ]]
}

@test "'notebooks rename home <valid-new>' exits with 0,  renames notebook, and updates .current." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks rename "home" "new-name"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                              ]]
  [[ "${output}" =~ home                          ]]
  [[ "${output}" =~ is\ now\ named                ]]
  [[ "${output}" =~ new-name                      ]]
  [[ -e "${NB_DIR}/new-name/.git"                 ]]
  [[ ! -e "${NB_DIR}/home"                        ]]
  [[ "$(cat "${NB_DIR}/.current")" == "new-name"  ]]
}

@test "'notebooks rename <invalid-old> <valid-new>' exits with 1 and does not rename notebook." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks rename "invalid" "new-name"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                                    ]]
  [[ "${output}" =~ invalid                             ]]
  [[ "${output}" =~ is\ not\ a\ valid\ notebook\ name\. ]]
  [[ ! -e "${NB_DIR}/new-name/.git"                     ]]
  [[ -e "${NB_DIR}/one/.git"                            ]]
  [[ -e "${NB_DIR}/two"                                 ]]
  [[ -e "${NB_DIR}/two/.git"                            ]]
  [[ -e "${NB_DIR}/home/.git"                           ]]
  [[ "$(cat "${NB_DIR}/.current")" == "home"            ]]
}

@test "'notebooks rename <valid-old> <invalid-new>' exits with 1 and does not rename notebook." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks rename "one" "two"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                          ]]
  [[ "${output}" =~ A\ notebook\ named        ]]
  [[ "${output}" =~ two                       ]]
  [[ "${output}" =~ lready\ exists\.          ]]
  [[ -e "${NB_DIR}/one/.git"                  ]]
  [[ -e "${NB_DIR}/two"                       ]]
  [[ -e "${NB_DIR}/two/.git"                  ]]
  [[ -e "${NB_DIR}/home/.git"                 ]]
  [[ "$(cat "${NB_DIR}/.current")" == "home"  ]]
}

@test "'notebooks rename local <new-name>' in local exits with 1." {
  {
    "${_NB}" init

    "${_NB}" notebooks add local

    mkdir -p "${_TMP_DIR}/example"

    cd "${_TMP_DIR}/example"

    [[ "$(pwd)" == "${_TMP_DIR}/example"  ]]

    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"

    [[ -e "${NB_DIR}/local"               ]]
  }

  run "${_NB}" notebooks rename local new-name

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                            ]]
  [[ "${lines[0]}" =~ can\ not\ be\ renamed\.   ]]
  [[ -e "${NB_DIR}/local"                       ]]
}

@test "'notebooks rename local <new-name>' outside local deletes." {
  {
    _pwd="${PWD}"

    "${_NB}" init

    "${_NB}" notebooks add local

    mkdir -p "${_TMP_DIR}/example"

    cd "${_TMP_DIR}/example"

    [[ "$(pwd)" == "${_TMP_DIR}/example"  ]]

    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"

    cd "${_pwd}" || return 1

    [[ -e "${NB_DIR}/local"               ]]
  }

  run "${_NB}" notebooks rename local new-name

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                  ]]
  [[ "${lines[0]}" =~ is\ now\ named  ]]
  [[ ! -e "${NB_DIR}/local"           ]]
  [[ -e "${NB_DIR}/new-name"          ]]
}
