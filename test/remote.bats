#!/usr/bin/env bats

load test_helper

# remote remove and set #######################################################

@test "'remote remove' deletes remote branch and 'remote set' rebases onto initialized remote." {
  {
    "${_NB}" init

    "${_NB}" add "Example File.md" --content "Example content."

    _setup_remote_repo

    "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}1${_NEWLINE}"

    diff                                      \
      <("${_NB}" remote)                      \
      <(printf "%s (master)\\n" "${_GIT_REMOTE_URL}")

    diff                                      \
      <(git -C "${NB_DIR}/home" branch --all) \
      <(printf "* master\\n  remotes/origin/master\\n")

    declare _before_hashes=()
    _before_hashes=($("${_NB}" git rev-list origin/master))

    [[ "${#_before_hashes[@]}"  -eq 2                                 ]]

    [[ "$("${_NB}" git log)"    =~  \[nb\]\ Add:\ Example\ File\.md   ]]
    [[ "$("${_NB}" git log)"    =~  Initial\ commit\.                 ]]
  }

  run "${_NB}" remote remove <<< "y${_NEWLINE}y${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" remote && return 1

  [[ "${status}"    -eq 0 ]]

  [[ "$("${_NB}" remote 2>&1)" =~ No\ remote\ configured.             ]]

  [[ "${lines[0]}"  =~  Removing\ remote:\ .*${_GIT_REMOTE_URL}       ]]
  [[ "${lines[1]}"  =~  Remote\ branch\ reset:\ .*master              ]]
  [[ "${lines[2]}"  =~  Remote\ removed.                              ]]

  diff                                        \
    <(git -C "${NB_DIR}/home" branch --all)   \
    <(printf "* master\\n")

  # resets remote

  diff                                        \
    <(git -C "${NB_DIR}/home" ls-remote       \
        --heads "${_GIT_REMOTE_URL}"          \
        | sed "s/.*\///g" || :)               \
    <(printf "master\\n")

  git clone "${_GIT_REMOTE_URL}" "${_TMP_DIR}/new-clone"

  run git -C "${_TMP_DIR}/new-clone" branch --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${lines[0]}"  =~ \*\ master                                  ]]
  [[    "${lines[1]}"  =~ remotes/origin/HEAD\ \-\>\ origin/master    ]]
  [[    "${lines[2]}"  =~ remotes/origin/master                       ]]

  declare _after_hashes=()
  _after_hashes=($(git -C "${_TMP_DIR}/new-clone" rev-list origin/master))

  printf "_after_hashes: %s\\n" "${_after_hashes[@]}"

  [[ "${#_after_hashes[@]}" -eq 1                                     ]]

  ! _contains "${_after_hashes[0]}" "${_before_hashes[@]}"

  [[ "${_after_hashes[0]}"  != "${_before_hashes[0]}"                 ]]
  [[ "${_after_hashes[0]}"  != "${_before_hashes[1]}"                 ]]

  git -C "${_TMP_DIR}/new-clone" log

  [[ "$(git -C "${_TMP_DIR}/new-clone" log)"  =~  \[nb\]\ Initialize  ]]

  {
    sleep 1

    "${_NB}" notebooks add "Sample Notebook"
    "${_NB}" notebooks use "Sample Notebook"

    "${_NB}" add "Sample File.md" --content "Sample content."

    declare _new_before_hashes=()
    _new_before_hashes=($("${_NB}" git rev-list master))

    printf "_new_before_hashes: %s\\n" "${_new_before_hashes[@]}"

    [[ "${#_new_before_hashes[@]}"  -eq 2                                 ]]

    [[ "$("${_NB}" git log)"        =~  \[nb\]\ Add:\ Sample\ File\.md    ]]
    [[ "$("${_NB}" git log)"        =~  Initialize                        ]]
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}1${_NEWLINE}1${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" remote

  [[ "${status}"    -eq 0 ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*Sample\ Notebook           ]]
  [[ "${lines[1]}"  =~  [^-]---------------------------------[^-]         ]]
  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}                  ]]
  [[ "${lines[3]}"  =~  Branch:\ .*master                                 ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                            ]]
  [[ "${lines[5]}"  =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*master.*\)                  ]]

  diff                  \
    <("${_NB}" remote)  \
    <(printf "%s (master)\\n" "${_GIT_REMOTE_URL:-}")

  git clone  "${_GIT_REMOTE_URL}" "${_TMP_DIR}/new-clone-2"

  run git -C "${_TMP_DIR}/new-clone-2" branch --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${lines[0]}"  =~ \*\ master                                  ]]
  [[    "${lines[1]}"  =~ remotes/origin/HEAD\ \-\>\ origin/master    ]]
  [[    "${lines[2]}"  =~ remotes/origin/master                       ]]

  [[ -f "${_TMP_DIR}/new-clone-2/Sample File.md" ]]

  declare _new_after_hashes=()
  _new_after_hashes=($(git -C "${_TMP_DIR}/new-clone-2" rev-list origin/master))

  printf "_new_after_hashes: %s\\n" "${_new_after_hashes[@]}"

  git -C "${_TMP_DIR}/new-clone-2" log

  [[ "${#_new_after_hashes[@]}" -eq 2                                   ]]

  ! _contains "${_new_after_hashes[0]}" "${_new_before_hashes[@]}"

  [[ "${_new_after_hashes[1]}"  == "${_after_hashes[0]}"                ]]
  [[ "${_new_after_hashes[0]}"  != "${_new_before_hashes[1]}"           ]]
  [[ "${_new_after_hashes[0]}"  != "${_new_before_hashes[0]}"           ]]

  [[ "$(git -C "${_TMP_DIR}/new-clone-2" log)"  =~  \[nb\]\ Initialize  ]]
}

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
