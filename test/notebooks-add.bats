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
  cd "${NB_DIR}" || return 1
}

# `notebooks add <name>` ######################################################

@test "\`notebooks add\` exits with 1 and prints error message." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks add

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "File Count: '%s'\\n" \
    "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)"
  printf "%s\\n" "$(cd "${NB_DIR}" && find . -maxdepth 1)"

  [[ ${status} -eq 1                                          ]]
  [[ "${lines[1]}" =~ \ \ nb\ notebooks\ \[\<name\>\]         ]]
  [[ "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 6  ]]
}

@test "\`notebooks add <existing>\` exits with 1 and prints error message." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks add one


  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1                                          ]]
  [[ "${lines[0]}" =~ Already\ exists                         ]]
  [[ "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 6  ]]
}

@test "\`notebooks add <name>\` exits with 0 and adds a notebook." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks add example


  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                          ]]
  [[ "${lines[0]}" =~ Added\ notebook\:                       ]]
  [[ "${lines[0]}" =~ example                                 ]]
  [[ "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 7  ]]
}

@test "\`notebooks add <name>\` creates git commit." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks add example


  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\$(ls -la \"${NB_DIR}/example/\"): '%s'\\n" \
    "$(ls -la "${NB_DIR}/example/")"

  [[ ${status} -eq 0 ]]

  cd "${NB_DIR}/example" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Initialize'
}

@test "\`notebooks add <name> <remote-url>\` exits with 0 and adds a notebook." {
  {
    _setup_notebooks
    _setup_remote_repo
  }

  run "${_NB}" notebooks add example "${_GIT_REMOTE_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_GIT_REMOTE_URL}: '%s'\\n" "${_GIT_REMOTE_URL}"

  [[ ${status} -eq 0                                          ]]
  [[ "${lines[1]}" =~ Added\ notebook\:                       ]]
  [[ "${lines[1]}" =~ example                                 ]]
  [[ "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 7  ]]
  [[ -d "${NB_DIR}/example/.git"                              ]]

  _origin="$(cd "${NB_DIR}/example" && git config --get remote.origin.url)"
  _compare "${_GIT_REMOTE_URL}" "${_origin}"

  [[ "${_origin}" =~ ${_GIT_REMOTE_URL} ]]
}

@test "\`notebooks a <name>\` exits with 0 and adds a notebook." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks a example


  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                          ]]
  [[ "${output}" =~ Added                                     ]]
  [[ "${output}" =~ example                                   ]]
  [[ "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 7  ]]
}

@test "\`notebooks create <name>\` exits with 0 and adds a notebook." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks add example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                          ]]
  [[ "${output}" =~ Added                                     ]]
  [[ "${output}" =~ example                                   ]]
  [[ "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 7  ]]
}

@test "\`notebooks new <name>\` exits with 0 and adds a notebook." {
  {
    _setup_notebooks
  }

  run "${_NB}" notebooks add example


  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                          ]]
  [[ "${output}" =~ Added                                     ]]
  [[ "${output}" =~ example                                   ]]
  [[ "$(cd "${NB_DIR}" && find . -maxdepth 1 | wc -l)" -eq 7  ]]
}
