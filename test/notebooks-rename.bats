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

# `notes notebooks rename` ####################################################

@test "\`notebooks rename <valid-old> <valid-new>\` exits with 0 and renames notebook." {
  {
    _setup_notebooks
  }

  run "${_NOTES}" notebooks rename "one" "new-name"
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${output}" == "'one' is now named 'new-name'" ]]
  [[ -e "${NOTES_DIR}/new-name/.git" ]]
  [[ ! -e "${NOTES_DIR}/one" ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "home" ]]
}

@test "\`notebooks rename home <valid-new>\` exits with 0,  renames notebook, and updates .current." {
  {
    _setup_notebooks
  }

  run "${_NOTES}" notebooks rename "home" "new-name"
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${output}" =~ "'home' is now named 'new-name'" ]]
  [[ -e "${NOTES_DIR}/new-name/.git" ]]
  [[ ! -e "${NOTES_DIR}/home" ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "new-name" ]]
}

@test "\`notebooks rename <invalid-old> <valid-new>\` exits with 1 and does not rename notebook." {
  {
    _setup_notebooks
  }

  run "${_NOTES}" notebooks rename "invalid" "new-name"
  [[ ${status} -eq 1 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${output}" =~ \'invalid\'\ is\ not\ a\ valid\ notebook\ name\. ]]
  [[ ! -e "${NOTES_DIR}/new-name/.git" ]]
  [[ -e "${NOTES_DIR}/one/.git" ]]
  [[ -e "${NOTES_DIR}/two" ]]
  [[ ! -e "${NOTES_DIR}/two/.git" ]]
  [[ -e "${NOTES_DIR}/home/.git" ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "home" ]]
}

@test "\`notebooks rename <valid-old> <invalid-new>\` exits with 1 and does not rename notebook." {
  {
    _setup_notebooks
  }

  run "${_NOTES}" notebooks rename "one" "two"
  [[ ${status} -eq 1 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${output}" =~ A\ notebook\ named\ \'two\'\ already\ exists\. ]]
  [[ -e "${NOTES_DIR}/one/.git" ]]
  [[ -e "${NOTES_DIR}/two" ]]
  [[ ! -e "${NOTES_DIR}/two/.git" ]]
  [[ -e "${NOTES_DIR}/home/.git" ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "home" ]]
}

@test "\`notebooks rename local <new-name>\` in local exits with 1." {
  {
    "${_NOTES}" init
    run "${_NOTES}" notebooks add local
    mkdir -p "${_TMP_DIR}/example"
    cd "${_TMP_DIR}/example"
    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]
    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"
    [[ -e "${NOTES_DIR}/local" ]]
  }

  run "${_NOTES}" notebooks rename local new-name

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]
  [[ "${lines[0]}" =~ can\ not\ be\ renamed\. ]]
  [[ -e "${NOTES_DIR}/local" ]]
}

@test "\`notebooks rename local <new-name>\` outside local deletes." {
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

  run "${_NOTES}" notebooks rename local new-name

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ is\ now\ named ]]
  [[ ! -e "${NOTES_DIR}/local" ]]
  [[ -e "${NOTES_DIR}/new-name" ]]
}
