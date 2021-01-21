#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

load test_helper

@test "'sync' with different default branch names updates local branch to match remote and syncs successfully." {
  {
    # set up remote

    _setup_remote_repo "example-branch-name"

    diff                                                            \
      <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD            \
          | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}') \
      <(printf "example-branch-name\\n")

    # configure locations for clones

    export NB_DIR_1="${_TMP_DIR}/nbdir-1"
    export NB_DIR_2="${_TMP_DIR}/nbdir-2"

    # create $NB_DIR_1 and assign remote

    export NB_DIR="${NB_DIR_1}"

    "${_NB}" init
    "${_NB}" remote set "${_GIT_REMOTE_URL}" --force

    diff                                                            \
      <(git -C "${NB_DIR_1}/home" rev-parse --abbrev-ref HEAD)      \
      <(printf "master\\n")

    # create $NB_DIR_2 and assign remote

    export NB_DIR="${NB_DIR_2}"

    "${_NB}" init
    "${_NB}" remote set "${_GIT_REMOTE_URL}" --force

    diff                                                            \
      <(git -C "${NB_DIR_2}/home" rev-parse --abbrev-ref HEAD)      \
      <(printf "master\\n")

    # create file in $NB_DIR_1

    export NB_DIR="${NB_DIR_1}"

    NB_AUTO_SYNC=0 "${_NB}" add           \
      "Example Folder/Example File.md"    \
      --content "Example content from 1."

    [[    -f "${NB_DIR_1:-}/home/Example Folder/Example File.md"  ]]
    [[ !  -f "${NB_DIR_2:-}/home/Example Folder/Example File.md"  ]]
  }

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0                                     ]]
  [[    "${output}"   =~  Syncing:\ .*home.*...Done!            ]]

  # $NB_DIR_1 default branch name is updated

  diff                                                            \
    <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD            \
        | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}') \
    <(printf "example-branch-name\\n")

  diff                                                            \
    <(git -C "${NB_DIR_1}/home" rev-parse --abbrev-ref HEAD)      \
    <(printf "example-branch-name\\n")

  diff                                                            \
    <(git -C "${NB_DIR_2}/home" rev-parse --abbrev-ref HEAD)      \
    <(printf "master\\n")


  # file from $NB_DIR_1 is synced to remote, but not other clone

  [[    -f "${NB_DIR_1:-}/home/Example Folder/Example File.md"  ]]
  [[ !  -f "${NB_DIR_2:-}/home/Example Folder/Example File.md"  ]]

  # switch to $NB_DIR_2 and sync

  export NB_DIR="${NB_DIR_2}"

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0                                     ]]
  [[    "${output}"   =~  Syncing:\ .*home.*...Done!            ]]

  # $NB_DIR_2 default branch name is updated

  diff                                                            \
    <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD            \
        | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}') \
    <(printf "example-branch-name\\n")

  diff                                                            \
    <(git -C "${NB_DIR_1}/home" rev-parse --abbrev-ref HEAD)      \
    <(printf "example-branch-name\\n")

  diff                                                            \
    <(git -C "${NB_DIR_2}/home" rev-parse --abbrev-ref HEAD)      \
    <(printf "example-branch-name\\n")


  # file from $NB_DIR_1 is synced from remote to $NB_DIR_2

  [[    -f "${NB_DIR_1:-}/home/Example Folder/Example File.md"  ]]
  [[    -f "${NB_DIR_2:-}/home/Example Folder/Example File.md"  ]]
}
