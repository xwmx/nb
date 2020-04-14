#!/usr/bin/env bats

load test_helper

_setup_remote() {
  run "${_NOTES}" init
}

# remote ######################################################################

@test "\`remote\` with no arguments and no remote prints message." {
  run "${_NOTES}" init

  run "${_NOTES}" remote
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${lines[0]}" == "No remote configured." ]]
  [[ ${status} -eq 0 ]]
}

@test "\`remote\` with no arguments and existing remote prints url." {
  run "${_NOTES}" init
  cd "${_NOTEBOOK_PATH}" &&
    git remote add origin "https://example.com/example.git"

  run "${_NOTES}" remote
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${lines[0]}" == "https://example.com/example.git" ]]
  [[ ${status} -eq 0 ]]
}

# remote remove ###############################################################

@test "\`remote remove\` with no existing remote returns 1 and prints message." {
  run "${_NOTES}" init

  run "${_NOTES}" remote remove
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${lines[0]}" == "No remote configured." ]]
  [[ ${status} -eq 1 ]]
}

@test "\`remote remove\` with existing remote removes remote and prints message." {
  run "${_NOTES}" init
  cd "${_NOTEBOOK_PATH}" &&
    git remote add origin "https://example.com/example.git"

  run "${_NOTES}" remote remove --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${lines[0]}" == "Removed remote 'https://example.com/example.git'" ]]
  [[ ${status} -eq 0 ]]
}

# remote set ##################################################################

@test "\`remote set\` with no URL exits with 1 and prints help." {
  run "${_NOTES}" init

  run "${_NOTES}" remote set --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ ${status} -eq 1 ]]
}

@test "\`remote set\` with no existing remote sets remote and prints message." {
  run "${_NOTES}" init

  run "${_NOTES}" remote set "https://example.com/example.git" --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${lines[0]}" == "Remote set to 'https://example.com/example.git'" ]]
  [[ ${status} -eq 0 ]]
}

@test "\`remote set\` with existing remote sets remote and prints message." {
  run "${_NOTES}" init
  cd "${_NOTEBOOK_PATH}" &&
    git remote add origin "https://example.com/example.git"

  run "${_NOTES}" remote set "https://example.com/example2.git" --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${lines[0]}" == "Remote set to 'https://example.com/example2.git'" ]]

  [[ ${status} -eq 0 ]]
}

@test "\`remote set\` to same URL as existing remote exits and prints message." {
  run "${_NOTES}" init
  cd "${_NOTEBOOK_PATH}" &&
    git remote add origin "https://example.com/example.git"

  run "${_NOTES}" remote set "https://example.com/example.git" --force
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${lines[0]}" == "Remote already set to 'https://example.com/example.git'" ]]

  [[ ${status} -eq 1 ]]
}

# help ########################################################################

@test "\`help rename\` exits with 0 and prints help information." {
  run "${_NOTES}" help remote
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes remote" ]]
}
