#!/usr/bin/env bats

load test_helper

# alias #######################################################################

@test "'unset remote' with no existing remote returns 1 and prints message." {
  {
    "${_NB}" init
  }

  run "${_NB}" unset remote

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 1                       ]]
  [[ "${lines[0]}"  =~  No\ remote\ configured  ]]
}

# --skip-confirmation #########################################################

@test "'remote remove --skip-confirmation' with existing remote removes remote without resetting default branch and prints message." {
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

  run "${_NB}" remote remove --skip-confirmation <<< "n${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" remote && return 1

  [[ "${status}"    -eq 0 ]]

  [[ "$("${_NB}" remote 2>&1)"  =~  No\ remote\ configured.           ]]

  [[ "${lines[0]}"  =~  Removing\ remote:\ .*${_GIT_REMOTE_URL}       ]]
  [[ "${lines[1]}"  =~  Remote\ removed.                              ]]

  diff                                        \
    <(git -C "${NB_DIR}/home" branch --all)   \
    <(printf "* master\\n")

  # does not reset remote

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

  [[ -f "${_TMP_DIR}/new-clone/Example File.md"                       ]]

  declare _after_hashes=()
  _after_hashes=($(git -C "${_TMP_DIR}/new-clone" rev-list origin/master))

  [[ "${#_after_hashes[@]}" -eq 2                                     ]]

  [[ "${_after_hashes[0]}"  ==  "${_before_hashes[0]}"                ]]
  [[ "${_after_hashes[1]}"  ==  "${_before_hashes[1]}"                ]]

  git -C "${_TMP_DIR}/new-clone" log

  [[    "$(git -C "${_TMP_DIR}/new-clone" log)" =~  \
          \[nb\]\ Add:\ Example\ File\.md             ]]
  [[    "$(git -C "${_TMP_DIR}/new-clone" log)" =~  \
          Initial\ commit\.                           ]]
  [[ !  "$(git -C "${_TMP_DIR}/new-clone" log)" =~  \
          \[nb\]\ Initialize                          ]]
}

@test "'remote remove --skip-confirmation' with existing remote removes remote, resets default branch, and prints message." {
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

  run "${_NB}" remote remove --skip-confirmation <<< "y${_NEWLINE}"

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

  [[      "${lines[0]}"  =~ \*\ master                                  ]]
  [[      "${lines[1]}"  =~ remotes/origin/HEAD\ \-\>\ origin/master    ]]
  [[      "${lines[2]}"  =~ remotes/origin/master                       ]]

  [[ ! -e "${_TMP_DIR}/new-clone/Example File.md"                       ]]

  declare _after_hashes=()
  _after_hashes=($(git -C "${_TMP_DIR}/new-clone" rev-list origin/master))

  [[ "${#_after_hashes[@]}" -eq 1                                       ]]

  ! _contains "${_after_hashes[0]}" "${_before_hashes[@]}"

  [[ "${_after_hashes[0]}"  != "${_before_hashes[0]}"                   ]]
  [[ "${_after_hashes[0]}"  != "${_before_hashes[1]}"                   ]]

  git -C "${_TMP_DIR}/new-clone" log

  [[ "$(git -C "${_TMP_DIR}/new-clone" log)"  =~  \[nb\]\ Initialize    ]]
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

@test "'remote remove' with existing remote removes remote without resetting default branch and prints message." {
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

  run "${_NB}" remote remove <<< "y${_NEWLINE}n${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" remote && return 1

  [[ "${status}"    -eq 0 ]]

  [[ "$("${_NB}" remote 2>&1)"  =~  No\ remote\ configured.           ]]

  [[ "${lines[0]}"  =~  Removing\ remote:\ .*${_GIT_REMOTE_URL}       ]]
  [[ "${lines[1]}"  =~  Remote\ removed.                              ]]

  diff                                        \
    <(git -C "${NB_DIR}/home" branch --all)   \
    <(printf "* master\\n")

  # does not reset remote

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

  [[ -f "${_TMP_DIR}/new-clone/Example File.md"                       ]]

  declare _after_hashes=()
  _after_hashes=($(git -C "${_TMP_DIR}/new-clone" rev-list origin/master))

  [[ "${#_after_hashes[@]}" -eq 2                                     ]]

  [[ "${_after_hashes[0]}"  ==  "${_before_hashes[0]}"                ]]
  [[ "${_after_hashes[1]}"  ==  "${_before_hashes[1]}"                ]]

  git -C "${_TMP_DIR}/new-clone" log

  [[    "$(git -C "${_TMP_DIR}/new-clone" log)" =~  \
          \[nb\]\ Add:\ Example\ File\.md             ]]
  [[    "$(git -C "${_TMP_DIR}/new-clone" log)" =~  \
          Initial\ commit\.                           ]]
  [[ !  "$(git -C "${_TMP_DIR}/new-clone" log)" =~  \
          \[nb\]\ Initialize                          ]]
}

@test "'remote remove' with existing remote removes remote, resets default branch, and prints message." {
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

  [[      "${lines[0]}"  =~ \*\ master                                  ]]
  [[      "${lines[1]}"  =~ remotes/origin/HEAD\ \-\>\ origin/master    ]]
  [[      "${lines[2]}"  =~ remotes/origin/master                       ]]

  [[ ! -e "${_TMP_DIR}/new-clone/Example File.md"                       ]]

  declare _after_hashes=()
  _after_hashes=($(git -C "${_TMP_DIR}/new-clone" rev-list origin/master))

  [[ "${#_after_hashes[@]}" -eq 1                                       ]]

  ! _contains "${_after_hashes[0]}" "${_before_hashes[@]}"

  [[ "${_after_hashes[0]}"  != "${_before_hashes[0]}"                   ]]
  [[ "${_after_hashes[0]}"  != "${_before_hashes[1]}"                   ]]

  git -C "${_TMP_DIR}/new-clone" log

  [[ "$(git -C "${_TMP_DIR}/new-clone" log)"  =~  \[nb\]\ Initialize    ]]
}

@test "'remote unset' with existing remote removes remote, resets default branch, and prints message." {
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

  run "${_NB}" remote unset <<< "y${_NEWLINE}y${_NEWLINE}"

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

  [[      "${lines[0]}"  =~ \*\ master                                  ]]
  [[      "${lines[1]}"  =~ remotes/origin/HEAD\ \-\>\ origin/master    ]]
  [[      "${lines[2]}"  =~ remotes/origin/master                       ]]

  [[ ! -e "${_TMP_DIR}/new-clone/Example File.md"                       ]]

  declare _after_hashes=()
  _after_hashes=($(git -C "${_TMP_DIR}/new-clone" rev-list origin/master))

  [[ "${#_after_hashes[@]}" -eq 1                                       ]]

  ! _contains "${_after_hashes[0]}" "${_before_hashes[@]}"

  [[ "${_after_hashes[0]}"  != "${_before_hashes[0]}"                   ]]
  [[ "${_after_hashes[0]}"  != "${_before_hashes[1]}"                   ]]

  git -C "${_TMP_DIR}/new-clone" log

  [[ "$(git -C "${_TMP_DIR}/new-clone" log)"  =~  \[nb\]\ Initialize    ]]
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

  [[ "$("${_NB}" remote 2>&1)" =~ No\ remote\ configured.           ]]

  [[ "${lines[0]}"  =~  Removing\ remote:\ .*${_GIT_REMOTE_URL}     ]]
  [[ "${lines[1]}"  =~  Remote\ branch\ deleted:\ .*example-branch  ]]
  [[ "${lines[2]}"  =~  Remote\ removed.                            ]]

  diff                                        \
    <(git -C "${NB_DIR}/home" ls-remote       \
        --heads "${_GIT_REMOTE_URL}"          \
        | sed "s/.*\///g" || :)               \
    <(printf "master\\n")

  diff                                        \
    <(git -C "${NB_DIR}/home" branch --all)   \
    <(printf "* example-branch\\n")
}

@test "'remote remove' with existing remote as orphan removes remote without removing remote branch and prints message." {
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

  run "${_NB}" remote remove <<< "y${_NEWLINE}n${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" remote && return 1

  [[ "${status}"    -eq 0 ]]

  [[ "$("${_NB}" remote 2>&1)" =~ No\ remote\ configured.         ]]

  [[ "${lines[0]}"  =~  Removing\ remote:\ .*${_GIT_REMOTE_URL}   ]]
  [[ "${lines[1]}"  =~  Remote\ removed.                          ]]

  diff                                        \
    <(git -C "${NB_DIR}/home" ls-remote       \
        --heads "${_GIT_REMOTE_URL}"          \
        | sed "s/.*\///g" || :)               \
    <(printf "example-branch\\nmaster\\n")

  diff                                        \
    <(git -C "${NB_DIR}/home" branch --all)   \
    <(printf "* example-branch\\n")
}
