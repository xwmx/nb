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

# `notes notebooks` ######################################################

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

# `notes notebooks --paths` ###################################################

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

# `notes notebooks add <name>` ################################################

@test "\`notebook add\` exits with 1 and prints error message." {
  {
    _setup_notebooks
  }

  run "${_NOTES}" notebooks add
  [[ ${status} -eq 1 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[1]}" =~ \ \ notes\ notebooks\ \[\<name\>\] ]]
  [[ "$(cd "${NOTES_DIR}" && ls -l | wc -l)" -eq 4 ]]
}

@test "\`notebooks add <existing>\` exits with 1 and prints error message." {
  {
    _setup_notebooks
  }

  run "${_NOTES}" notebooks add one
  [[ ${status} -eq 1 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Already\ exists ]]
  [[ "$(cd "${NOTES_DIR}" && ls -l | wc -l)" -eq 4 ]]
}

@test "\`notebooks add <name>\` exits with 0 and adds a notebook." {
  {
    _setup_notebooks
  }

  run "${_NOTES}" notebooks add example
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # [[ "${output}" == "Added: example" ]]
  [[ "$(cd "${NOTES_DIR}" && ls -l | wc -l)" -eq 5 ]]
}

@test "\`notebooks add <name>\` creates git commit." {
  {
    _setup_notebooks
  }

  run "${_NOTES}" notebooks add example
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\$(ls -la \"${NOTES_DIR}/example/\"): '%s'\\n" \
    "$(ls -la "${NOTES_DIR}/example/")"

  cd "${NOTES_DIR}/example" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Initialize') ]]
}

@test "\`notebooks add <name> <remote-url>\` exits with 0 and adds a notebook." {
  {
    _setup_notebooks
    _setup_remote_repo
  }

  run "${_NOTES}" notebooks add example "${_GIT_REMOTE_URL}"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_GIT_REMOTE_URL}: '%s'\\n" "${_GIT_REMOTE_URL}"
  [[ ${status} -eq 0 ]]

  [[ "${lines[1]}" == "Added: example" ]]
  [[ "$(cd "${NOTES_DIR}" && ls -l | wc -l)" -eq 5 ]]
  [[ -d "${NOTES_DIR}/example/.git" ]]
  _origin="$(cd "${NOTES_DIR}/example" && git config --get remote.origin.url)"
  _compare "${_GIT_REMOTE_URL}" "${_origin}"
  [[ "${_origin}" =~  "${_GIT_REMOTE_URL}" ]]
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

# `notes notebooks init` ######################################################

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
  [[ $(git log | grep '\[NOTES\] Initialize') ]]
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
  [[ "${_origin}" =~  "${_GIT_REMOTE_URL}" ]]

  cd "${_TMP_DIR}/example" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep 'Initial commit.') ]]
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

  [[ "${output}" =~ "'invalid' is not a valid notebook name." ]]
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

  [[ "${output}" =~ "A notebook named 'two' already exists." ]]
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
