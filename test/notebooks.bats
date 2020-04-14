#!/usr/bin/env bats

load test_helper

_setup_notebooks() {
  "${_NOTES}" init
  mkdir -p "${NOTES_DIR}/one"
  cd "${NOTES_DIR}/one"
  git init
  git remote add origin "${_GIT_REMOTE_URL}"
  mkdir -p "${NOTES_DIR}/two"
  cd "${NOTES_DIR}"
}

# `notes notebooks` ######################################################

@test "\`notebooks\` exits with 0 and prints all notebook names." {
  {
    _setup_notebooks
    _expected="$(tput setaf 3)home$(tput sgr0)
one	(${_GIT_REMOTE_URL})"
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

  _expected="one	(${_GIT_REMOTE_URL})"
  [[ "${output}" == "${_expected}" ]]
}

@test "\`notebooks <name> --names\` exits with 0 and prints the given notebook name." {
  {
    _setup_notebooks
    _expected="$(tput setaf 3)home$(tput sgr0)"
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
    _expected="$(tput setaf 3)home$(tput sgr0)
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
one	(${_GIT_REMOTE_URL})"
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

  [[ "${output}" == "one" ]]
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

  [[ "${lines[1]}" == "  notes notebooks [<name>] [--names] [--no-color]" ]]
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
  [[ "${lines[1]}" == "  notes notebooks [<name>] [--names] [--no-color]" ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "home" ]]

  run "${_NOTES}" env
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'_NOTEBOOK_PATH=${NOTES_DIR}/home'" "'${lines[3]}'"

  [[ "${lines[3]}" == "_NOTEBOOK_PATH=${NOTES_DIR}/home" ]]
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
  _compare "'_NOTEBOOK_PATH=${NOTES_DIR}/home'" "'${lines[3]}'"

  [[ "${lines[3]}" == "_NOTEBOOK_PATH=${NOTES_DIR}/home" ]]
}

@test "\`notebooks use <name>\` exits with 0 and sets <name> in .current." {
  {
    _setup_notebooks
  }

  run "${_NOTES}" notebooks use one
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'Now using $(tput setaf 3)one$(tput sgr0).'" "'${output}'"

  [[ "${output}" == "Now using $(tput setaf 3)one$(tput sgr0)." ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "one" ]]

  run "${_NOTES}" env
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'_NOTEBOOK_PATH=${NOTES_DIR}/one'" "'${lines[3]}'"

  [[ "${lines[3]}" == "_NOTEBOOK_PATH=${NOTES_DIR}/one" ]]
}

@test "\`notebooks use <name>:\` exits with 0 and sets <name> in .current." {
  {
    _setup_notebooks
  }

  run "${_NOTES}" notebooks use one:
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'Now using $(tput setaf 3)one$(tput sgr0).'" "'${output}'"

  [[ "${output}" == "Now using $(tput setaf 3)one$(tput sgr0)." ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "one" ]]

  run "${_NOTES}" env
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "'_NOTEBOOK_PATH=${NOTES_DIR}/one'" "'${lines[3]}'"

  [[ "${lines[3]}" == "_NOTEBOOK_PATH=${NOTES_DIR}/one" ]]
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
  [[ "${lines[1]}" == "  notes notebooks [<name>] [--names] [--no-color]" ]]
}
