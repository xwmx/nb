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

# `notes notebooks add <name>` ################################################

@test "\`notebooks add\` exits with 1 and prints error message." {
  {
    _setup_notebooks
  }

  run "${_NOTES}" notebooks add
  [[ ${status} -eq 1 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "File Count: '%s'\\n" \
    "$(cd "${NOTES_DIR}" && find . -maxdepth 1 | wc -l)"

  [[ "${lines[1]}" =~ \ \ notes\ notebooks\ \[\<name\>\] ]]
  [[ "$(cd "${NOTES_DIR}" && find . -maxdepth 1 | wc -l)" -eq 5 ]]
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
  [[ "$(cd "${NOTES_DIR}" && find . -maxdepth 1 | wc -l)" -eq 5 ]]
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
  [[ "$(cd "${NOTES_DIR}" && find . -maxdepth 1 | wc -l)" -eq 6 ]]
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
  git log | grep -q '\[NOTES\] Initialize'
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
  [[ "$(cd "${NOTES_DIR}" && find . -maxdepth 1 | wc -l)" -eq 6 ]]
  [[ -d "${NOTES_DIR}/example/.git" ]]
  _origin="$(cd "${NOTES_DIR}/example" && git config --get remote.origin.url)"
  _compare "${_GIT_REMOTE_URL}" "${_origin}"
  [[ "${_origin}" =~ ${_GIT_REMOTE_URL} ]]
}
