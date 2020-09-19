#!/usr/bin/env bats

load test_helper

_setup_notebooks() {
  "${_NB}" init
  mkdir -p "${NB_DIR}/one"
  cd "${NB_DIR}/one" || return 1
  git init
  git remote add origin "${_GIT_REMOTE_URL}"
  touch "${NB_DIR}/one/.index"
  cd "${NB_DIR}" || return 1
}

# `notebooks delete` ##########################################################

@test "\`notebooks delete <valid>\` exits with 0 and deletes notebook." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks delete "one" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                          ]]
  [[ "${output}" =~ Notebook\ deleted\:       ]]
  [[ "${output}" =~ one                       ]]
  [[ ! -e "${NB_DIR}/one"                     ]]
  [[ "$(cat "${NB_DIR}/.current")" == "home"  ]]
}

@test "\`notebooks delete -f <valid>\` parses arguments and deletes notebook." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks delete -f "one"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                          ]]
  [[ "${output}" =~ Notebook\ deleted\:       ]]
  [[ "${output}" =~ one                       ]]
  [[ ! -e "${NB_DIR}/one"                     ]]
  [[ "$(cat "${NB_DIR}/.current")" == "home"  ]]
}

@test "\`notebooks delete <current>\` exits with 0 and deletes notebook." {
  {
    _setup_notebooks
    "${_NB}" notebooks use "one"
    [[ "$(cat "${NB_DIR}/.current")" == "one" ]]
  }

  run "${_NB}" notebooks delete "one" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                          ]]
  [[ "${lines[0]}" =~ Now\ using              ]]
  [[ "${lines[0]}" =~ home                    ]]
  [[ "${lines[1]}" =~ Notebook\ deleted\:     ]]
  [[ "${lines[1]}" =~ one                     ]]
  [[ ! -e "${NB_DIR}/one"                     ]]
  [[ "$(cat "${NB_DIR}/.current")" == "home"  ]]
}

@test "\`notebooks delete <home>\` exits with 0 and deletes notebook." {
  {
    _setup_notebooks
    [[ "$(cat "${NB_DIR}/.current")" == "home" ]]
  }

  run "${_NB}" notebooks delete "home" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                            ]]
  [[ "${lines[0]}" =~ Now\ using                ]]
  [[ "${lines[0]}" =~ one                       ]]
  [[ "${lines[1]}" =~ Notebook\ deleted\:       ]]
  [[ "${lines[1]}" =~ home                      ]]
  [[ ! -e "${NB_DIR}/home"                      ]]
  [[ "$(cat "${NB_DIR}/.current")" == "one"     ]]
}

@test "\`notebooks delete <home>\` last notebook exits with 0 and deletes notebook." {
  {
    _setup_notebooks
    [[ "$(cat "${NB_DIR}/.current")" == "home"  ]]

    "${_NB}" notebooks delete "one" --force

    [[ -e "${NB_DIR}/home"                      ]]
    [[ ! -e "${NB_DIR}/one"                     ]]
  }

  run "${_NB}" notebooks delete "home" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                          ]]
  [[ "${lines[0]}" =~ Notebook\ deleted\:     ]]
  [[ "${lines[0]}" =~ home                    ]]
  [[ ! -e "${NB_DIR}/home"                    ]]
  [[ "$(cat "${NB_DIR}/.current")" == "home"  ]]
}

@test "\`notebooks delete <no name>\` exits with 1." {
  {
    "${_NB}" init
  }

  run "${_NB}" notebooks delete --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1        ]]
  [[ "${lines[0]}" =~ Usage ]]
  [[ -e "${NB_DIR}/home"    ]]
}

@test "\`notebooks delete <not-valid>\` exits with 1." {
  {
    "${_NB}" init
  }

  run "${_NB}" notebooks delete not-valid --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                        ]]
  [[ "${lines[0]}" =~ Notebook\ not\ found  ]]
  [[ -e "${NB_DIR}/home"                    ]]
}

@test "\`notebooks delete local\` in local exits with 1." {
  {
    "${_NB}" init
    run "${_NB}" notebooks add local
    mkdir -p "${_TMP_DIR}/example"
    cd "${_TMP_DIR}/example"
    [[ "$(pwd)" == "${_TMP_DIR}/example"  ]]
    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"
    [[ -e "${NB_DIR}/local"               ]]
  }

  run "${_NB}" notebooks delete local --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                  ]]
  [[ "${lines[0]}" =~ file\ explorer  ]]
  [[ -e "${NB_DIR}/home"              ]]
  [[ -e "${NB_DIR}/local"             ]]
}

@test "\`notebooks delete local\` outside local deletes." {
  {
    _pwd="${PWD}"
    "${_NB}" init
    run "${_NB}" notebooks add local
    mkdir -p "${_TMP_DIR}/example"
    cd "${_TMP_DIR}/example"
    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]
    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"
    cd "${_pwd}" || return 1
    [[ -e "${NB_DIR}/local" ]]
  }

  run "${_NB}" notebooks delete local --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                      ]]
  [[ "${lines[0]}" =~ Notebook\ deleted\: ]]
  [[ "${lines[0]}" =~ local               ]]
  [[ ! -e "${NB_DIR}/local"               ]]
}
