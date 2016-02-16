#!/usr/bin/env bats

load test_helper

_setup_notebooks() {
  "$_NOTES" init
  mkdir -p "${NOTES_DIR}/one"
  cd "${NOTES_DIR}/one"
  git init
  git remote add origin "${_GIT_REMOTE_URL}"
  mkdir -p "${NOTES_DIR}/two"
  cd "${NOTES_DIR}"
}

# `notes notebook` ############################################################

@test "\`notebook\` exits with 0 and prints the current notebook name." {
  {
    _setup_notebooks
  }

  run "$_NOTES" notebook
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ "$output" == "home" ]]
}

@test "\`notebook current\` exits with 0 and prints the current notebook name." {
  {
    _setup_notebooks
    printf "%s\n" "one" > "${NOTES_DIR}/.current"
  }

  run "$_NOTES" notebook
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ "$output" == "one" ]]
}

# `notes notebook add <name>` #################################################

@test "\`notebook add\` exits with 1 and prints error message." {
  {
    _setup_notebooks
  }

  run "$_NOTES" notebook add
  [[ $status -eq 1 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ "${lines[1]}" == "  notes notebook" ]]
  [[ "$(cd "${NOTES_DIR}" && ls -l | wc -l)" -eq 4 ]]
}

@test "\`notebook add <existing>\` exits with 1 and prints error message." {
  {
    _setup_notebooks
  }

  run "$_NOTES" notebook add one
  [[ $status -eq 1 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ "${lines[0]}" =~ Already\ exists ]]
  [[ "$(cd "${NOTES_DIR}" && ls -l | wc -l)" -eq 4 ]]
}

@test "\`notebook add <name>\` exits with 0 and adds a notebook." {
  {
    _setup_notebooks
  }

  run "$_NOTES" notebook add example
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  # [[ "$output" == "Added: example" ]]
  [[ "$(cd "${NOTES_DIR}" && ls -l | wc -l)" -eq 5 ]]
}

@test "\`notebook add <name> <remote-url>\` exits with 0 and adds a notebook." {
  {
    _setup_notebooks
    _setup_remote_repo
  }

  run "$_NOTES" notebook add example "$_GIT_REMOTE_URL"
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  printf "\$_GIT_REMOTE_URL: '%s'\n" "$_GIT_REMOTE_URL"
  [[ $status -eq 0 ]]

  [[ "${lines[1]}" == "Added: example" ]]
  [[ "$(cd "${NOTES_DIR}" && ls -l | wc -l)" -eq 5 ]]
  [[ -d "${NOTES_DIR}/example/.git" ]]
  _origin="$(cd "${NOTES_DIR}/example" && git config --get remote.origin.url)"
  _compare "$_GIT_REMOTE_URL" "$_origin"
  [[ "$_origin" =~  "$_GIT_REMOTE_URL" ]]
}

# `notes notebook list` #######################################################

@test "\`notebook list\` exits with 0 and prints all notebook names." {
  {
    _setup_notebooks
  }

  run "$_NOTES" notebook list
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  _expected="$(tput setaf 3)home$(tput sgr0)
one	(${_GIT_REMOTE_URL})"
  [[ "$output" == "$_expected" ]]
}

@test "\`notebook list --names\` exits with 0 and prints all notebook names." {
  {
    _setup_notebooks
  }

  run "$_NOTES" notebook list --names
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  _expected="home
one"
  [[ "$output" == "$_expected" ]]
}

# `notes notebook rename` #####################################################

@test "\`notebook rename <valid-old> <valid-new>\` exits with 0 and renames notebook." {
  {
    _setup_notebooks
  }

  run "$_NOTES" notebook rename "one" "new-name"
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ "$output" == "'one' is now named 'new-name'" ]]
  [[ -e "${NOTES_DIR}/new-name/.git" ]]
  [[ ! -e "${NOTES_DIR}/one" ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "home" ]]
}

@test "\`notebook rename home <valid-new>\` exits with 0,  renames notebook, and updates .current." {
  {
    _setup_notebooks
  }

  run "$_NOTES" notebook rename "home" "new-name"
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ "$output" =~ "'home' is now named 'new-name'" ]]
  [[ -e "${NOTES_DIR}/new-name/.git" ]]
  [[ ! -e "${NOTES_DIR}/home" ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "new-name" ]]
}

@test "\`notebook rename <invalid-old> <valid-new>\` exits with 1 and does not rename notebook." {
  {
    _setup_notebooks
  }

  run "$_NOTES" notebook rename "invalid" "new-name"
  [[ $status -eq 1 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ "$output" =~ "'invalid' is not a valid notebook name." ]]
  [[ ! -e "${NOTES_DIR}/new-name/.git" ]]
  [[ -e "${NOTES_DIR}/one/.git" ]]
  [[ -e "${NOTES_DIR}/two" ]]
  [[ ! -e "${NOTES_DIR}/two/.git" ]]
  [[ -e "${NOTES_DIR}/home/.git" ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "home" ]]
}

@test "\`notebook rename <valid-old> <invalid-new>\` exits with 1 and does not rename notebook." {
  {
    _setup_notebooks
  }

  run "$_NOTES" notebook rename "one" "two"
  [[ $status -eq 1 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"

  [[ "$output" =~ "A notebook named 'two' already exists." ]]
  [[ -e "${NOTES_DIR}/one/.git" ]]
  [[ -e "${NOTES_DIR}/two" ]]
  [[ ! -e "${NOTES_DIR}/two/.git" ]]
  [[ -e "${NOTES_DIR}/home/.git" ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "home" ]]
}

# `notes notebook use <name>` #################################################

@test "\`notebook use\` exits with 1 and prints error message." {
  {
    _setup_notebooks
  }

  run "$_NOTES" notebook use
  [[ $status -eq 1 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  printf ".current: %s\n" "$(cat "${NOTES_DIR}/.current")"
  [[ "${lines[1]}" == "  notes notebook" ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "home" ]]

  run "$_NOTES" env
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  _compare "'NOTES_DATA_DIR=${NOTES_DIR}/home'" "'${lines[1]}'"

  [[ "${lines[1]}" == "NOTES_DATA_DIR=${NOTES_DIR}/home" ]]
}

@test "\`notebook use <invalid>\` exits with 1 and prints error message." {
  {
    _setup_notebooks
  }

  run "$_NOTES" notebook use not-a-notebook
  [[ $status -eq 1 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  printf ".current: %s\n" "$(cat "${NOTES_DIR}/.current")"
  [[ "${lines[0]}" == "❌  Not found: not-a-notebook" ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "home" ]]

  run "$_NOTES" env
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  _compare "'NOTES_DATA_DIR=${NOTES_DIR}/home'" "'${lines[1]}'"

  [[ "${lines[1]}" == "NOTES_DATA_DIR=${NOTES_DIR}/home" ]]
}

@test "\`notebook use <name>\` exits with 0 and sets <name> in .current." {
  {
    _setup_notebooks
  }

  run "$_NOTES" notebook use one
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  _compare "'Now using $(tput setaf 3)one$(tput sgr0).'" "'$output'"

  [[ "$output" == "Now using $(tput setaf 3)one$(tput sgr0)." ]]
  [[ "$(cat "${NOTES_DIR}/.current")" == "one" ]]

  run "$_NOTES" env
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  _compare "'NOTES_DATA_DIR=${NOTES_DIR}/one'" "'${lines[1]}'"

  [[ "${lines[1]}" == "NOTES_DATA_DIR=${NOTES_DIR}/one" ]]
}

# help ########################################################################

@test "\`help list\` exits with status 0." {
  run "$_NOTES" help notebook
  [[ $status -eq 0 ]]
}

@test "\`help list\` prints help information." {
  run "$_NOTES" help notebook
  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes notebook" ]]
}
