#!/usr/bin/env bats

load test_helper

_setup_notebook() {
  {
    "${_NB}" init
    mkdir -p "${NB_DIR}/one"
    cd "${NB_DIR}/one" || return 1
    git init
    git remote add origin "${_GIT_REMOTE_URL}"
    mkdir -p "${NB_DIR}/two"
    cd "${NB_DIR}" || return 1
  } > /dev/null 2>&1
}

# `notebooks archive` #########################################################

@test "\`notebooks archive\` exits with 0 and archives." {
  {
    _setup_notebook
  }

  run "${_NB}" notebooks archive

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                      ]]
  [[ "${output}" == "$(_color_primary "home") archived."  ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Archived'
}

@test "\`notebooks archive <name>\` exits with 0 and archives." {
  {
    _setup_notebook
  }

  run "${_NB}" notebooks archive one

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                    ]]
  [[ "${output}" == "$(_color_primary "one") archived." ]]

  # Creates git commit
  cd "${NB_DIR}/one" || return 1
  _counter=0
  while [[ -n "$(git status --porcelain)" ]]
  do
    [[ "${_counter}" -gt 5 ]] && git status && break
    sleep 1
    _counter="$((_counter+1))"
  done
  git log | grep -q '\[nb\] Archived'
}

@test "\`notebooks archive\` does not create git commit if already archived." {
  {
    _setup_notebook
    touch "${_NOTEBOOK_PATH}/.archived"
  }

  run "${_NB}" notebooks archive

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0            ]]
  # NOTE: Spinner changes output in unexpected ways.
  [[ "${output}" =~ home        ]]
  [[ "${output}" =~ archived\.$ ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  ! git log | grep '\[nb\] Archived'
}

# `notebooks unarchive` #######################################################

@test "\`notebooks unarchive\` exits with 0 and unarchives." {
  {
    _setup_notebook
    run "${_NB}" notebooks archive
  }

  run "${_NB}" notebooks unarchive

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                        ]]
  [[ "${output}" == "$(_color_primary "home") unarchived."  ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep '\[nb\] Unarchived'
}

@test "\`notebooks unarchive <name>\` exits with 0 and unarchives." {
  {
    _setup_notebook
    run "${_NB}" notebooks archive one
  }

  run "${_NB}" notebooks unarchive one

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                      ]]
  [[ "${output}" == "$(_color_primary "one") unarchived." ]]

  # Creates git commit
  cd "${NB_DIR}/one" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep '\[nb\] Unarchived'
}

@test "\`notebooks unarchive\` does not create git commit if already unarchived." {
  {
    _setup_notebook
  }

  run "${_NB}" notebooks unarchive

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                        ]]
  [[ "${output}" == "$(_color_primary "home") unarchived."  ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  ! git log | grep -q '\[nb\] Unarchived'
}

# `notebooks status` ##########################################################

@test "\`notebooks status\` exits with 0 and prints status." {
  {
    _setup_notebook
  }

  run "${_NB}" notebooks status

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                            ]]
  [[ "${output}" == "$(_color_primary "home") is not archived." ]]

  run "${_NB}" notebooks archive
  run "${_NB}" notebooks status

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                        ]]
  [[ "${output}" == "$(_color_primary "home") is archived." ]]
}

@test "\`notebooks status <name>\` exits with 0 and prints status." {
  {
    _setup_notebook
  }

  run "${_NB}" notebooks status one

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                            ]]
  [[ "${output}" == "$(_color_primary "one") is not archived."  ]]

  run "${_NB}" notebooks archive one
  run "${_NB}" notebooks status one

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                        ]]
  [[ "${output}" == "$(_color_primary "one") is archived."  ]]
}

# help ########################################################################

@test "\`help notebooks\` exits with status 0." {
  run "${_NB}" help notebooks

  [[ ${status} -eq 0 ]]
}

@test "\`help notebooks\` prints help information." {
  run "${_NB}" help notebooks

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" == "Usage:"      ]]
  [[ "${lines[1]}" =~ nb\ notebook  ]]
}
