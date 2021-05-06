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

    "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}1${_NEWLINE}"

    diff                                      \
      <("${_NB}" remote)                      \
      <(printf "%s (master)\\n" "${_GIT_REMOTE_URL}")

    diff                                      \
      <(git -C "${NB_DIR}/home" branch --all) \
      <(printf "* master\\n  remotes/origin/master\\n")
  }

  run "${_NB}" remote remove <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" remote && return 1

  [[ "${status}"    -eq 0 ]]

  [[ "$("${_NB}" remote 2>&1)" =~ No\ remote\ configured.         ]]

  [[ "${lines[0]}"  =~  Removing\ remote:\ .*${_GIT_REMOTE_URL}   ]]
  [[ "${lines[1]}"  =~  Removed\ \ remote:\ .*${_GIT_REMOTE_URL}  ]]

  diff                                        \
    <(git -C "${NB_DIR}/home" branch --all)   \
    <(printf "* master\\n")

  # does not delete last branch

  diff                                        \
    <(git -C "${NB_DIR}/home" ls-remote       \
        --heads "${_GIT_REMOTE_URL}"          \
        | sed "s/.*\///g" || :)               \
    <(printf "master\\n")
}

@test "'remote unset' with existing remote removes remote and prints message." {
  {
    "${_NB}" init

    _setup_remote_repo

    "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}1${_NEWLINE}"

    diff                                      \
      <("${_NB}" remote)                      \
      <(printf "%s (master)\\n" "${_GIT_REMOTE_URL}")

    diff                                      \
      <(git -C "${NB_DIR}/home" branch --all) \
      <(printf "* master\\n  remotes/origin/master\\n")
  }

  run "${_NB}" remote unset <<< "y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" remote && return 1

  [[ "${status}"    -eq 0 ]]

  [[ "$("${_NB}" remote 2>&1)" =~ No\ remote\ configured.         ]]

  [[ "${lines[0]}"  =~  Removing\ remote:\ .*${_GIT_REMOTE_URL}   ]]
  [[ "${lines[1]}"  =~  Removed\ \ remote:\ .*${_GIT_REMOTE_URL}  ]]

  diff                                        \
    <(git -C "${NB_DIR}/home" branch --all)   \
    <(printf "* master\\n")

  # does not delete last branch

  diff                                        \
    <(git -C "${NB_DIR}/home" ls-remote       \
        --heads "${_GIT_REMOTE_URL}"          \
        | sed "s/.*\///g" || :)               \
    <(printf "master\\n")
}

@test "'remote remove' with existing remote as orphan removes remote, removes branch and prints message." {
  {
    "${_NB}" init

    _setup_remote_repo

    "${_NB}" git branch -m "example-branch"

    "${_NB}" remote add "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}2${_NEWLINE}"

    diff                                      \
      <("${_NB}" remote)                      \
      <(printf "%s (example-branch)\\n" "${_GIT_REMOTE_URL}")

    diff                                      \
      <(git -C "${NB_DIR}/home" branch --all) \
      <(printf "* example-branch\\n  remotes/origin/example-branch\\n")

    diff                                      \
      <(git -C "${NB_DIR}/home" ls-remote     \
          --heads "${_GIT_REMOTE_URL}"        \
          | sed "s/.*\///g" || :)             \
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

  diff                                        \
    <(git -C "${NB_DIR}/home" ls-remote       \
        --heads "${_GIT_REMOTE_URL}"          \
        | sed "s/.*\///g" || :)               \
    <(printf "master\\n")

  diff                                        \
    <(git -C "${NB_DIR}/home" branch --all)   \
    <(printf "* example-branch\\n")
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
