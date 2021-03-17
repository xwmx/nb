#!/usr/bin/env bats

load test_helper

# remote ######################################################################

@test "'remote' with no arguments and no remote prints message." {
  {
    "${_NB}" init
  }

  run "${_NB}" remote

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                       ]]
  [[ "${lines[0]}"  =~  No\ remote\ configured  ]]
}

@test "'remote --url' with existing remote prints url." {
  {
    "${_NB}" init

    cd "${NB_DIR}/home" &&
      git remote add origin "${_GIT_REMOTE_URL}"
  }

  run "${_NB}" remote --url

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                     ]]
  [[ "${lines[0]}"  ==  "${_GIT_REMOTE_URL}"  ]]
}

@test "'remote' with no arguments and existing remote prints url and branch." {
  {
    "${_NB}" init

    cd "${NB_DIR}/home" &&
      git remote add origin "${_GIT_REMOTE_URL}"
  }

  run "${_NB}" remote

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                             ]]
  [[ "${lines[0]}"  ==  "${_GIT_REMOTE_URL} (master)" ]]
}

@test "'remote' with no arguments does not trigger git commit." {
  {
    "${_NB}" init
    cd "${NB_DIR}/home" &&
      git remote add origin "${_GIT_REMOTE_URL}"

    touch "${NB_DIR}/home/example.md"

    [[ -f "${NB_DIR}/home/example.md" ]]

    "${_NB}" git dirty
  }

  run "${_NB}" remote

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                             ]]

  [[ "${lines[0]}"  ==  "${_GIT_REMOTE_URL} (master)" ]]

  [[ -f "${NB_DIR}/home/example.md"                   ]]

  "${_NB}" git dirty

  # does not create git commit

  cd "${NB_DIR}/home" || return 1
  if [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  then
    sleep 1
  fi

  ! git log | grep -q '\[nb\] Commit'
  ! git log | grep -q '\[nb\] Sync'
}

# remote set ##################################################################

@test "'remote set <url>' with no existing remote sets remote and prints message." {
  {
    "${_NB}" init
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" remote

  [[ "${status}"          -eq 0                   ]]

  [[ "${lines[0]}"        =~  Remote\ set\ to     ]]
  [[ "${lines[0]}"        =~  ${_GIT_REMOTE_URL}  ]]

  diff                  \
    <("${_NB}" remote)  \
    <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")
}

@test "'remote set <url>' with existing remote sets remote and prints message." {
  {
    "${_NB}" init

    cd "${NB_DIR}/home" &&
      git remote add origin "https://example.test/example.git"

    diff                  \
      <("${_NB}" remote)  \
      <(printf "https://example.test/example.git (master)\\n")
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"          -eq 0                   ]]

  [[ "${lines[0]}"        =~  Remote\ set\ to     ]]
  [[ "${lines[0]}"        =~  ${_GIT_REMOTE_URL}  ]]

  diff                  \
    <("${_NB}" remote)  \
    <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")
}

@test "'remote set <url>' to same URL as existing remote exits and prints message." {
  {
    "${_NB}" init
    cd "${NB_DIR}/home" &&
      git remote add origin "${_GIT_REMOTE_URL}"
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"          -eq 1                         ]]

  [[ "${lines[0]}"        =~  Remote\ already\ set\ to  ]]
  [[ "${lines[0]}"        =~  ${_GIT_REMOTE_URL}        ]]
  [[ "$("${_NB}" remote)" =~  ${_GIT_REMOTE_URL}        ]]
}

@test "'remote set' with no URL exits with 1 and prints help." {
  {
    "${_NB}" init
  }

  run "${_NB}" remote set --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1       ]]
  [[ "${lines[0]}"  =~  Usage\: ]]
}

# remote remove ###############################################################

@test "'remote remove' with no existing remote returns 1 and prints message." {
  {
    "${_NB}" init
  }

  run "${_NB}" remote remove

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                       ]]
  [[ "${lines[0]}"  =~  No\ remote\ configured  ]]
}

@test "'remote remove' with existing remote removes remote and prints message." {
  {
    "${_NB}" init
    cd "${NB_DIR}/home" &&
      git remote add origin "${_GIT_REMOTE_URL}"
  }

  run "${_NB}" remote remove --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" remote && return 1

  [[ "${status}"                -eq 0                   ]]

  [[ "$("${_NB}" remote 2>&1)"  =~  No\ remote          ]]
  [[ "${lines[0]}"              =~  Removed\ remote     ]]
  [[ "${lines[0]}"              =~  ${_GIT_REMOTE_URL}  ]]
}

@test "'remote unset' with existing remote removes remote and prints message." {
  {
    "${_NB}" init
    cd "${NB_DIR}/home" &&
      git remote add origin "${_GIT_REMOTE_URL}"
  }

  run "${_NB}" remote unset --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" remote && return 1

  [[ "${status}"                -eq 0                   ]]

  [[ "$("${_NB}" remote 2>&1)"  =~  No\ remote          ]]
  [[ "${lines[0]}"              =~  Removed\ remote     ]]
  [[ "${lines[0]}"              =~  ${_GIT_REMOTE_URL}  ]]
}

# help ########################################################################

@test "'help remote' exits with 0 and prints help information." {
  run "${_NB}" help remote

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0               ]]

  [[ "${lines[0]}"  =~  Usage\:         ]]
  [[ "${lines[1]}"  =~  \ \ nb\ remote  ]]
}
