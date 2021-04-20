#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

load test_helper

_setup_notebooks() {
  _setup_remote_repo

  export NB_DIR_1="${_TMP_DIR}/nbdir-1"
  export NB_DIR_2="${_TMP_DIR}/nbdir-2"

  export NB_DIR="${NB_DIR_1}"

  "${_NB}" init "${_GIT_REMOTE_URL}"

  export NB_DIR="${NB_DIR_2}"

  "${_NB}" init "${_GIT_REMOTE_URL}"

  export NB_DIR="${NB_DIR_1}"
}

# sync --all #################################################################

@test "'sync --all' with no local syncs global notebooks with a folder." {
  export NB_AUTO_SYNC=0

  {
    _setup_notebooks

    # global-remote

    "${_NB}" notebooks add global-remote "${_GIT_REMOTE_URL}"

    run "${_NB}" global-remote:add      \
      "Example Folder/global-remote.md" \
      --content "Example content from global-remote."

    [[ "${status}" -eq 0 ]]

    # NB_DIR_1

    [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/archived.md"         ]]
    [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/global-remote.md"    ]]
    [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/global-no-remote.md" ]]

    [[ ! -f "${NB_DIR_1}/global-remote/Example Folder/archived.md"            ]]
    [[   -f "${NB_DIR_1}/global-remote/Example Folder/global-remote.md"       ]]
    [[ ! -f "${NB_DIR_1}/global-remote/Example Folder/global-no-remote.md"    ]]

    [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/archived.md"         ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/global-remote.md"    ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/global-no-remote.md" ]]

    [[ ! -f "${NB_DIR_1}/home/Example Folder/example-archived.md"             ]]
    [[ ! -f "${NB_DIR_1}/home/Example Folder/global-remote.md"                ]]
    [[ ! -f "${NB_DIR_1}/home/Example Folder/global-no-remote.md"             ]]

    # NB_DIR_2

    [[ ! -f "${NB_DIR_2}/home/Example Folder/archived.md"                     ]]
    [[ ! -f "${NB_DIR_2}/home/Example Folder/global-remote.md"                ]]
    [[ ! -f "${NB_DIR_2}/home/Example Folder/global-no-remote.md"             ]]

    # global-no-remote

    "${_NB}" notebooks add global-no-remote

    run "${_NB}" global-no-remote:add       \
      "Example Folder/global-no-remote.md"  \
      --content "Example content from global-no-remote."

    [[ "${status}" -eq 0 ]]

    # NB_DIR_1

    [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/archived.md"         ]]
    [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/global-remote.md"    ]]
    [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/global-no-remote.md" ]]

    [[ ! -f "${NB_DIR_1}/global-remote/Example Folder/archived.md"            ]]
    [[   -f "${NB_DIR_1}/global-remote/Example Folder/global-remote.md"       ]]
    [[ ! -f "${NB_DIR_1}/global-remote/Example Folder/global-no-remote.md"    ]]

    [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/archived.md"         ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/global-remote.md"    ]]
    [[   -f "${NB_DIR_1}/global-no-remote/Example Folder/global-no-remote.md" ]]

    [[ ! -f "${NB_DIR_1}/home/Example Folder/example-archived.md"             ]]
    [[ ! -f "${NB_DIR_1}/home/Example Folder/global-remote.md"                ]]
    [[ ! -f "${NB_DIR_1}/home/Example Folder/global-no-remote.md"             ]]

    # NB_DIR_2

    [[ ! -f "${NB_DIR_2}/home/Example Folder/archived.md"                     ]]
    [[ ! -f "${NB_DIR_2}/home/Example Folder/global-remote.md"                ]]
    [[ ! -f "${NB_DIR_2}/home/Example Folder/global-no-remote.md"             ]]

    # example-archived

    "${_NB}" notebooks add example-archived "${_GIT_REMOTE_URL}"
    "${_NB}" notebooks archive example-archived
    run "${_NB}" example-archived:add \
      "Example Folder/archived.md"    \
      --content "Example content from example-archived."

    [[ "${status}" -eq 0 ]]

    # NB_DIR_1

    [[   -f "${NB_DIR_1}/example-archived/Example Folder/archived.md"         ]]
    [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/global-remote.md"    ]]
    [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/global-no-remote.md" ]]

    [[ ! -f "${NB_DIR_1}/global-remote/Example Folder/archived.md"            ]]
    [[   -f "${NB_DIR_1}/global-remote/Example Folder/global-remote.md"       ]]
    [[ ! -f "${NB_DIR_1}/global-remote/Example Folder/global-no-remote.md"    ]]

    [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/archived.md"         ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/global-remote.md"    ]]
    [[   -f "${NB_DIR_1}/global-no-remote/Example Folder/global-no-remote.md" ]]

    [[ ! -f "${NB_DIR_1}/home/Example Folder/example-archived.md"             ]]
    [[ ! -f "${NB_DIR_1}/home/Example Folder/global-remote.md"                ]]
    [[ ! -f "${NB_DIR_1}/home/Example Folder/global-no-remote.md"             ]]

    # NB_DIR_2

    [[ ! -f "${NB_DIR_2}/home/Example Folder/archived.md"                     ]]
    [[ ! -f "${NB_DIR_2}/home/Example Folder/global-remote.md"                ]]
    [[ ! -f "${NB_DIR_2}/home/Example Folder/global-no-remote.md"             ]]
  }

  # sync 1: send changes to remote
  run "${_NB}" sync --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${output}" =~ \
    Syncing:\ .*global-remote.*....*home.*...Done!            ]]
  [[ ! "${output}" =~ local                                   ]]
  [[ ! "${output}" =~ archived                                ]]
  [[ ! "${output}" =~ no-remote                               ]]

  [[ "${status}" -eq 0                                        ]]

  # sync 2: sync all again to get changes
  run "${_NB}" sync --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${output}" =~ \
    Syncing:\ .*global-remote.*....*home.*...Done!            ]]
  [[ ! "${output}" =~ local                                   ]]
  [[ ! "${output}" =~ archived                                ]]
  [[ ! "${output}" =~ no-remote                               ]]

  [[ "${status}" -eq 0                                        ]]

  # NB_DIR_1

  [[   -f "${NB_DIR_1}/example-archived/Example Folder/archived.md"         ]]
  [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/global-remote.md"    ]]
  [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/global-no-remote.md" ]]

  [[ ! -f "${NB_DIR_1}/global-remote/Example Folder/archived.md"            ]]
  [[   -f "${NB_DIR_1}/global-remote/Example Folder/global-remote.md"       ]]
  [[ ! -f "${NB_DIR_1}/global-remote/Example Folder/global-no-remote.md"    ]]

  [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/archived.md"         ]]
  [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/global-remote.md"    ]]
  [[   -f "${NB_DIR_1}/global-no-remote/Example Folder/global-no-remote.md" ]]

  [[ ! -f "${NB_DIR_1}/home/Example Folder/example-archived.md"             ]]
  [[   -f "${NB_DIR_1}/home/Example Folder/global-remote.md"                ]]
  [[ ! -f "${NB_DIR_1}/home/Example Folder/global-no-remote.md"             ]]

  # NB_DIR_2

  [[ ! -f "${NB_DIR_2}/home/Example Folder/archived.md"                     ]]
  [[ ! -f "${NB_DIR_2}/home/Example Folder/global-remote.md"                ]]
  [[ ! -f "${NB_DIR_2}/home/Example Folder/global-no-remote.md"             ]]
}

# local notebook ##############################################################

@test "'sync --all' with local syncs local and global notebooks with a folder." {
  export NB_AUTO_SYNC=0

  {
    _setup_notebooks

    # global-remote

    "${_NB}" notebooks add global-remote "${_GIT_REMOTE_URL}"

    run "${_NB}" global-remote:add      \
      "Example Folder/global-remote.md" \
      --content "Example content from global-remote."

    [[ "${status}" -eq 0 ]]

    # NB_DIR_1

    [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/archived.md"         ]]
    [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/global-remote.md"    ]]
    [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/global-no-remote.md" ]]
    [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/local.md"            ]]

    [[ ! -f "${NB_DIR_1}/global-remote/Example Folder/archived.md"            ]]
    [[   -f "${NB_DIR_1}/global-remote/Example Folder/global-remote.md"       ]]
    [[ ! -f "${NB_DIR_1}/global-remote/Example Folder/global-no-remote.md"    ]]
    [[ ! -f "${NB_DIR_1}/global-remote/Example Folder/local.md"               ]]

    [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/archived.md"         ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/global-remote.md"    ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/global-no-remote.md" ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/local.md"            ]]

    [[ ! -f "${NB_DIR_1}/home/Example Folder/example-archived.md"             ]]
    [[ ! -f "${NB_DIR_1}/home/Example Folder/global-remote.md"                ]]
    [[ ! -f "${NB_DIR_1}/home/Example Folder/global-no-remote.md"             ]]
    [[ ! -f "${NB_DIR_1}/home/Example Folder/local.md"                        ]]

    # NB_DIR_2

    [[ ! -f "${NB_DIR_2}/home/Example Folder/archived.md"                     ]]
    [[ ! -f "${NB_DIR_2}/home/Example Folder/global-remote.md"                ]]
    [[ ! -f "${NB_DIR_2}/home/Example Folder/global-no-remote.md"             ]]
    [[ ! -f "${NB_DIR_2}/home/Example Folder/local.md"                        ]]

    # local

    [[ ! -f "${_TMP_DIR}/example-local/Example Folder/archived.md"            ]]
    [[ ! -f "${_TMP_DIR}/example-local/Example Folder/global-remote.md"       ]]
    [[ ! -f "${_TMP_DIR}/example-local/Example Folder/global-no-remote.md"    ]]
    [[ ! -f "${_TMP_DIR}/example-local/Example Folder/local.md"               ]]

    # global-no-remote

    "${_NB}" notebooks add global-no-remote

    run "${_NB}" global-no-remote:add       \
      "Example Folder/global-no-remote.md"  \
      --content "Example content from global-no-remote."

    [[ "${status}" -eq 0 ]]

    # NB_DIR_1

    [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/archived.md"         ]]
    [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/global-remote.md"    ]]
    [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/global-no-remote.md" ]]
    [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/local.md"            ]]

    [[ ! -f "${NB_DIR_1}/global-remote/Example Folder/archived.md"            ]]
    [[   -f "${NB_DIR_1}/global-remote/Example Folder/global-remote.md"       ]]
    [[ ! -f "${NB_DIR_1}/global-remote/Example Folder/global-no-remote.md"    ]]
    [[ ! -f "${NB_DIR_1}/global-remote/Example Folder/local.md"               ]]

    [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/archived.md"         ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/global-remote.md"    ]]
    [[   -f "${NB_DIR_1}/global-no-remote/Example Folder/global-no-remote.md" ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/local.md"            ]]

    [[ ! -f "${NB_DIR_1}/home/Example Folder/example-archived.md"             ]]
    [[ ! -f "${NB_DIR_1}/home/Example Folder/global-remote.md"                ]]
    [[ ! -f "${NB_DIR_1}/home/Example Folder/global-no-remote.md"             ]]
    [[ ! -f "${NB_DIR_1}/home/Example Folder/local.md"                        ]]

    # NB_DIR_2

    [[ ! -f "${NB_DIR_2}/home/Example Folder/archived.md"                     ]]
    [[ ! -f "${NB_DIR_2}/home/Example Folder/global-remote.md"                ]]
    [[ ! -f "${NB_DIR_2}/home/Example Folder/global-no-remote.md"             ]]
    [[ ! -f "${NB_DIR_2}/home/Example Folder/local.md"                        ]]

    # local

    [[ ! -f "${_TMP_DIR}/example-local/Example Folder/archived.md"            ]]
    [[ ! -f "${_TMP_DIR}/example-local/Example Folder/global-remote.md"       ]]
    [[ ! -f "${_TMP_DIR}/example-local/Example Folder/global-no-remote.md"    ]]
    [[ ! -f "${_TMP_DIR}/example-local/Example Folder/local.md"               ]]

    # example-archived

    "${_NB}" notebooks add example-archived "${_GIT_REMOTE_URL}"
    "${_NB}" notebooks archive example-archived

    run "${_NB}" example-archived:add \
      "Example Folder/archived.md"    \
      --content "Example content from example-archived."

    [[ "${status}" -eq 0 ]]

    # NB_DIR_1

    [[   -f "${NB_DIR_1}/example-archived/Example Folder/archived.md"         ]]
    [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/global-remote.md"    ]]
    [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/global-no-remote.md" ]]
    [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/local.md"            ]]

    [[ ! -f "${NB_DIR_1}/global-remote/Example Folder/archived.md"            ]]
    [[   -f "${NB_DIR_1}/global-remote/Example Folder/global-remote.md"       ]]
    [[ ! -f "${NB_DIR_1}/global-remote/Example Folder/global-no-remote.md"    ]]
    [[ ! -f "${NB_DIR_1}/global-remote/Example Folder/local.md"               ]]

    [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/archived.md"         ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/global-remote.md"    ]]
    [[   -f "${NB_DIR_1}/global-no-remote/Example Folder/global-no-remote.md" ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/local.md"            ]]

    [[ ! -f "${NB_DIR_1}/home/Example Folder/example-archived.md"             ]]
    [[ ! -f "${NB_DIR_1}/home/Example Folder/global-remote.md"                ]]
    [[ ! -f "${NB_DIR_1}/home/Example Folder/global-no-remote.md"             ]]
    [[ ! -f "${NB_DIR_1}/home/Example Folder/local.md"                        ]]

    # NB_DIR_2

    [[ ! -f "${NB_DIR_2}/home/Example Folder/archived.md"                     ]]
    [[ ! -f "${NB_DIR_2}/home/Example Folder/global-remote.md"                ]]
    [[ ! -f "${NB_DIR_2}/home/Example Folder/global-no-remote.md"             ]]
    [[ ! -f "${NB_DIR_2}/home/Example Folder/local.md"                        ]]

    # local

    [[ ! -f "${_TMP_DIR}/example-local/Example Folder/archived.md"            ]]
    [[ ! -f "${_TMP_DIR}/example-local/Example Folder/global-remote.md"       ]]
    [[ ! -f "${_TMP_DIR}/example-local/Example Folder/global-no-remote.md"    ]]
    [[ ! -f "${_TMP_DIR}/example-local/Example Folder/local.md"               ]]

    run "${_NB}" notebooks init "${_TMP_DIR}/example-local" "${_GIT_REMOTE_URL}"

    cd "${_TMP_DIR}/example-local"

    [[ "$(pwd)" == "${_TMP_DIR}/example-local"            ]]

    [[ ${status} -eq 0                                    ]]
    [[ "$("${_NB}" remote --url)" == "${_GIT_REMOTE_URL}" ]]

    "${_NB}" notebooks current --local

    run "${_NB}" add            \
      "Example Folder/local.md" \
      --content "Example content from local."

    [[ "${status}" -eq 0 ]]

    # NB_DIR_1

    [[   -f "${NB_DIR_1}/example-archived/Example Folder/archived.md"         ]]
    [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/global-remote.md"    ]]
    [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/global-no-remote.md" ]]
    [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/local.md"            ]]

    [[ ! -f "${NB_DIR_1}/global-remote/Example Folder/archived.md"            ]]
    [[   -f "${NB_DIR_1}/global-remote/Example Folder/global-remote.md"       ]]
    [[ ! -f "${NB_DIR_1}/global-remote/Example Folder/global-no-remote.md"    ]]
    [[ ! -f "${NB_DIR_1}/global-remote/Example Folder/local.md"               ]]

    [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/archived.md"         ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/global-remote.md"    ]]
    [[   -f "${NB_DIR_1}/global-no-remote/Example Folder/global-no-remote.md" ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/local.md"            ]]

    [[ ! -f "${NB_DIR_1}/home/Example Folder/example-archived.md"             ]]
    [[ ! -f "${NB_DIR_1}/home/Example Folder/global-remote.md"                ]]
    [[ ! -f "${NB_DIR_1}/home/Example Folder/global-no-remote.md"             ]]
    [[ ! -f "${NB_DIR_1}/home/Example Folder/local.md"                        ]]

    # NB_DIR_2

    [[ ! -f "${NB_DIR_2}/home/Example Folder/archived.md"                     ]]
    [[ ! -f "${NB_DIR_2}/home/Example Folder/global-remote.md"                ]]
    [[ ! -f "${NB_DIR_2}/home/Example Folder/global-no-remote.md"             ]]
    [[ ! -f "${NB_DIR_2}/home/Example Folder/local.md"                        ]]

    # local

    [[ ! -f "${_TMP_DIR}/example-local/Example Folder/archived.md"            ]]
    [[ ! -f "${_TMP_DIR}/example-local/Example Folder/global-remote.md"       ]]
    [[ ! -f "${_TMP_DIR}/example-local/Example Folder/global-no-remote.md"    ]]
    [[   -f "${_TMP_DIR}/example-local/Example Folder/local.md"               ]]
  }

  # sync 1: send changes to remote
  run "${_NB}" sync --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ! "${output}" =~ \
    Syncing:\ .*local.*....*local.*....*global-remote.*....*home.*...Done!  ]]
  [[   "${output}" =~ \
    Syncing:\ .*local.*....*global-remote.*....*home.*...Done!              ]]

  [[ ! "${output}" =~ archived  ]]
  [[ ! "${output}" =~ no-remote ]]

  [[ "${status}" -eq 0          ]]

  # sync 2: sync all again to get changes
  run "${_NB}" sync --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"


  [[ ! "${output}" =~ \
    Syncing:\ .*local.*....*local.*....*global-remote.*....*home.*...Done!  ]]
  [[   "${output}" =~ \
    Syncing:\ .*local.*....*global-remote.*....*home.*...Done!              ]]

  [[ ! "${output}" =~ archived  ]]
  [[ ! "${output}" =~ no-remote ]]

  [[ "${status}" -eq 0          ]]

  # NB_DIR_1

  [[   -f "${NB_DIR_1}/example-archived/Example Folder/archived.md"         ]]
  [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/global-remote.md"    ]]
  [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/global-no-remote.md" ]]
  [[ ! -f "${NB_DIR_1}/example-archived/Example Folder/local.md"            ]]

  [[ ! -f "${NB_DIR_1}/global-remote/Example Folder/archived.md"            ]]
  [[   -f "${NB_DIR_1}/global-remote/Example Folder/global-remote.md"       ]]
  [[ ! -f "${NB_DIR_1}/global-remote/Example Folder/global-no-remote.md"    ]]
  [[   -f "${NB_DIR_1}/global-remote/Example Folder/local.md"               ]]

  [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/archived.md"         ]]
  [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/global-remote.md"    ]]
  [[   -f "${NB_DIR_1}/global-no-remote/Example Folder/global-no-remote.md" ]]
  [[ ! -f "${NB_DIR_1}/global-no-remote/Example Folder/local.md"            ]]

  [[ ! -f "${NB_DIR_1}/home/Example Folder/example-archived.md"             ]]
  [[   -f "${NB_DIR_1}/home/Example Folder/global-remote.md"                ]]
  [[ ! -f "${NB_DIR_1}/home/Example Folder/global-no-remote.md"             ]]
  [[   -f "${NB_DIR_1}/home/Example Folder/local.md"                        ]]

  # NB_DIR_2

  [[ ! -f "${NB_DIR_2}/home/Example Folder/archived.md"                     ]]
  [[ ! -f "${NB_DIR_2}/home/Example Folder/global-remote.md"                ]]
  [[ ! -f "${NB_DIR_2}/home/Example Folder/global-no-remote.md"             ]]
  [[ ! -f "${NB_DIR_2}/home/Example Folder/local.md"                        ]]

  # local

  [[ ! -f "${_TMP_DIR}/example-local/Example Folder/archived.md"            ]]
  [[   -f "${_TMP_DIR}/example-local/Example Folder/global-remote.md"       ]]
  [[ ! -f "${_TMP_DIR}/example-local/Example Folder/global-no-remote.md"    ]]
  [[   -f "${_TMP_DIR}/example-local/Example Folder/local.md"               ]]
}

@test "'sync' succeeds with local notebook with a folder." {
  {
    _setup_notebooks

    run "${_NB}" notebooks init "${_TMP_DIR}/example-local"

    cd "${_TMP_DIR}/example-local"

    [[ "$(pwd)" == "${_TMP_DIR}/example-local" ]]

    run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}1${_NEWLINE}"


    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    [[ ${status} -eq 0                                    ]]
    [[ "$("${_NB}" remote --url)" == "${_GIT_REMOTE_URL}" ]]
    [[ "${output}"                =~ Remote\ set\ to      ]]
    [[ "${output}"                =~ ${_GIT_REMOTE_URL}   ]]

    "${_NB}" notebooks current --local

    run "${_NB}" add            \
      "Example Folder/local.md" \
      --content "Example content from local."

    [[ "${status}" -eq 0                                      ]]
    [[ -f "${_TMP_DIR}/example-local/Example Folder/local.md" ]]
    [[ ! -f "${NB_DIR_1}/home/Example Folder/local.md"        ]]
  }

  # sync 1: send changes to remote
  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0                                      ]]
  [[ -f "${_TMP_DIR}/example-local/Example Folder/local.md" ]]
  [[ ! -f "${NB_DIR_1}/home/Example Folder/local.md"        ]]

  cd ..

  "${_NB}" notebooks current --local || true

  # sync 2: pull changes from remote
  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0                                      ]]
  [[ -f "${_TMP_DIR}/example-local/Example Folder/local.md" ]]
  [[ -f "${NB_DIR_1}/home/Example Folder/local.md"          ]]
}

# sync ########################################################################

@test "'sync' succeeds when files are added and removed from two clones within a folder." {
  # skip
  {
    _setup_notebooks
    "${_NB}" add "Example Folder/one.md" --content "Example content from 1."

    export NB_DIR="${NB_DIR_2}"
    "${_NB}" add "Example Folder/two.md" --content "Example content from 2."

    export NB_DIR="${NB_DIR_1}"
  }

  # sync 1: send changes to remote
  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "(1)\\n"
  printf "index 1:\\n"
  cat "${NB_DIR_1}/home/Example Folder/.index"
  printf "index 2:\\n"
  cat "${NB_DIR_2}/home/Example Folder/.index"

  [[ "${status}" -eq 0 ]]

  diff                                                      \
    <(NB_DIR="${NB_DIR_1}" "${_NB}" count Example\ Folder/) \
    <(printf "1\\n")
  diff                                                      \
    <(NB_DIR="${NB_DIR_2}" "${_NB}" count Example\ Folder/) \
    <(printf "1\\n")
  diff                                                      \
    <(cat "${NB_DIR_1}/home/Example Folder/.index")         \
    <(printf "one.md\\n")
  diff                                                      \
    <(cat "${NB_DIR_2}/home/Example Folder/.index")         \
    <(printf "two.md\\n")

  export NB_DIR="${NB_DIR_2}"

  # sync 2: pull changes from remote, rebase, send new changes back to remote
  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "(2)\\n"
  printf "index 1:\\n"
  cat "${NB_DIR_1}/home/Example Folder/.index"
  printf "index 2:\\n"
  cat "${NB_DIR_2}/home/Example Folder/.index"

  [[ "${status}" -eq 0 ]]

  diff                                                      \
    <(NB_DIR="${NB_DIR_1}" "${_NB}" count Example\ Folder/) \
    <(printf "1\\n")
  diff                                                      \
    <(NB_DIR="${NB_DIR_2}" "${_NB}" count Example\ Folder/) \
    <(printf "2\\n")
  diff                                                      \
    <(cat "${NB_DIR_1}/home/Example Folder/.index")         \
    <(printf "one.md\\n")
  diff                                                      \
    <(cat "${NB_DIR_2}/home/Example Folder/.index")         \
    <(printf "one.md%stwo.md\\n" "${_NEWLINE}")

  # sync 3: pull changes from remote
  export NB_DIR="${NB_DIR_1}"

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "(3)\\n"
  printf "index 1:\\n"
  cat "${NB_DIR_1}/home/Example Folder/.index"
  printf "index 2:\\n"
  cat "${NB_DIR_2}/home/Example Folder/.index"

  [[ "${status}" -eq 0                                                              ]]
  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count Example\ Folder/)" == 2                 ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count Example\ Folder/)" == 2                 ]]
  [[ "$(cat "${NB_DIR_1}/home/Example Folder/.index")" == "one.md${_NEWLINE}two.md" ]]
  [[ "$(cat "${NB_DIR_2}/home/Example Folder/.index")" == "one.md${_NEWLINE}two.md" ]]

  # Add more notes to each clone

  export NB_DIR="${NB_DIR_1}"
  run "${_NB}" add "Example Folder/one-2.md" --content "Example content from 1."

  export NB_DIR="${NB_DIR_2}"
  run "${_NB}" add "Example Folder/two-2.md" --content "Example content from 2."

  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count Example\ Folder/)" == 3 ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count Example\ Folder/)" == 3 ]]
  [[ "$(cat "${NB_DIR_1}/home/Example Folder/.index")" == \
        "one.md${_NEWLINE}two.md${_NEWLINE}one-2.md"                ]]
  [[ "$(cat "${NB_DIR_2}/home/Example Folder/.index")" == \
        "one.md${_NEWLINE}two.md${_NEWLINE}two-2.md"                ]]

  # sync 4: send new changes to remote
  export NB_DIR="${NB_DIR_2}"

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "(4)\\n"
  printf "index 1:\\n"
  cat "${NB_DIR_1}/home/Example Folder/.index"
  printf "index 2:\\n"
  cat "${NB_DIR_2}/home/Example Folder/.index"

  [[ "${status}" -eq 0                                              ]]
  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count Example\ Folder/)" == 3 ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count Example\ Folder/)" == 3 ]]
  [[ "$(cat "${NB_DIR_1}/home/Example Folder/.index")" == \
        "one.md${_NEWLINE}two.md${_NEWLINE}one-2.md"                ]]
  [[ "$(cat "${NB_DIR_2}/home/Example Folder/.index")" == \
        "one.md${_NEWLINE}two.md${_NEWLINE}two-2.md"                ]]

  # sync 5: pull changes from remote, rebase, send new changes back to remote
  export NB_DIR="${NB_DIR_1}"

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "(5)\\n"
  printf "index 1:\\n"
  cat "${NB_DIR_1}/home/Example Folder/.index"
  printf "index 2:\\n"
  cat "${NB_DIR_2}/home/Example Folder/.index"

  [[ "${status}" -eq 0                                                ]]
  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count Example\ Folder/)" == 4   ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count Example\ Folder/)" == 3   ]]
  [[ "$(cat "${NB_DIR_1}/home/Example Folder/.index")" == \
     "one.md${_NEWLINE}two.md${_NEWLINE}two-2.md${_NEWLINE}one-2.md"  ]]
  [[ "$(cat "${NB_DIR_2}/home/Example Folder/.index")" == \
     "one.md${_NEWLINE}two.md${_NEWLINE}two-2.md"                     ]]

  # sync 6: pull changes from remote
  export NB_DIR="${NB_DIR_2}"

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "(6)\\n"
  printf "index 1:\\n"
  cat "${NB_DIR_1}/home/Example Folder/.index"
  printf "index 2:\\n"
  cat "${NB_DIR_2}/home/Example Folder/.index"

  [[ "${status}" -eq 0                                                ]]
  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count Example\ Folder/)" == 4   ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count Example\ Folder/)" == 4   ]]
  [[ "$(cat "${NB_DIR_1}/home/Example Folder/.index")" == \
     "one.md${_NEWLINE}two.md${_NEWLINE}two-2.md${_NEWLINE}one-2.md"  ]]
  [[ "$(cat "${NB_DIR_2}/home/Example Folder/.index")" == \
     "one.md${_NEWLINE}two.md${_NEWLINE}two-2.md${_NEWLINE}one-2.md"  ]]

  # add more notes to and remove notes from each clone

  export NB_DIR="${NB_DIR_1}"
  run "${_NB}" add "Example Folder/one-3.md" --content "Example content from 1."
  run "${_NB}" delete "Example Folder/two.md" --force

  export NB_DIR="${NB_DIR_2}"
  run "${_NB}" add "Example Folder/two-3.md" --content "Example content from 2."

  printf "(6.5)\\n"
  NB_DIR="${NB_DIR_1}" "${_NB}" count
  printf "index 1:\\n"
  cat "${NB_DIR_1}/home/Example Folder/.index"
  NB_DIR="${NB_DIR_2}" "${_NB}" count
  printf "index 2:\\n"
  cat "${NB_DIR_2}/home/Example Folder/.index"

  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count Example\ Folder/)" == 4 ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count Example\ Folder/)" == 5 ]]
  [[ "$(cat "${NB_DIR_1}/home/Example Folder/.index")" == \
    "one.md${_NEWLINE}${_NEWLINE}two-2.md${_NEWLINE}one-2.md${_NEWLINE}one-3.md"        ]]
  [[ "$(cat "${NB_DIR_2}/home/Example Folder/.index")" == \
    "one.md${_NEWLINE}two.md${_NEWLINE}two-2.md${_NEWLINE}one-2.md${_NEWLINE}two-3.md"  ]]

  # sync 7: push changes to remote
  export NB_DIR="${NB_DIR_2}"

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "(7)\\n"
  NB_DIR="${NB_DIR_1}" "${_NB}" count
  printf "index 1:\\n"
  cat "${NB_DIR_1}/home/Example Folder/.index"
  NB_DIR="${NB_DIR_2}" "${_NB}" count
  printf "index 2:\\n"
  cat "${NB_DIR_2}/home/Example Folder/.index"

  [[ "${status}" -eq 0                                              ]]
  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count Example\ Folder/)" == 4 ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count Example\ Folder/)" == 5 ]]
  [[ "$(cat "${NB_DIR_1}/home/Example Folder/.index")" == \
    "one.md${_NEWLINE}${_NEWLINE}two-2.md${_NEWLINE}one-2.md${_NEWLINE}one-3.md"        ]]
  [[ "$(cat "${NB_DIR_2}/home/Example Folder/.index")" == \
    "one.md${_NEWLINE}two.md${_NEWLINE}two-2.md${_NEWLINE}one-2.md${_NEWLINE}two-3.md"  ]]

  # sync 8: pull changes from remote
  export NB_DIR="${NB_DIR_1}"

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "(8)\\n"
  NB_DIR="${NB_DIR_1}" "${_NB}" count
  printf "index 1:\\n"
  cat "${NB_DIR_1}/home/Example Folder/.index"
  NB_DIR="${NB_DIR_2}" "${_NB}" count
  printf "index 2:\\n"
  cat "${NB_DIR_2}/home/Example Folder/.index"

  [[ "${status}" -eq 0                                              ]]
  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count Example\ Folder/)" == 5 ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count Example\ Folder/)" == 5 ]]
  [[ "$(cat "${NB_DIR_1}/home/Example Folder/.index")" == \
     "one.md${_NEWLINE}${_NEWLINE}two-2.md${_NEWLINE}one-2.md${_NEWLINE}two-3.md${_NEWLINE}one-3.md"  ]]
  [[ "$(cat "${NB_DIR_2}/home/Example Folder/.index")" == \
     "one.md${_NEWLINE}two.md${_NEWLINE}two-2.md${_NEWLINE}one-2.md${_NEWLINE}two-3.md"               ]]

  # sync 9: push changes to remote
  export NB_DIR="${NB_DIR_1}"

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "(9)\\n"
  NB_DIR="${NB_DIR_1}" "${_NB}" count
  printf "index 1:\\n"
  cat "${NB_DIR_1}/home/Example Folder/.index"
  NB_DIR="${NB_DIR_2}" "${_NB}" count
  printf "index 2:\\n"
  cat "${NB_DIR_2}/home/Example Folder/.index"

  [[ "${status}" -eq 0                                              ]]
  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count Example\ Folder/)" == 5 ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count Example\ Folder/)" == 5 ]]
  [[ "$(cat "${NB_DIR_1}/home/Example Folder/.index")" == \
     "one.md${_NEWLINE}${_NEWLINE}two-2.md${_NEWLINE}one-2.md${_NEWLINE}two-3.md${_NEWLINE}one-3.md"  ]]
  [[ "$(cat "${NB_DIR_2}/home/Example Folder/.index")" == \
     "one.md${_NEWLINE}two.md${_NEWLINE}two-2.md${_NEWLINE}one-2.md${_NEWLINE}two-3.md"               ]]

  # sync 10: pull changes from remote
  export NB_DIR="${NB_DIR_2}"

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "(10)\\n"
  NB_DIR="${NB_DIR_1}" "${_NB}" count
  printf "index 1:\\n"
  cat "${NB_DIR_1}/home/Example Folder/.index"
  NB_DIR="${NB_DIR_2}" "${_NB}" count
  printf "index 2:\\n"
  cat "${NB_DIR_2}/home/Example Folder/.index"

  [[ "${status}" -eq 0                                              ]]
  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count Example\ Folder/)" == 5 ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count Example\ Folder/)" == 5 ]]
  [[ "$(cat "${NB_DIR_1}/home/Example Folder/.index")" == \
     "one.md${_NEWLINE}${_NEWLINE}two-2.md${_NEWLINE}one-2.md${_NEWLINE}two-3.md${_NEWLINE}one-3.md"  ]]
  [[ "$(cat "${NB_DIR_2}/home/Example Folder/.index")" == \
     "one.md${_NEWLINE}${_NEWLINE}two-2.md${_NEWLINE}one-2.md${_NEWLINE}two-3.md${_NEWLINE}one-3.md"  ]]
}

@test "'sync' succeeds when one file is edited on two clones within a folder." {
  # skip

  _setup_notebooks

  export NB_DIR="${NB_DIR_1}"

  run "${_NB}" add "Example Folder/one.md" --content "Example content from 1.

- Line 3 List Item
- Line 4 List Item
- Line 5 List Item
"
  run "${_NB}" sync

  export NB_DIR="${NB_DIR_2}"

  run "${_NB}" sync

  # ls -la "${NB_DIR_2}"

  _sed_i 's/Line 4/Line n/' "${NB_DIR_2}/home/Example Folder/one.md"

  run "${_NB}" &>/dev/null
  run "${_NB}" sync

  export NB_DIR="${NB_DIR_1}"

  _sed_i 's/Line 4/Line x/' "${NB_DIR_1}/home/Example Folder/one.md"

  run "${_NB}" &>/dev/null
  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  cat "${NB_DIR_1}/home/Example Folder/one.md"

  [[ "${status}" -eq 0                              ]]
  [[ "${output}" =~ Files\ containing\ conflicts\:  ]]
  [[ "${output}" =~ home\:Example\ Folder/one\.md   ]]

  grep -q '<<<<<<< HEAD'        "${NB_DIR_1}/home/Example Folder/one.md"
  grep -q '\- Line n List Item' "${NB_DIR_1}/home/Example Folder/one.md"
  grep -q '======='             "${NB_DIR_1}/home/Example Folder/one.md"
  grep -q '\- Line x List Item' "${NB_DIR_1}/home/Example Folder/one.md"
  grep -q '>>>>>>>'             "${NB_DIR_1}/home/Example Folder/one.md"
  grep -q '\[nb\] Commit'       "${NB_DIR_1}/home/Example Folder/one.md"
  grep -q '\- Line 5 List Item' "${NB_DIR_1}/home/Example Folder/one.md"
}

@test "'sync' succeeds when multiple files are edited on two clones within a folder." {
  # skip
  _setup_notebooks

  export NB_DIR="${NB_DIR_1}"

  run "${_NB}" add "Example Folder/one.md" --content "Example content from 1.

- Line 3 List Item
- Line 4 List Item
- Line 5 List Item
"

  run "${_NB}" add "Example Folder/two.md" --content "Example content from 1.

- Line 3 List Item
- Line 4 List Item
- Line 5 List Item
"

  run "${_NB}" add "Example Folder/three.md" --content "Example content from 1.

- Line 3 List Item
- Line 4 List Item
- Line 5 List Item
"
  run "${_NB}" sync

  export NB_DIR="${NB_DIR_2}"

  run "${_NB}" sync

  # ls -la "${NB_DIR_2}"

  _sed_i 's/Line 4/Line n/' "${NB_DIR_2}/home/Example Folder/one.md"
  _sed_i 's/Line 4/Line n/' "${NB_DIR_2}/home/Example Folder/two.md"
  _sed_i 's/Line 4/Line n/' "${NB_DIR_2}/home/Example Folder/three.md"

  run "${_NB}" &>/dev/null
  run "${_NB}" sync

  export NB_DIR="${NB_DIR_1}"

  _sed_i 's/Line 4/Line x/' "${NB_DIR_1}/home/Example Folder/one.md"
  _sed_i 's/Line 4/Line x/' "${NB_DIR_1}/home/Example Folder/two.md"
  _sed_i 's/Line 4/Line x/' "${NB_DIR_1}/home/Example Folder/three.md"

  run "${_NB}" &>/dev/null
  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  cat "${NB_DIR_1}/home/Example Folder/one.md"

  [[ "${status}" -eq 0                              ]]
  [[ "${output}" =~ Files\ containing\ conflicts\:  ]]
  [[ "${output}" =~ home\:Example\ Folder/one\.md   ]]
  [[ "${output}" =~ home\:Example\ Folder/two\.md   ]]
  [[ "${output}" =~ home\:Example\ Folder/three\.md ]]

  grep -q '<<<<<<< HEAD'        "${NB_DIR_1}/home/Example Folder/one.md"
  grep -q '\- Line n List Item' "${NB_DIR_1}/home/Example Folder/one.md"
  grep -q '======='             "${NB_DIR_1}/home/Example Folder/one.md"
  grep -q '\- Line x List Item' "${NB_DIR_1}/home/Example Folder/one.md"
  grep -q '>>>>>>>'             "${NB_DIR_1}/home/Example Folder/one.md"
  grep -q '\[nb\] Commit'       "${NB_DIR_1}/home/Example Folder/one.md"
  grep -q '\- Line 5 List Item' "${NB_DIR_1}/home/Example Folder/one.md"

  grep -q '<<<<<<< HEAD'        "${NB_DIR_1}/home/Example Folder/two.md"
  grep -q '\- Line n List Item' "${NB_DIR_1}/home/Example Folder/two.md"
  grep -q '======='             "${NB_DIR_1}/home/Example Folder/two.md"
  grep -q '\- Line x List Item' "${NB_DIR_1}/home/Example Folder/two.md"
  grep -q '>>>>>>>'             "${NB_DIR_1}/home/Example Folder/two.md"
  grep -q '\[nb\] Commit'       "${NB_DIR_1}/home/Example Folder/two.md"
  grep -q '\- Line 5 List Item' "${NB_DIR_1}/home/Example Folder/two.md"

  grep -q '<<<<<<< HEAD'        "${NB_DIR_1}/home/Example Folder/three.md"
  grep -q '\- Line n List Item' "${NB_DIR_1}/home/Example Folder/three.md"
  grep -q '======='             "${NB_DIR_1}/home/Example Folder/three.md"
  grep -q '\- Line x List Item' "${NB_DIR_1}/home/Example Folder/three.md"
  grep -q '>>>>>>>'             "${NB_DIR_1}/home/Example Folder/three.md"
  grep -q '\[nb\] Commit'       "${NB_DIR_1}/home/Example Folder/three.md"
  grep -q '\- Line 5 List Item' "${NB_DIR_1}/home/Example Folder/three.md"
}

@test "'sync' succeeds when the same filename is added on two clones within a folder." {
  # skip
  _setup_notebooks

  export NB_DIR="${NB_DIR_1}"

  run "${_NB}" add "Example Folder/one.md" --content "Example content from 1.

- Line 3 List Item
- Line 4 List Item
- Line 5 List Item
"
  run "${_NB}" sync

  export NB_DIR="${NB_DIR_2}"

  run "${_NB}" add "Example Folder/one.md" --content "Example different content from 2.

This content is unique to 2.
"

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "1:one.md\\n"
  cat "${NB_DIR_1}/home/Example Folder/one.md"
  printf "2:one.md\\n"
  cat "${NB_DIR_2}/home/Example Folder/one.md"

  [[ "${status}" -eq 0                              ]]
  [[ "${output}" =~ Files\ containing\ conflicts\:  ]]
  [[ "${output}" =~ home\:Example\ Folder/one\.md   ]]

  grep -q '<<<<<<< HEAD'                        "${NB_DIR_2}/home/Example Folder/one.md"
  grep -q 'Example content from 1.'             "${NB_DIR_2}/home/Example Folder/one.md"
  grep -q '\- Line 3 List Item'                 "${NB_DIR_2}/home/Example Folder/one.md"
  grep -q '======='                             "${NB_DIR_2}/home/Example Folder/one.md"
  grep -q 'Example different content'           "${NB_DIR_2}/home/Example Folder/one.md"
  grep -q '>>>>>>>'                             "${NB_DIR_2}/home/Example Folder/one.md"
  grep -q '\[nb\] Add\: Example Folder/one.md'  "${NB_DIR_2}/home/Example Folder/one.md"
}

@test "'sync' succeeds when an encrypted file is edited on two clones within a folder." {
  # skip

  _setup_notebooks

  export NB_DIR="${NB_DIR_1}"

  run "${_NB}" add "Example Folder/one.md"  \
    --encrypt --password password           \
    --content "Example content from 1.

- Line 3 List Item
- Line 4 List Item
- Line 5 List Item
"
  run "${_NB}" sync

  [[ -e "${NB_DIR_1}/home/Example Folder/one.md.enc"                    ]]
  [[ ! -e "${NB_DIR_1}/home/Example Folder/one--conflicted-copy.md.enc" ]]

  [[ ! -e "${NB_DIR_2}/home/Example Folder/one.md.enc"                  ]]
  [[ ! -e "${NB_DIR_2}/home/Example Folder/one--conflicted-copy.md.enc" ]]

  export NB_DIR="${NB_DIR_2}"

  [[ ! "$(
          "${_NB}" show "Example Folder/one.md.enc" \
            --password password --print --no-color
        )" =~ Edit\ content\ from\ 1\.                    ]]
  [[ ! "$(
          "${_NB}" show "Example Folder/one.md.enc" \
          --password password --print --no-color
        )" =~ Edit\ content\ from\ 2\.                    ]]

  run "${_NB}" sync

  [[ -e "${NB_DIR_1}/home/Example Folder/one.md.enc"                    ]]
  [[ ! -e "${NB_DIR_1}/home/Example Folder/one--conflicted-copy.md.enc" ]]

  [[ -e "${NB_DIR_2}/home/Example Folder/one.md.enc"                    ]]
  [[ ! -e "${NB_DIR_2}/home/Example Folder/one--conflicted-copy.md.enc" ]]

  [[ "$(_get_hash "${NB_DIR_1}/home/Example Folder/one.md.enc")" == \
     "$(_get_hash "${NB_DIR_2}/home/Example Folder/one.md.enc")"        ]]

  ls -la "${NB_DIR_2}"

  echo "Edit content from 2." | "${_NB}" edit "Example Folder/1" --password password

  run "${_NB}" sync

  [[ -e "${NB_DIR_1}/home/Example Folder/one.md.enc"                    ]]
  [[ ! -e "${NB_DIR_1}/home/Example Folder/one--conflicted-copy.md.enc" ]]

  [[ -e "${NB_DIR_2}/home/Example Folder/one.md.enc"                    ]]
  [[ ! -e "${NB_DIR_2}/home/Example Folder/one--conflicted-copy.md.enc" ]]

  [[ "$(_get_hash "${NB_DIR_1}/home/Example Folder/one.md.enc")" != \
     "$(_get_hash "${NB_DIR_2}/home/Example Folder/one.md.enc")"        ]]

  [[ "$(
        "${_NB}" show "Example Folder/one.md.enc" \
          --password password --print --no-color
      )" =~ Edit\ content\ from\ 2\.                      ]]

  export NB_DIR="${NB_DIR_1}"

  _before="$(
    _get_hash "${NB_DIR_1}/home/Example Folder/one.md.enc"
  )"

  echo "Edit content from 1." | "${_NB}" edit "Example Folder/1" --password password

  _after="$(
    _get_hash "${NB_DIR_1}/home/Example Folder/one.md.enc"
  )"

  printf "\${_before}:  %s\\n" "${_before}"
  printf "\${_after}:   %s\\n" "${_after}"

  [[ "${_before}" != "${_after}"      ]]

  [[ "$(
        "${_NB}" show "Example Folder/one.md.enc" \
          --password password --print --no-color
      )" =~ Edit\ content\ from\ 1\.  ]]

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "$(_get_hash "${NB_DIR_1}/home/Example Folder/one.md.enc")" != \
     "$(_get_hash "${NB_DIR_2}/home/Example Folder/one.md.enc")"        ]]

  [[ "${status}" -eq 0                                                  ]]

  [[ -e "${NB_DIR_1}/home/Example Folder/one.md.enc"                    ]]
  [[ -e "${NB_DIR_1}/home/Example Folder/one--conflicted-copy.md.enc"   ]]

  [[ -e "${NB_DIR_2}/home/Example Folder/one.md.enc"                    ]]
  [[ ! -e "${NB_DIR_2}/home/Example Folder/one--conflicted-copy.md.enc" ]]

  [[ "$(_get_hash "${NB_DIR_1}/home/Example Folder/one.md.enc")" != \
     "$(_get_hash "${NB_DIR_2}/home/Example Folder/one.md.enc")"        ]]

  [[ "$(_get_hash "${NB_DIR_1}/home/Example Folder/one--conflicted-copy.md.enc")" == \
     "$(_get_hash "${NB_DIR_2}/home/Example Folder/one.md.enc")"        ]]

  [[ ${output} =~ Conflicted\ copies\ of\ binary\ files\:               ]]
  [[ ${output} =~ home\:Example\ Folder/one\-\-conflicted-copy\.md\.enc ]]

  [[ "$(
        "${_NB}" show "Example Folder/one.md.enc"                   \
          --password password --print --no-color
      )" =~ Edit\ content\ from\ 1\.                      ]]
  [[ "$(
        "${_NB}" show "Example Folder/one--conflicted-copy.md.enc"  \
          --password password --print --no-color
      )" =~ Edit\ content\ from\ 2\.                      ]]

  export NB_DIR="${NB_DIR_2}"

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]

  [[ -e "${NB_DIR_1}/home/Example Folder/one.md.enc"                              ]]
  [[ -e "${NB_DIR_1}/home/Example Folder/one--conflicted-copy.md.enc"             ]]

  [[ -e "${NB_DIR_2}/home/Example Folder/one.md.enc"                              ]]
  [[ -e "${NB_DIR_2}/home/Example Folder/one--conflicted-copy.md.enc"             ]]

  [[ "$(_get_hash "${NB_DIR_1}/home/Example Folder/one.md.enc")" == \
     "$(_get_hash "${NB_DIR_2}/home/Example Folder/one.md.enc")"                  ]]

  [[ "$(_get_hash "${NB_DIR_1}/home/Example Folder/one--conflicted-copy.md.enc")" == \
     "$(_get_hash "${NB_DIR_2}/home/Example Folder/one--conflicted-copy.md.enc")" ]]

  [[ "$(_get_hash "${NB_DIR_1}/home/Example Folder/one.md.enc")" != \
     "$(_get_hash "${NB_DIR_1}/home/Example Folder/one--conflicted-copy.md.enc")" ]]

  [[ "$(
        "${_NB}" show "Example Folder/one.md.enc"                   \
          --password password --print --no-color
      )" =~ Edit\ content\ from\ 1\.                                ]]
  [[ "$(
        "${_NB}" show "Example Folder/one--conflicted-copy.md.enc"  \
          --password password --print --no-color
      )" =~ Edit\ content\ from\ 2\.                                ]]
}

@test "'sync' notebooks exist after setup." {
  _setup_notebooks

  [[ -d "${_GIT_REMOTE_PATH}"     ]]
  [[ "${NB_DIR_1}" == "${NB_DIR}" ]]
  [[ -d "${NB_DIR_1}/home/.git"   ]]
  [[ -d "${NB_DIR_2}/home/.git"   ]]
}
