#!/usr/bin/env bats

load test_helper

_setup_notebook() {
  "${_NOTES}" init
  mkdir -p "${NOTES_DIR}/one"
  cd "${NOTES_DIR}/one"
  git init
  git remote add origin "${_GIT_REMOTE_URL}"
  mkdir -p "${NOTES_DIR}/two"
  cd "${NOTES_DIR}"
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
