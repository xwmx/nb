#!/usr/bin/env bats

load test_helper

_setup_notebook() {
  {
    "${_NOTES}" init
    mkdir -p "${NOTES_DIR}/one"
    cd "${NOTES_DIR}/one"
    git init
    git remote add origin "${_GIT_REMOTE_URL}"
    mkdir -p "${NOTES_DIR}/two"
    cd "${NOTES_DIR}"
  } > /dev/null 2>&1
}

# `notes notebook` ############################################################

@test "\`notebook\` exits with 0 and prints current notebook name." {
  {
    _setup_notebook
  }

  run "${_NOTES}" notebook
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${output}" == "home" ]]
}

# `notes notebook archive` ####################################################

@test "\`notebook archive\` exits with 0 and archives." {
  {
    _setup_notebook
  }

  run "${_NOTES}" notebook archive

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]
  [[ "${output}" == "home archived." ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Archived') ]]
}

@test "\`notebook archive\` does not create git commit if already archived." {
  {
    _setup_notebook
    touch "${_NOTEBOOK_PATH}/.archived"
  }

  run "${_NOTES}" notebook archive

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]
  # Spinner changes output in unexpected ways.
  [[ "${output}" =~ home\ archived\.$ ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ ! $(git log | grep '\[NOTES\] Archived') ]]
}

# `notes notebook unarchive` ##################################################

@test "\`notebook unarchive\` exits with 0 and unarchives." {
  {
    _setup_notebook
    run "${_NOTES}" notebook archive
  }

  run "${_NOTES}" notebook unarchive

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]
  [[ "${output}" == "home unarchived." ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Unarchived') ]]
}

@test "\`notebook unarchive\` does not create git commit if already unarchived." {
  {
    _setup_notebook
  }

  run "${_NOTES}" notebook unarchive

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]
  [[ "${output}" == "home unarchived." ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ ! $(git log | grep '\[NOTES\] Unarchived') ]]
}

# `notes notebook status` #####################################################

@test "\`notebook status\` exits with 0 and prints status." {
  {
    _setup_notebook
  }

  run "${_NOTES}" notebook status

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]
  [[ "${output}" == "home is not archived." ]]

  run "${_NOTES}" notebook archive
  run "${_NOTES}" notebook status

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]
  [[ "${output}" == "home is archived." ]]
}

# help ########################################################################

@test "\`help notebook\` exits with status 0." {
  run "${_NOTES}" help notebook
  [[ ${status} -eq 0 ]]
}

@test "\`help notebook\` prints help information." {
  run "${_NOTES}" help notebook
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" =~ notes\ notebook ]]
}
