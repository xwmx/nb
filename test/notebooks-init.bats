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

# `notebooks init` ############################################################

@test "\`notebooks init\` with no arguments initializes the current directory" {
  {
    _setup_notebooks
    mkdir -p "${_TMP_DIR}/example"
    cd "${_TMP_DIR}/example"
    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]
  }

  run "${_NOTES}" notebooks init
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Initialized\ local\ notebook ]]
  [[ "${lines[0]}" =~ example ]]
  [[ -d "${_TMP_DIR}/example/.git"    ]]
  [[ -f "${_TMP_DIR}/example/.index"  ]]
}

@test "\`notebooks init\` in existing notebook exits with 1 and prints error message." {
  {
    _setup_notebooks
    mkdir -p "${_TMP_DIR}/example"
    cd "${_TMP_DIR}/example"
    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]
    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"
  }

  run "${_NOTES}" notebooks init
  [[ ${status} -eq 1 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Notebook\ exists ]]
  [[ "${lines[0]}" =~ example ]]
}

@test "\`notebooks init\` in existing git repo exits with 1 and prints error message." {
  {
    _setup_notebooks
    mkdir -p "${_TMP_DIR}/example"
    cd "${_TMP_DIR}/example"
    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]
    git init 1>/dev/null
  }

  run "${_NOTES}" notebooks init
  [[ ${status} -eq 1 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Git\ repository\ exists ]]
  [[ "${lines[0]}" =~ example ]]
}

@test "\`notebooks init <relative path>\` with no arguments succeeds." {
  {
    _setup_notebooks
    cd "${_TMP_DIR}"
    [[ "$(pwd)" == "${_TMP_DIR}" ]]
  }

  run "${_NOTES}" notebooks init example
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Initialized\ local\ notebook ]]
  [[ "${lines[0]}" =~ example ]]
  [[ -d "${_TMP_DIR}/example/.git"    ]]
  [[ -f "${_TMP_DIR}/example/.index"  ]]
}

@test "\`notebooks init <relative path>\` in existing notebook exits with 1." {
  {
    _setup_notebooks
    mkdir -p "${_TMP_DIR}/example"
    cd "${_TMP_DIR}/example"
    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]
    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"
    cd "${_TMP_DIR}"
    [[ "$(pwd)" == "${_TMP_DIR}" ]]
  }

  run "${_NOTES}" notebooks init example
  [[ ${status} -eq 1 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Notebook\ exists ]]
  [[ "${lines[0]}" =~ example ]]
}

@test "\`notebooks init <relative path>\` in existing git repo exits with 1." {
  {
    _setup_notebooks
    mkdir -p "${_TMP_DIR}/example"
    cd "${_TMP_DIR}/example"
    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]
    git init 1>/dev/null
    cd "${_TMP_DIR}"
    [[ "$(pwd)" == "${_TMP_DIR}" ]]
  }

  run "${_NOTES}" notebooks init example
  [[ ${status} -eq 1 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Git\ repository\ exists ]]
  [[ "${lines[0]}" =~ example ]]
}

@test "\`notebooks init <absolute path>\` with no arguments succeeds." {
  {
    _setup_notebooks
  }

  run "${_NOTES}" notebooks init "${_TMP_DIR}/example"
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Initialized\ local\ notebook ]]
  [[ "${lines[0]}" =~ example ]]
  [[ -d "${_TMP_DIR}/example/.git"    ]]
  [[ -f "${_TMP_DIR}/example/.index"  ]]

  cd "${_TMP_DIR}/example" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep '\[NOTES\] Initialize'
}

@test "\`notebooks init <absolute path>\` in existing notebook exits with 1." {
  {
    _setup_notebooks
    mkdir -p "${_TMP_DIR}/example"
    cd "${_TMP_DIR}/example"
    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]
    git init 1>/dev/null && touch "${_TMP_DIR}/example/.index"
  }

  run "${_NOTES}" notebooks init "${_TMP_DIR}/example"
  [[ ${status} -eq 1 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Notebook\ exists ]]
  [[ "${lines[0]}" =~ example ]]
}

@test "\`notebooks init <absolute path>\` in existing git repo exits with 1." {
  {
    _setup_notebooks
    mkdir -p "${_TMP_DIR}/example"
    cd "${_TMP_DIR}/example"
    [[ "$(pwd)" == "${_TMP_DIR}/example" ]]
    git init 1>/dev/null
  }

  run "${_NOTES}" notebooks init "${_TMP_DIR}/example"
  [[ ${status} -eq 1 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Git\ repository\ exists ]]
  [[ "${lines[0]}" =~ example ]]
}

@test "\`notebooks init <path> <remote-url>\` exits with 0 and adds a notebook." {
  {
    _setup_notebooks
    _setup_remote_repo
  }

  run "${_NOTES}" notebooks init "${_TMP_DIR}/example" "${_GIT_REMOTE_URL}"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_GIT_REMOTE_URL}: '%s'\\n" "${_GIT_REMOTE_URL}"
  [[ ${status} -eq 0 ]]

  [[ "${lines[0]}" =~ Cloning ]]
  [[ "${lines[1]}" =~ Initialized\ local\ notebook ]]
  [[ "${lines[1]}" =~ example ]]
  [[ -d "${_TMP_DIR}/example/.git"    ]]
  [[ -f "${_TMP_DIR}/example/.index"  ]]
  _origin="$(cd "${_TMP_DIR}/example" && git config --get remote.origin.url)"
  _compare "${_GIT_REMOTE_URL}" "${_origin}"
  [[ "${_origin}" =~ ${_GIT_REMOTE_URL} ]]

  cd "${_TMP_DIR}/example" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep 'Initial commit.'
}
