#!/usr/bin/env bats

load test_helper

# remote ######################################################################

@test "\`remote\` with no arguments and no remote prints message." {
  {
    run "${_NB}" init
  }

  run "${_NB}" remote

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ No\ remote\ configured  ]]
  [[ ${status} -eq 0                          ]]
}

@test "\`remote\` with no arguments and existing remote prints url." {
  {
    run "${_NB}" init
    cd "${_NOTEBOOK_PATH}" &&
      git remote add origin "${_GIT_REMOTE_URL}"
  }

  run "${_NB}" remote

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" == "${_GIT_REMOTE_URL}"  ]]
  [[ ${status} -eq 0                        ]]
}

# remote remove ###############################################################

@test "\`remote remove\` with no existing remote returns 1 and prints message." {
  {
    run "${_NB}" init
  }

  run "${_NB}" remote remove

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ No\ remote\ configured  ]]
  [[ ${status} -eq 1                          ]]
}

@test "\`remote remove\` with existing remote removes remote and prints message." {
  {
    run "${_NB}" init
    cd "${_NOTEBOOK_PATH}" &&
      git remote add origin "${_GIT_REMOTE_URL}"
  }

  run "${_NB}" remote remove --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  "${_NB}" remote

  [[ "$("${_NB}" remote)" =~ No\ remote   ]]
  [[ "${lines[0]}" =~ Removed\ remote     ]]
  [[ "${lines[0]}" =~ ${_GIT_REMOTE_URL}  ]]
  [[ ${status} -eq 0                      ]]
}

# remote set ##################################################################

@test "\`remote set\` with no URL exits with 1 and prints help." {
  {
    run "${_NB}" init
  }

  run "${_NB}" remote set --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Usage\: ]]
  [[ ${status} -eq 1          ]]
}

@test "\`remote set\` with no existing remote sets remote and prints message." {
  {
    run "${_NB}" init
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Remote\ set\ to     ]]
  [[ "${lines[0]}" =~ ${_GIT_REMOTE_URL}  ]]
  [[ ${status} -eq 0                      ]]
}

@test "\`remote set\` with existing remote sets remote and prints message." {
  {
    run "${_NB}" init
    cd "${_NOTEBOOK_PATH}" &&
      git remote add origin "https://example.test/example.git"
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Remote\ set\ to     ]]
  [[ "${lines[0]}" =~ ${_GIT_REMOTE_URL}  ]]
  [[ ${status} -eq 0                      ]]
}

@test "\`remote set\` to same URL as existing remote exits and prints message." {
  {
    run "${_NB}" init
    cd "${_NOTEBOOK_PATH}" &&
      git remote add origin "${_GIT_REMOTE_URL}"
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Remote\ already\ set\ to  ]]
  [[ "${lines[0]}" =~ ${_GIT_REMOTE_URL}        ]]
  [[ ${status} -eq 1                            ]]
}

# help ########################################################################

@test "\`help remote\` exits with 0 and prints help information." {
  run "${_NB}" help remote

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                  ]]
  [[ "${lines[0]}" =~ Usage\:         ]]
  [[ "${lines[1]}" =~ \ \ nb\ remote  ]]
}
