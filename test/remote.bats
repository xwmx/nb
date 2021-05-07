#!/usr/bin/env bats

load test_helper

# remote branches #############################################################

@test "'remote branches' with no existing remote prints message." {
  {
    "${_NB}" init
  }

  run "${_NB}" remote branches

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"


  [[ "${status}"    -eq 1                       ]]
  [[ "${#lines[@]}" -eq 1                       ]]

  [[ "${lines[0]}"  =~  No\ remote\ configured. ]]
}

@test "'remote branches <url>' with no existing remote prints remote branches with current branch highlighted." {
  {
    "${_NB}" init

    _setup_remote_repo
  }

  run "${_NB}" remote branches "${_GIT_REMOTE_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"


  [[ "${status}"    -eq 0                       ]]
  [[ "${#lines[@]}" -eq 1                       ]]

  [[ "${lines[0]}"  =~  .*master.*              ]]
}

@test "'remote branches' with existing remote as orphan prints branches with current branch highlighted." {
  {
    "${_NB}" init

    _setup_remote_repo

    "${_NB}" git branch -m "example-branch"

    "${_NB}" remote add "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}"

    diff                                  \
      <(git -C "${NB_DIR}/home" ls-remote \
          --heads "${_GIT_REMOTE_URL}"    \
          | sed "s/.*\///g" || :)         \
      <(printf "example-branch\\nmaster\\n")
  }

  run "${_NB}" remote branches

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"


  [[ "${status}"    -eq 0                       ]]
  [[ "${#lines[@]}" -eq 2                       ]]

  [[ "${lines[0]}"  =~  .*example-branch.*      ]]
  [[ "${lines[1]}"  ==  "master"                ]]
}
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

    [[ -f "${NB_DIR}/home/example.md"   ]]

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

# help ########################################################################

@test "'help remote' exits with 0 and prints help information." {
  run "${_NB}" help remote

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0               ]]

  [[ "${lines[0]}"  =~  Usage.*\:       ]]
  [[ "${lines[1]}"  =~  \ \ nb\ remote  ]]
}
