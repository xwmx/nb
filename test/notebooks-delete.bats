#!/usr/bin/env bats

load test_helper

_setup_notebooks() {
  "${_NOTES}" init
  mkdir -p "${NOTES_DIR}/one"
  cd "${NOTES_DIR}/one"
  git init
  git remote add origin "${_GIT_REMOTE_URL}"
  touch "${NOTES_DIR}/one/.index"
  mkdir -p "${NOTES_DIR}/two"
  cd "${NOTES_DIR}"
}

# `notes notebooks delete` ####################################################

@test "\`notebooks delete <valid>\` exits with 0 and deletes notebook." {
  {
    _setup_notebooks
  }

  run "${_NOTES}" notebooks delete "one" --force

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]
  [[ "${output}" == "Notebook deleted: one" ]]
  [[ ! -e "${NOTES_DIR}/one" ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "home" ]]
}

@test "\`notebooks delete <current>\` exits with 0 and deletes notebook." {
  {
    _setup_notebooks
    "${_NOTES}" notebooks use "one"
    [[ "$(cat "${NOTES_DIR}/.current")" == "one" ]]
  }

  run "${_NOTES}" notebooks delete "one" --force

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ Now\ using ]]
  [[ "${lines[0]}" =~ home ]]
  [[ "${lines[1]}" == "Notebook deleted: one" ]]
  [[ ! -e "${NOTES_DIR}/one" ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "home" ]]
}

@test "\`notebooks delete <home>\` exits with 0 and deletes notebook." {
  {
    _setup_notebooks
    [[ "$(cat "${NOTES_DIR}/.current")" == "home" ]]
  }

  run "${_NOTES}" notebooks delete "home" --force

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ Now\ using ]]
  [[ "${lines[0]}" =~ one ]]
  [[ "${lines[1]}" == "Notebook deleted: home" ]]
  [[ ! -e "${NOTES_DIR}/home" ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "one" ]]
}

@test "\`notebooks delete <home>\` last notebook exits with 0 and deletes notebook." {
  {
    _setup_notebooks
    [[ "$(cat "${NOTES_DIR}/.current")" == "home" ]]
    "${_NOTES}" notebooks delete "one" --force
    [[ -e "${NOTES_DIR}/home" ]]
    [[ ! -e "${NOTES_DIR}/one" ]]
  }

  run "${_NOTES}" notebooks delete "home" --force

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" == "Notebook deleted: home" ]]
  [[ ! -e "${NOTES_DIR}/home" ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "home" ]]
}

@test "\`notebooks delete <no name>\` exits with 1." {
  {
    "${_NOTES}" init
  }

  run "${_NOTES}" notebooks delete --force

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]
  [[ "${lines[0]}" =~ Usage ]]
  [[ -e "${NOTES_DIR}/home" ]]
}

@test "\`notebooks delete <not-valid>\` exits with 1." {
  {
    "${_NOTES}" init
  }

  run "${_NOTES}" notebooks delete not-valid --force

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]
  [[ "${lines[0]}" =~ Notebook\ not\ found ]]
  [[ -e "${NOTES_DIR}/home" ]]
}

@test "\`notebooks delete local\` in local exits with 1." {
  {
    "${_NOTES}" init
    run "${_NOTES}" notebooks add local
    mkdir -p "${_TMP_DIR}/example"
    cd "${_TMP_DIR}/example"
    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]
    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"
    [[ -e "${NOTES_DIR}/local" ]]
  }

  run "${_NOTES}" notebooks delete local --force

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]
  [[ "${lines[0]}" =~ file\ explorer ]]
  [[ -e "${NOTES_DIR}/home" ]]
  [[ -e "${NOTES_DIR}/local" ]]
}

@test "\`notebooks delete local\` outside local deletes." {
  {
    _pwd="${PWD}"
    "${_NOTES}" init
    run "${_NOTES}" notebooks add local
    mkdir -p "${_TMP_DIR}/example"
    cd "${_TMP_DIR}/example"
    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]
    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"
    cd "${_pwd}" || return 1
    [[ -e "${NOTES_DIR}/local" ]]
  }

  run "${_NOTES}" notebooks delete local --force

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ Notebook\ deleted\:\ local ]]
  [[ ! -e "${NOTES_DIR}/local" ]]
}
