#!/usr/bin/env bats

load test_helper

# remote remove ###############################################################

@test "'remote remove' with no existing remote returns 1 and prints message." {
  {
    "${_NB}" init

    _setup_remote_repo
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

    _setup_remote_repo

    cd "${NB_DIR}/home" &&
      git remote add origin "${_GIT_REMOTE_URL}"
  }

  run "${_NB}" remote remove <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" remote && return 1

  [[ "${status}"    -eq 0 ]]

  [[ "$("${_NB}" remote 2>&1)" =~ No\ remote\ configured.         ]]

  [[ "${lines[0]}"  =~  Removing\ remote:\ .*${_GIT_REMOTE_URL}   ]]
  [[ "${lines[1]}"  =~  Removed\ \ remote:\ .*${_GIT_REMOTE_URL}  ]]
}

@test "'remote unset' with existing remote removes remote and prints message." {
  {
    "${_NB}" init

    _setup_remote_repo

    cd "${NB_DIR}/home" &&
      git remote add origin "${_GIT_REMOTE_URL}"

    diff                                  \
      <(git -C "${NB_DIR}/home" ls-remote \
          --heads "${_GIT_REMOTE_URL}"    \
          | sed "s/.*\///g" || :)         \
      <(printf "master\\n")
  }

  run "${_NB}" remote unset <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" remote && return 1

  [[ "${status}"    -eq 0 ]]

  [[ "$("${_NB}" remote 2>&1)" =~ No\ remote\ configured.         ]]

  [[ "${lines[0]}"  =~  Removing\ remote:\ .*${_GIT_REMOTE_URL}   ]]
  [[ "${lines[1]}"  =~  Removed\ \ remote:\ .*${_GIT_REMOTE_URL}  ]]

  # does not delete last branch

  diff                                  \
    <(git -C "${NB_DIR}/home" ls-remote \
        --heads "${_GIT_REMOTE_URL}"    \
        | sed "s/.*\///g" || :)         \
    <(printf "master\\n")
}

@test "'remote remove' with existing remote as orphan removes remote, removes branch and prints message." {
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

  run "${_NB}" remote remove <<< "y${_NEWLINE}y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" remote && return 1

  [[ "${status}"    -eq 0 ]]

  [[ "$("${_NB}" remote 2>&1)" =~ No\ remote\ configured.         ]]

  [[ "${lines[0]}"  =~  Removing\ remote:\ .*${_GIT_REMOTE_URL}   ]]
  [[ "${lines[1]}"  =~  Removed\ \ remote:\ .*${_GIT_REMOTE_URL}  ]]

    diff                                  \
      <(git -C "${NB_DIR}/home" ls-remote \
          --heads "${_GIT_REMOTE_URL}"    \
          | sed "s/.*\///g" || :)         \
      <(printf "master\\n")
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

# help ########################################################################

@test "'help remote' exits with 0 and prints help information." {
  run "${_NB}" help remote

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0               ]]

  [[ "${lines[0]}"  =~  Usage\:         ]]
  [[ "${lines[1]}"  =~  \ \ nb\ remote  ]]
}
