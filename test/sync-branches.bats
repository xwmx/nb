#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

load test_helper

@test "'remote' and 'sync' with multiple notebooks displays prompts, updates configuration, and syncs successfully." {
  # set up remote

  _setup_remote_repo

  diff                                                            \
    <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD            \
        | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}') \
    <(printf "master\\n")

  # configure locations for clones

  export NB_DIR_1="${_TMP_DIR}/NB_DIR_1"
  export NB_DIR_2="${_TMP_DIR}/NB_DIR_2"
  export NB_DIR_3="${_TMP_DIR}/NB_DIR_3"

  # create $NB_DIR_1 and home notebook

  export NB_DIR="${NB_DIR_1}"

  "${_NB}" init

  diff                                                            \
    <(git -C "${NB_DIR_1}/home" rev-parse --abbrev-ref HEAD)      \
    <(printf "master\\n")

  "${_NB}" add  "Home 1 File One.md"  \
    --title     "Home 1 Title One"    \
    --content   "Home 1 content one."

  [[    -f "${NB_DIR_1}/home/Home 1 File One.md"                  ]]

  # create notebook

  # "${_NB}" notebooks add "Example Notebook"

  # diff                                                                    \
  #   <(git -C "${NB_DIR_1}/Example Notebook" rev-parse --abbrev-ref HEAD)  \
  #   <(printf "master\\n")

  # "${_NB}" use "Example Notebook"

  # "${_NB}" add  "Example 1 File One.md" \
  #   --title     "Example 1 Title One"   \
  #   --content   "Example 1 content one."

  # [[    -f "${NB_DIR_1}/Example Notebook/Example 1 File One.md"   ]]

  # create notebook

  # "${_NB}" notebooks add "Sample Notebook"

  # diff                                                                    \
  #   <(git -C "${NB_DIR_1}/Sample Notebook" rev-parse --abbrev-ref HEAD)   \
  #   <(printf "master\\n")

  # "${_NB}" use "Sample Notebook"

  # "${_NB}" add  "Sample 1 File One.md"  \
  #   --title     "Sample 1 Title One"    \
  #   --content   "Sample 1 content one."

  # [[    -f "${NB_DIR_1}/Sample Notebook/Sample 1 File One.md"     ]]

  # set "home" notebook remote

  "${_NB}" use "home"

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}1${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                         ]]

  [[ "${lines[0]}"  =~  Adding\ remote\ to:\ .*home               ]]
  [[ "${lines[1]}"  =~  [^-]----------------------[^-]            ]]
  [[ "${lines[2]}"  =~  URL:\ \ \ \ .*${_GIT_REMOTE_URL}          ]]
  [[ "${lines[3]}"  =~  Branch:\ .*master                         ]]
  [[ "${lines[4]}"  =~  [^-]--------------[^-]                    ]]
  [[ "${lines[5]}"  =~  \
Remote\ branch\ has\ existing\ content:\ .*master                   ]]
  [[ "${lines[6]}"  =~  \
.*[.*1.*].*\ Sync\ with\ existing\ remote\ content.                 ]]
  [[ "${lines[7]}"  =~  \
.*[.*2.*].*\ Sync\ as\ a\ new\ orphan\ branch\ on\ the\ remote.     ]]
  [[ "${lines[8]}"  =~  \
Remote\ set\ to:\ .*${_GIT_REMOTE_URL}.*\ \(.*master.*\)          ]]

  # sync "home" to remote

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                         ]]

  diff                                                            \
    <(git ls-remote --symref "${_GIT_REMOTE_URL}" HEAD            \
        | awk '/^ref:/ {sub(/refs\/heads\//, "", $2); print $2}') \
    <(printf "master\\n")


  declare _nbdir_1_home_commit_hashes=()
  _nbdir_1_home_commit_hashes=($(
    git -C "${NB_DIR_1}/home" rev-list --all --full-history
  ))

  [[ "${#_nbdir_1_home_commit_hashes[@]}" == "2" ]]

  # create $NB_DIR_2 by cloning remote

  export NB_DIR="${NB_DIR_2}"

  "${_NB}" init "${_GIT_REMOTE_URL}"

  diff                                                            \
    <(git -C "${NB_DIR_2}/home" rev-parse --abbrev-ref HEAD)      \
    <(printf "master\\n")

  [[    -f "${NB_DIR_2}/home/Home 1 File One.md"                  ]]
  [[ !  -f "${NB_DIR_2}/Example Notebook/Example 1 File One.md"   ]]
  [[ !  -f "${NB_DIR_2}/Sample Notebook/Sample 1 File One.md"     ]]

  declare _nbdir_2_home_commit_hashes=()
  _nbdir_2_home_commit_hashes=($(
    git -C "${NB_DIR_2}/home" rev-list --all --full-history
  ))

  [[ "${#_nbdir_2_home_commit_hashes[@]}" == "2" ]]

  diff                                                            \
    <(printf "%s\\n" "${_nbdir_1_home_commit_hashes[@]:-}")       \
    <(printf "%s\\n" "${_nbdir_2_home_commit_hashes[@]:-}")

  # initialize $NB_DIR_3

  export NB_DIR="${NB_DIR_3}"

  "${_NB}" init

  diff                                                            \
    <(git -C "${NB_DIR_3}/home" rev-parse --abbrev-ref HEAD)      \
    <(printf "master\\n")

  "${_NB}" add  "Home 3 File One.md"  \
    --title     "Home 3 Title One"    \
    --content   "Home 3 content one."

  "${_NB}" add  "Home 3 File Two.md"  \
    --title     "Home 3 Title Two"    \
    --content   "Home 3 content Two."

  [[    -f "${NB_DIR_3}/home/Home 3 File One.md"                  ]]
  [[ !  -f "${NB_DIR_3}/home/Home 1 File One.md"                  ]]

  # declare _nbdir_3_home_commit_hashes_before_sync=()
  # _nbdir_3_home_commit_hashes_before_sync=($(
  #   git -C "${NB_DIR_3}/home" rev-list --all --full-history
  # ))

  # add remote

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}1${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                         ]]

  # sync

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                         ]]

  [[    -f "${NB_DIR_3}/home/Home 3 File One.md"                  ]]
  [[    -f "${NB_DIR_3}/home/Home 1 File One.md"                  ]]

  # verify rebased:

  declare _nbdir_3_home_commit_hashes=()
  _nbdir_3_home_commit_hashes=($(
    git -C "${NB_DIR_3}/home" rev-list --all --full-history
  ))

  [[ "${#_nbdir_3_home_commit_hashes[@]}" == "4" ]]

  diff                                                            \
    <(printf "%s\\n" "${_nbdir_1_home_commit_hashes[0]:-}")       \
    <(printf "%s\\n" "${_nbdir_3_home_commit_hashes[2]:-}")

  diff                                                            \
    <(printf "%s\\n" "${_nbdir_1_home_commit_hashes[1]:-}")       \
    <(printf "%s\\n" "${_nbdir_3_home_commit_hashes[3]:-}")

  diff                                                            \
    <(printf "%s\\n" "${_nbdir_1_home_commit_hashes[1]:-}")       \
    <(git -C "${NB_DIR_3}/home" rev-list --max-parents=0 HEAD)

  diff                                                            \
    <(git -C "${NB_DIR_1}/home" rev-list --max-parents=0 HEAD)    \
    <(git -C "${NB_DIR_3}/home" rev-list --max-parents=0 HEAD)

  # switch to $NB_DIR_1 and create new notebook

  export NB_DIR="${NB_DIR_1}"

  "${_NB}" notebooks add "Example Notebook"

  diff                                                                    \
    <(git -C "${NB_DIR_1}/Example Notebook" rev-parse --abbrev-ref HEAD)  \
    <(printf "master\\n")

  "${_NB}" use "Example Notebook"

  "${_NB}" add  "Example 1 File One.md" \
    --title     "Example 1 Title One"   \
    --content   "Example 1 content one."

  [[    -f "${NB_DIR_1}/Example Notebook/Example 1 File One.md"   ]]

  # set new notebook remote

  run "${_NB}" remote add "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}1${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                         ]]

}

@test "'sync' with different branch names displays prompts, updates local branch to match remote, and syncs successfully." {
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
    "${_NB}" git remote add origin "${_GIT_REMOTE_URL}"

    diff                                                            \
      <(git -C "${NB_DIR_1}/home" rev-parse --abbrev-ref HEAD)      \
      <(printf "master\\n")

    # create $NB_DIR_2 and assign remote

    export NB_DIR="${NB_DIR_2}"

    "${_NB}" init
    "${_NB}" git remote add origin "${_GIT_REMOTE_URL}"

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

  run "${_NB}" sync  <<< "y${_NEWLINE}1${_NEWLINE}1${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0                                       ]]
  [[    "${output}"   =~  Syncing:\ .*home.*...Done!              ]]

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

  [[    -f "${NB_DIR_1:-}/home/Example Folder/Example File.md"    ]]
  [[ !  -f "${NB_DIR_2:-}/home/Example Folder/Example File.md"    ]]

  # switch to $NB_DIR_2 and sync

  export NB_DIR="${NB_DIR_2}"

  run "${_NB}" sync <<< "y${_NEWLINE}1${_NEWLINE}1${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 0                                       ]]
  [[    "${output}"   =~  Syncing:\ .*home.*...Done!              ]]

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

  [[    -f "${NB_DIR_1:-}/home/Example Folder/Example File.md"    ]]
  [[    -f "${NB_DIR_2:-}/home/Example Folder/Example File.md"    ]]
}
