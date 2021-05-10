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

# help ########################################################################

@test "'help sync' exits with 0 and prints help information." {
  run "${_NB}" help sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0             ]]

  [[ "${lines[0]}"  =~  Usage.*\:     ]]
  [[ "${lines[1]}"  =~  \ \ nb\ sync  ]]
}

# sync --all #################################################################

@test "'sync --all' with no local syncs global notebooks." {
  export NB_AUTO_SYNC=0

  {
    _setup_notebooks

    # global-remote

    "${_NB}" notebooks add global-remote "${_GIT_REMOTE_URL}"

    run "${_NB}" global-remote:add "global-remote.md" \
      --content "Example content from global-remote."

    [[ ${status} -eq 0                                          ]]

    # NB_DIR_1

    [[ ! -f "${NB_DIR_1}/example-archived/archived.md"          ]]
    [[ ! -f "${NB_DIR_1}/example-archived/global-remote.md"     ]]
    [[ ! -f "${NB_DIR_1}/example-archived/global-no-remote.md"  ]]

    [[ ! -f "${NB_DIR_1}/global-remote/archived.md"             ]]
    [[   -f "${NB_DIR_1}/global-remote/global-remote.md"        ]]
    [[ ! -f "${NB_DIR_1}/global-remote/global-no-remote.md"     ]]

    [[ ! -f "${NB_DIR_1}/global-no-remote/archived.md"          ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/global-remote.md"     ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/global-no-remote.md"  ]]

    [[ ! -f "${NB_DIR_1}/home/example-archived.md"              ]]
    [[ ! -f "${NB_DIR_1}/home/global-remote.md"                 ]]
    [[ ! -f "${NB_DIR_1}/home/global-no-remote.md"              ]]

    # NB_DIR_2

    [[ ! -f "${NB_DIR_2}/home/archived.md"                      ]]
    [[ ! -f "${NB_DIR_2}/home/global-remote.md"                 ]]
    [[ ! -f "${NB_DIR_2}/home/global-no-remote.md"              ]]

    # global-no-remote

    "${_NB}" notebooks add global-no-remote

    run "${_NB}" global-no-remote:add "global-no-remote.md" \
      --content "Example content from global-no-remote."

    [[ ${status} -eq 0                                          ]]

    # NB_DIR_1

    [[ ! -f "${NB_DIR_1}/example-archived/archived.md"          ]]
    [[ ! -f "${NB_DIR_1}/example-archived/global-remote.md"     ]]
    [[ ! -f "${NB_DIR_1}/example-archived/global-no-remote.md"  ]]

    [[ ! -f "${NB_DIR_1}/global-remote/archived.md"             ]]
    [[   -f "${NB_DIR_1}/global-remote/global-remote.md"        ]]
    [[ ! -f "${NB_DIR_1}/global-remote/global-no-remote.md"     ]]

    [[ ! -f "${NB_DIR_1}/global-no-remote/archived.md"          ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/global-remote.md"     ]]
    [[   -f "${NB_DIR_1}/global-no-remote/global-no-remote.md"  ]]

    [[ ! -f "${NB_DIR_1}/home/example-archived.md"              ]]
    [[ ! -f "${NB_DIR_1}/home/global-remote.md"                 ]]
    [[ ! -f "${NB_DIR_1}/home/global-no-remote.md"              ]]

    # NB_DIR_2

    [[ ! -f "${NB_DIR_2}/home/archived.md"                      ]]
    [[ ! -f "${NB_DIR_2}/home/global-remote.md"                 ]]
    [[ ! -f "${NB_DIR_2}/home/global-no-remote.md"              ]]

    # example-archived

    "${_NB}" notebooks add example-archived "${_GIT_REMOTE_URL}"
    "${_NB}" notebooks archive example-archived
    run "${_NB}" example-archived:add "archived.md" \
      --content "Example content from example-archived."

    [[ ${status} -eq 0                                          ]]

    # NB_DIR_1

    [[   -f "${NB_DIR_1}/example-archived/archived.md"          ]]
    [[ ! -f "${NB_DIR_1}/example-archived/global-remote.md"     ]]
    [[ ! -f "${NB_DIR_1}/example-archived/global-no-remote.md"  ]]

    [[ ! -f "${NB_DIR_1}/global-remote/archived.md"             ]]
    [[   -f "${NB_DIR_1}/global-remote/global-remote.md"        ]]
    [[ ! -f "${NB_DIR_1}/global-remote/global-no-remote.md"     ]]

    [[ ! -f "${NB_DIR_1}/global-no-remote/archived.md"          ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/global-remote.md"     ]]
    [[   -f "${NB_DIR_1}/global-no-remote/global-no-remote.md"  ]]

    [[ ! -f "${NB_DIR_1}/home/example-archived.md"              ]]
    [[ ! -f "${NB_DIR_1}/home/global-remote.md"                 ]]
    [[ ! -f "${NB_DIR_1}/home/global-no-remote.md"              ]]

    # NB_DIR_2

    [[ ! -f "${NB_DIR_2}/home/archived.md"                      ]]
    [[ ! -f "${NB_DIR_2}/home/global-remote.md"                 ]]
    [[ ! -f "${NB_DIR_2}/home/global-no-remote.md"              ]]
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

  [[ ${status} -eq 0                                          ]]

  # sync 2: sync all again to get changes
  run "${_NB}" sync --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[   "${output}" =~ \
    Syncing:\ .*global-remote.*....*home.*...Done!            ]]
  [[ ! "${output}" =~ local                                   ]]
  [[ ! "${output}" =~ archived                                ]]
  [[ ! "${output}" =~ no-remote                               ]]

  [[ ${status} -eq 0                                          ]]

  # NB_DIR_1

  [[   -f "${NB_DIR_1}/example-archived/archived.md"          ]]
  [[ ! -f "${NB_DIR_1}/example-archived/global-remote.md"     ]]
  [[ ! -f "${NB_DIR_1}/example-archived/global-no-remote.md"  ]]

  [[ ! -f "${NB_DIR_1}/global-remote/archived.md"             ]]
  [[   -f "${NB_DIR_1}/global-remote/global-remote.md"        ]]
  [[ ! -f "${NB_DIR_1}/global-remote/global-no-remote.md"     ]]

  [[ ! -f "${NB_DIR_1}/global-no-remote/archived.md"          ]]
  [[ ! -f "${NB_DIR_1}/global-no-remote/global-remote.md"     ]]
  [[   -f "${NB_DIR_1}/global-no-remote/global-no-remote.md"  ]]

  [[ ! -f "${NB_DIR_1}/home/example-archived.md"              ]]
  [[   -f "${NB_DIR_1}/home/global-remote.md"                 ]]
  [[ ! -f "${NB_DIR_1}/home/global-no-remote.md"              ]]

  # NB_DIR_2

  [[ ! -f "${NB_DIR_2}/home/archived.md"                      ]]
  [[ ! -f "${NB_DIR_2}/home/global-remote.md"                 ]]
  [[ ! -f "${NB_DIR_2}/home/global-no-remote.md"              ]]
}

# local notebook ##############################################################

@test "'sync --all' with local syncs local and global notebooks." {
  export NB_AUTO_SYNC=0

  {
    _setup_notebooks

    # global-remote

    "${_NB}" notebooks add global-remote "${_GIT_REMOTE_URL}"

    run "${_NB}" global-remote:add "global-remote.md" \
      --content "Example content from global-remote."

    [[ ${status} -eq 0                                          ]]

    # NB_DIR_1

    [[ ! -f "${NB_DIR_1}/example-archived/archived.md"          ]]
    [[ ! -f "${NB_DIR_1}/example-archived/global-remote.md"     ]]
    [[ ! -f "${NB_DIR_1}/example-archived/global-no-remote.md"  ]]
    [[ ! -f "${NB_DIR_1}/example-archived/local.md"             ]]

    [[ ! -f "${NB_DIR_1}/global-remote/archived.md"             ]]
    [[   -f "${NB_DIR_1}/global-remote/global-remote.md"        ]]
    [[ ! -f "${NB_DIR_1}/global-remote/global-no-remote.md"     ]]
    [[ ! -f "${NB_DIR_1}/global-remote/local.md"                ]]

    [[ ! -f "${NB_DIR_1}/global-no-remote/archived.md"          ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/global-remote.md"     ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/global-no-remote.md"  ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/local.md"             ]]

    [[ ! -f "${NB_DIR_1}/home/example-archived.md"              ]]
    [[ ! -f "${NB_DIR_1}/home/global-remote.md"                 ]]
    [[ ! -f "${NB_DIR_1}/home/global-no-remote.md"              ]]
    [[ ! -f "${NB_DIR_1}/home/local.md"                         ]]

    # NB_DIR_2

    [[ ! -f "${NB_DIR_2}/home/archived.md"                      ]]
    [[ ! -f "${NB_DIR_2}/home/global-remote.md"                 ]]
    [[ ! -f "${NB_DIR_2}/home/global-no-remote.md"              ]]
    [[ ! -f "${NB_DIR_2}/home/local.md"                         ]]

    # local

    [[ ! -f "${_TMP_DIR}/example-local/archived.md"             ]]
    [[ ! -f "${_TMP_DIR}/example-local/global-remote.md"        ]]
    [[ ! -f "${_TMP_DIR}/example-local/global-no-remote.md"     ]]
    [[ ! -f "${_TMP_DIR}/example-local/local.md"                ]]

    # global-no-remote

    "${_NB}" notebooks add global-no-remote

    run "${_NB}" global-no-remote:add "global-no-remote.md" \
      --content "Example content from global-no-remote."

    [[ ${status} -eq 0                                          ]]

    # NB_DIR_1

    [[ ! -f "${NB_DIR_1}/example-archived/archived.md"          ]]
    [[ ! -f "${NB_DIR_1}/example-archived/global-remote.md"     ]]
    [[ ! -f "${NB_DIR_1}/example-archived/global-no-remote.md"  ]]
    [[ ! -f "${NB_DIR_1}/example-archived/local.md"             ]]

    [[ ! -f "${NB_DIR_1}/global-remote/archived.md"             ]]
    [[   -f "${NB_DIR_1}/global-remote/global-remote.md"        ]]
    [[ ! -f "${NB_DIR_1}/global-remote/global-no-remote.md"     ]]
    [[ ! -f "${NB_DIR_1}/global-remote/local.md"                ]]

    [[ ! -f "${NB_DIR_1}/global-no-remote/archived.md"          ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/global-remote.md"     ]]
    [[   -f "${NB_DIR_1}/global-no-remote/global-no-remote.md"  ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/local.md"             ]]

    [[ ! -f "${NB_DIR_1}/home/example-archived.md"              ]]
    [[ ! -f "${NB_DIR_1}/home/global-remote.md"                 ]]
    [[ ! -f "${NB_DIR_1}/home/global-no-remote.md"              ]]
    [[ ! -f "${NB_DIR_1}/home/local.md"                         ]]

    # NB_DIR_2

    [[ ! -f "${NB_DIR_2}/home/archived.md"                      ]]
    [[ ! -f "${NB_DIR_2}/home/global-remote.md"                 ]]
    [[ ! -f "${NB_DIR_2}/home/global-no-remote.md"              ]]
    [[ ! -f "${NB_DIR_2}/home/local.md"                         ]]

    # local

    [[ ! -f "${_TMP_DIR}/example-local/archived.md"             ]]
    [[ ! -f "${_TMP_DIR}/example-local/global-remote.md"        ]]
    [[ ! -f "${_TMP_DIR}/example-local/global-no-remote.md"     ]]
    [[ ! -f "${_TMP_DIR}/example-local/local.md"                ]]

    # example-archived

    "${_NB}" notebooks add example-archived "${_GIT_REMOTE_URL}"
    "${_NB}" notebooks archive example-archived

    run "${_NB}" example-archived:add "archived.md" \
      --content "Example content from example-archived."

    [[ ${status} -eq 0                                          ]]

    # NB_DIR_1

    [[   -f "${NB_DIR_1}/example-archived/archived.md"          ]]
    [[ ! -f "${NB_DIR_1}/example-archived/global-remote.md"     ]]
    [[ ! -f "${NB_DIR_1}/example-archived/global-no-remote.md"  ]]
    [[ ! -f "${NB_DIR_1}/example-archived/local.md"             ]]

    [[ ! -f "${NB_DIR_1}/global-remote/archived.md"             ]]
    [[   -f "${NB_DIR_1}/global-remote/global-remote.md"        ]]
    [[ ! -f "${NB_DIR_1}/global-remote/global-no-remote.md"     ]]
    [[ ! -f "${NB_DIR_1}/global-remote/local.md"                ]]

    [[ ! -f "${NB_DIR_1}/global-no-remote/archived.md"          ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/global-remote.md"     ]]
    [[   -f "${NB_DIR_1}/global-no-remote/global-no-remote.md"  ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/local.md"             ]]

    [[ ! -f "${NB_DIR_1}/home/example-archived.md"              ]]
    [[ ! -f "${NB_DIR_1}/home/global-remote.md"                 ]]
    [[ ! -f "${NB_DIR_1}/home/global-no-remote.md"              ]]
    [[ ! -f "${NB_DIR_1}/home/local.md"                         ]]

    # NB_DIR_2

    [[ ! -f "${NB_DIR_2}/home/archived.md"                      ]]
    [[ ! -f "${NB_DIR_2}/home/global-remote.md"                 ]]
    [[ ! -f "${NB_DIR_2}/home/global-no-remote.md"              ]]
    [[ ! -f "${NB_DIR_2}/home/local.md"                         ]]

    # local

    [[ ! -f "${_TMP_DIR}/example-local/archived.md"             ]]
    [[ ! -f "${_TMP_DIR}/example-local/global-remote.md"        ]]
    [[ ! -f "${_TMP_DIR}/example-local/global-no-remote.md"     ]]
    [[ ! -f "${_TMP_DIR}/example-local/local.md"                ]]

    run "${_NB}" notebooks init "${_TMP_DIR}/example-local" "${_GIT_REMOTE_URL}"

    cd "${_TMP_DIR}/example-local"

    [[ "$(pwd)" == "${_TMP_DIR}/example-local" ]]

    [[ ${status} -eq 0                                    ]]
    [[ "$("${_NB}" remote --url)" == "${_GIT_REMOTE_URL}" ]]

    "${_NB}" notebooks current --local

    run "${_NB}" add "local.md" --content "Example content from local."

    [[ ${status} -eq 0                                          ]]

    # NB_DIR_1

    [[   -f "${NB_DIR_1}/example-archived/archived.md"          ]]
    [[ ! -f "${NB_DIR_1}/example-archived/global-remote.md"     ]]
    [[ ! -f "${NB_DIR_1}/example-archived/global-no-remote.md"  ]]
    [[ ! -f "${NB_DIR_1}/example-archived/local.md"             ]]

    [[ ! -f "${NB_DIR_1}/global-remote/archived.md"             ]]
    [[   -f "${NB_DIR_1}/global-remote/global-remote.md"        ]]
    [[ ! -f "${NB_DIR_1}/global-remote/global-no-remote.md"     ]]
    [[ ! -f "${NB_DIR_1}/global-remote/local.md"                ]]

    [[ ! -f "${NB_DIR_1}/global-no-remote/archived.md"          ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/global-remote.md"     ]]
    [[   -f "${NB_DIR_1}/global-no-remote/global-no-remote.md"  ]]
    [[ ! -f "${NB_DIR_1}/global-no-remote/local.md"             ]]

    [[ ! -f "${NB_DIR_1}/home/example-archived.md"              ]]
    [[ ! -f "${NB_DIR_1}/home/global-remote.md"                 ]]
    [[ ! -f "${NB_DIR_1}/home/global-no-remote.md"              ]]
    [[ ! -f "${NB_DIR_1}/home/local.md"                         ]]

    # NB_DIR_2

    [[ ! -f "${NB_DIR_2}/home/archived.md"                      ]]
    [[ ! -f "${NB_DIR_2}/home/global-remote.md"                 ]]
    [[ ! -f "${NB_DIR_2}/home/global-no-remote.md"              ]]
    [[ ! -f "${NB_DIR_2}/home/local.md"                         ]]

    # local

    [[ ! -f "${_TMP_DIR}/example-local/archived.md"             ]]
    [[ ! -f "${_TMP_DIR}/example-local/global-remote.md"        ]]
    [[ ! -f "${_TMP_DIR}/example-local/global-no-remote.md"     ]]
    [[   -f "${_TMP_DIR}/example-local/local.md"                ]]
  }

  # sync 1: send changes to remote
  run "${_NB}" sync --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ! "${output}" =~ \
    Syncing:\ .*local.*....*local.*....*global-remote.*....*home.*...Done!  ]]
  [[   "${output}" =~ \
    Syncing:\ .*local.*....*global-remote.*....*home.*...Done!              ]]

  [[ ! "${output}" =~ archived                                ]]
  [[ ! "${output}" =~ no-remote                               ]]

  [[ ${status} -eq 0                                          ]]

  # sync 2: sync all again to get changes
  run "${_NB}" sync --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"


  [[ ! "${output}" =~ \
    Syncing:\ .*local.*....*local.*....*global-remote.*....*home.*...Done!  ]]
  [[   "${output}" =~ \
    Syncing:\ .*local.*....*global-remote.*....*home.*...Done!              ]]

  [[ ! "${output}" =~ archived                                ]]
  [[ ! "${output}" =~ no-remote                               ]]

  [[ ${status} -eq 0                                          ]]

  # NB_DIR_1

  [[   -f "${NB_DIR_1}/example-archived/archived.md"          ]]
  [[ ! -f "${NB_DIR_1}/example-archived/global-remote.md"     ]]
  [[ ! -f "${NB_DIR_1}/example-archived/global-no-remote.md"  ]]
  [[ ! -f "${NB_DIR_1}/example-archived/local.md"             ]]

  [[ ! -f "${NB_DIR_1}/global-remote/archived.md"             ]]
  [[   -f "${NB_DIR_1}/global-remote/global-remote.md"        ]]
  [[ ! -f "${NB_DIR_1}/global-remote/global-no-remote.md"     ]]
  [[   -f "${NB_DIR_1}/global-remote/local.md"                ]]

  [[ ! -f "${NB_DIR_1}/global-no-remote/archived.md"          ]]
  [[ ! -f "${NB_DIR_1}/global-no-remote/global-remote.md"     ]]
  [[   -f "${NB_DIR_1}/global-no-remote/global-no-remote.md"  ]]
  [[ ! -f "${NB_DIR_1}/global-no-remote/local.md"             ]]

  [[ ! -f "${NB_DIR_1}/home/example-archived.md"              ]]
  [[   -f "${NB_DIR_1}/home/global-remote.md"                 ]]
  [[ ! -f "${NB_DIR_1}/home/global-no-remote.md"              ]]
  [[   -f "${NB_DIR_1}/home/local.md"                         ]]

  # NB_DIR_2

  [[ ! -f "${NB_DIR_2}/home/archived.md"                      ]]
  [[ ! -f "${NB_DIR_2}/home/global-remote.md"                 ]]
  [[ ! -f "${NB_DIR_2}/home/global-no-remote.md"              ]]
  [[ ! -f "${NB_DIR_2}/home/local.md"                         ]]

  # local

  [[ ! -f "${_TMP_DIR}/example-local/archived.md"             ]]
  [[   -f "${_TMP_DIR}/example-local/global-remote.md"        ]]
  [[ ! -f "${_TMP_DIR}/example-local/global-no-remote.md"     ]]
  [[   -f "${_TMP_DIR}/example-local/local.md"                ]]
}

@test "'sync' succeeds with local notebook." {
  {
    _setup_notebooks

    "${_NB}" notebooks init "${_TMP_DIR}/example-local"

    cd "${_TMP_DIR}/example-local"

    [[ "$(pwd)" == "${_TMP_DIR}/example-local" ]]

    "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}1${_NEWLINE}"

    diff <("${_NB}" remote --url) <(printf "%s\\n" "${_GIT_REMOTE_URL}")

    "${_NB}" notebooks current --local

    run "${_NB}" add "local.md" --content "Example content from local."

    [[    -f "${_TMP_DIR}/example-local/local.md" ]]
    [[ !  -f "${NB_DIR_1}/home/local.md"          ]]
  }

  # sync 1: send changes to remote
  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                          ]]
  [[ -f "${_TMP_DIR}/example-local/local.md"  ]]
  [[ ! -f "${NB_DIR_1}/home/local.md"         ]]

  cd ..

  "${_NB}" notebooks current --local || true

  # sync 2: pull changes from remote
  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                          ]]
  [[ -f "${_TMP_DIR}/example-local/local.md"  ]]
  [[ -f "${NB_DIR_1}/home/local.md"           ]]
}

# sync errors #################################################################

@test "'sync' returns error when notebook has no remote." {
  {
    _setup_notebooks

    "${_NB}" remote remove <<< "y${_NEWLINE}"

    "${_NB}" remote && return 1
  }

  run "${_NB}" sync

  printf "\${status}:   '%s'\\n" "${status}"
  printf "\${output}:   '%s'\\n" "${output}"
  printf "\${lines[2]}: '%s'\\n" "${lines[2]}"

  [[ "${lines[0]}" =~ No\ remote\ configured  ]]
  [[ "${lines[1]}" =~ Set\ the\ remote        ]]
  [[ ${status} -eq 1                          ]]
}

@test "'sync --all' returns error when no unarchived notebooks with remotes found." {
  {
    _setup_notebooks

    "${_NB}" notebooks add example
    "${_NB}" notebooks archive home
    "${_NB}" remote remove <<< "y${_NEWLINE}"

    "${_NB}" remote && return 1
  }

  run "${_NB}" sync --all

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ No\ unarchived\ notebooks ]]
  [[ ${status} -eq 1                            ]]
}

# remote set && sync #########################################################

@test "'sync' fails with invalid remote." {
  {
    _setup_notebooks

    "${_NB}" remote remove <<< "y${_NEWLINE}"

    [[ "$("${_NB}" remote 2>&1)" =~ No\ remote ]]

    "${_NB}" add "one.md" --content "Example content from 1."

    [[    -f "${NB_DIR_1}/home/one.md"  ]]
    [[ !  -f "${NB_DIR_2}/home/one.md"  ]]

    "${_NB}" git remote add origin "https://example.test/invalid.git"

    diff                        \
      <("${_NB}" remote --url)  \
      <(printf "%s\\n" "https://example.test/invalid.git")
  }

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"   -eq 1                                   ]]
  [[    "${lines[0]}" =~  Syncing                             ]]
  [[    "${lines[0]}" =~  home                                ]]
  [[    "${lines[1]}" =~  unable\ to\ access\                 ]]
  [[    "${lines[1]}" =~  https://example.test/invalid.git/   ]]
  [[ !  "${output}"   =~  Done                                ]]
}

@test "'sync' succeeds after 'remote set'" {
  {
    _setup_notebooks

    "${_NB}" remote remove <<< "y${_NEWLINE}"

    [[ "$("${_NB}" remote 2>&1)" =~ No\ remote ]]

    "${_NB}" add "one.md" --content "Example content from 1."

    [[    -f "${NB_DIR_1}/home/one.md"  ]]
    [[ !  -f "${NB_DIR_2}/home/one.md"  ]]
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" <<< "y${_NEWLINE}1${_NEWLINE}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${output}" =~ Remote\ set\ to     ]]
  [[ "${output}" =~ ${_GIT_REMOTE_URL}  ]]
  [[ ${status} -eq 0                    ]]

  # sync 1: send changes to remote
  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Syncing:\ .*home.*...Done! ]]

  export NB_DIR="${NB_DIR_2}"

  # sync 2: pull changes from remote
  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Syncing:\ .*home.*...Done! ]]

  [[ ${status} -eq 0                ]]
  [[ -f "${NB_DIR_1}/home/one.md"   ]]
  [[ -f "${NB_DIR_2}/home/one.md"   ]]
}

# autosync ####################################################################

@test "NB_AUTO_SYNC=1 syncs with 'add'." {
  {
    _setup_notebooks

    [[ ! -f "${NB_DIR_1}/home/one.md" ]]
    [[ ! -f "${NB_DIR_2}/home/one.md" ]]
  }

  export NB_AUTO_SYNC=1

  # sync 1: add with autosync on
  run "${_NB}" add "one.md" --content "Example content from 1."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" env

  [[ -f "${NB_DIR_1}/home/one.md"   ]]
  [[ ! -f "${NB_DIR_2}/home/one.md" ]]

  [[ ${status}      -eq 0           ]]
  [[ "${lines[0]}"  =~ Added        ]]
  [[ "${lines[0]}"  =~ one          ]]
  [[ ! "${output}"  =~ Sync         ]]

  export NB_DIR="${NB_DIR_2}"

  # sync 2: pull changes from remote
  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls -la "${NB_DIR_1}/home/"
  git -C "${NB_DIR_1}/home" status
  ls -la "${NB_DIR_2}/home/"
  git -C "${NB_DIR_2}/home" status

  [[ ${status} -eq 0              ]]
  [[ -f "${NB_DIR_1}/home/one.md" ]]
  [[ -f "${NB_DIR_2}/home/one.md" ]]
}

@test "NB_AUTO_SYNC=0 does not sync with 'add'." {
  {
    _setup_notebooks

    [[ ! -f "${NB_DIR_1}/home/one.md" ]]
    [[ ! -f "${NB_DIR_2}/home/one.md" ]]
  }

  export NB_AUTO_SYNC=0

  # sync 1: add with autosync off
  run "${_NB}" add "one.md" --content "Example content from 1."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" env

  [[ -f "${NB_DIR_1}/home/one.md"   ]]
  [[ ! -f "${NB_DIR_2}/home/one.md" ]]

  [[ ${status}      -eq 0           ]]
  [[ "${lines[0]}"  =~ Added        ]]
  [[ "${lines[0]}"  =~ one          ]]
  [[ ! "${output}"  =~ Sync         ]]

  export NB_DIR="${NB_DIR_2}"

  # sync 2: pull changes from remote
  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls -la "${NB_DIR_1}/home/"
  git -C "${NB_DIR_1}/home" status
  ls -la "${NB_DIR_2}/home/"
  git -C "${NB_DIR_2}/home" status

  [[ ${status} -eq 0                ]]
  [[ -f "${NB_DIR_1}/home/one.md"   ]]
  [[ ! -f "${NB_DIR_2}/home/one.md" ]]
}

@test "NB_AUTO_SYNC=1 syncs dirty repo." {
  {
    _setup_notebooks

    touch "${NB_DIR_1}/home/one.md"

    [[ -f "${NB_DIR_1}/home/one.md"   ]]
    [[ ! -f "${NB_DIR_2}/home/one.md" ]]

    "${_NB}" git dirty
  }

  export NB_AUTO_SYNC=1

  # sync 1: autosync on with no subcommand
  run "${_NB}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" env

  [[ -f "${NB_DIR_1}/home/one.md"   ]]
  [[ ! -f "${NB_DIR_2}/home/one.md" ]]

  [[ ${status}      -eq 0           ]]
  [[ "${lines[0]}"  =~ home         ]]
  [[ "${lines[2]}"  =~ one          ]]
  [[ ! "${output}"  =~ Sync         ]]

  export NB_DIR="${NB_DIR_2}"

  # sync 2: pull changes from remote
  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls -la "${NB_DIR_1}/home/"
  git -C "${NB_DIR_1}/home" status
  ls -la "${NB_DIR_2}/home/"
  git -C "${NB_DIR_2}/home" status

  [[ ${status} -eq 0              ]]
  [[ -f "${NB_DIR_1}/home/one.md" ]]
  [[ -f "${NB_DIR_2}/home/one.md" ]]
}

@test "NB_AUTO_SYNC=0 does not sync dirty repo." {
  {
    _setup_notebooks

    touch "${NB_DIR_1}/home/one.md" 

    [[ -f "${NB_DIR_1}/home/one.md"   ]]
    [[ ! -f "${NB_DIR_2}/home/one.md" ]]

    "${_NB}" git dirty
  }

  export NB_AUTO_SYNC=0

  # sync 1: autosync off with no subcommand
  run "${_NB}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" env

  [[ -f "${NB_DIR_1}/home/one.md"   ]]
  [[ ! -f "${NB_DIR_2}/home/one.md" ]]

  [[ ${status}      -eq 0           ]]
  [[ "${lines[0]}"  =~ home         ]]
  [[ "${lines[2]}"  =~ one          ]]
  [[ ! "${output}"  =~ Sync         ]]

  export NB_DIR="${NB_DIR_2}"

  # sync 2: pull changes from remote
  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  ls -la "${NB_DIR_1}/home/"
  git -C "${NB_DIR_1}/home" status
  ls -la "${NB_DIR_2}/home/"
  git -C "${NB_DIR_2}/home" status

  [[ ${status} -eq 0                ]]
  [[ -f "${NB_DIR_1}/home/one.md"   ]]
  [[ ! -f "${NB_DIR_2}/home/one.md" ]]
}

@test "NB_AUTO_SYNC=1 with error fails silently." {
  {
    _setup_notebooks
    mv "${_GIT_REMOTE_PATH}" "${_GIT_REMOTE_PATH}.bak"

    [[ ! -f "${NB_DIR_1}/home/one.md" ]]
    [[ ! -f "${NB_DIR_2}/home/one.md" ]]
  }

  export NB_AUTO_SYNC=1

  # sync 1: add with autosync
  run "${_NB}" add "one.md" --content "Example content from 1."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ -f "${NB_DIR_1}/home/one.md"   ]]
  [[ ! -f "${NB_DIR_2}/home/one.md" ]]

  [[ ${status}      -eq 0           ]]
  [[ "${lines[0]}"  =~ Added        ]]
  [[ "${lines[0]}"  =~ one          ]]
  [[ ! "${output}"  =~ Sync         ]]

  mv "${_GIT_REMOTE_PATH}.bak" "${_GIT_REMOTE_PATH}"

  export NB_DIR="${NB_DIR_2}"

  # sync 2: pull changes from remote
  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                ]]
  [[ -f "${NB_DIR_1}/home/one.md"   ]]
  [[ ! -f "${NB_DIR_2}/home/one.md" ]]
}

# sync ########################################################################

@test "'sync' succeeds when files are added and removed from two clones." {
  # skip
  {
    _setup_notebooks
    "${_NB}" add "one.md" --content "Example content from 1."

    export NB_DIR="${NB_DIR_2}"
    "${_NB}" add "two.md" --content "Example content from 2."

    export NB_DIR="${NB_DIR_1}"
  }

  # sync 1: send changes to remote
  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "(1)\\n"
  printf "index 1:\\n"
  cat "${NB_DIR_1}/home/.index"
  printf "index 2:\\n"
  cat "${NB_DIR_2}/home/.index"

  [[ ${status} -eq 0                                ]]
  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count)" == 1  ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count)" == 1  ]]
  [[ "$(cat "${NB_DIR_1}/home/.index")" == "one.md" ]]
  [[ "$(cat "${NB_DIR_2}/home/.index")" == "two.md" ]]

  export NB_DIR="${NB_DIR_2}"

  # sync 2: pull changes from remote, rebase, send new changes back to remote
  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "(2)\\n"
  printf "index 1:\\n"
  cat "${NB_DIR_1}/home/.index"
  printf "index 2:\\n"
  cat "${NB_DIR_2}/home/.index"

  [[ ${status} -eq 0                                                  ]]
  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count)" == 1                    ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count)" == 2                    ]]
  [[ "$(cat "${NB_DIR_1}/home/.index")" == "one.md"                   ]]
  [[ "$(cat "${NB_DIR_2}/home/.index")" == "one.md${_NEWLINE}two.md"  ]]

  # sync 3: pull changes from remote
  export NB_DIR="${NB_DIR_1}"

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "(3)\\n"
  printf "index 1:\\n"
  cat "${NB_DIR_1}/home/.index"
  printf "index 2:\\n"
  cat "${NB_DIR_2}/home/.index"

  [[ ${status} -eq 0                                                  ]]
  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count)" == 2                    ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count)" == 2                    ]]
  [[ "$(cat "${NB_DIR_1}/home/.index")" == "one.md${_NEWLINE}two.md"  ]]
  [[ "$(cat "${NB_DIR_2}/home/.index")" == "one.md${_NEWLINE}two.md"  ]]

  # Add more notes to each clone

  export NB_DIR="${NB_DIR_1}"
  run "${_NB}" add "one-2.md" --content "Example content from 1."

  export NB_DIR="${NB_DIR_2}"
  run "${_NB}" add "two-2.md" --content "Example content from 2."

  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count)" == 3  ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count)" == 3  ]]
  [[ "$(cat "${NB_DIR_1}/home/.index")" == "one.md${_NEWLINE}two.md${_NEWLINE}one-2.md"  ]]
  [[ "$(cat "${NB_DIR_2}/home/.index")" == "one.md${_NEWLINE}two.md${_NEWLINE}two-2.md"  ]]

  # sync 4: send new changes to remote
  export NB_DIR="${NB_DIR_2}"

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "(4)\\n"
  printf "index 1:\\n"
  cat "${NB_DIR_1}/home/.index"
  printf "index 2:\\n"
  cat "${NB_DIR_2}/home/.index"

  [[ ${status} -eq 0                                ]]
  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count)" == 3  ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count)" == 3  ]]
  [[ "$(cat "${NB_DIR_1}/home/.index")" == "one.md${_NEWLINE}two.md${_NEWLINE}one-2.md"  ]]
  [[ "$(cat "${NB_DIR_2}/home/.index")" == "one.md${_NEWLINE}two.md${_NEWLINE}two-2.md"  ]]

  # sync 5: pull changes from remote, rebase, send new changes back to remote
  export NB_DIR="${NB_DIR_1}"

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "(5)\\n"
  printf "index 1:\\n"
  cat "${NB_DIR_1}/home/.index"
  printf "index 2:\\n"
  cat "${NB_DIR_2}/home/.index"

  [[ ${status} -eq 0                                                  ]]
  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count)" == 4                    ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count)" == 3                    ]]
  [[ "$(cat "${NB_DIR_1}/home/.index")" == \
     "one.md${_NEWLINE}two.md${_NEWLINE}two-2.md${_NEWLINE}one-2.md"  ]]
  [[ "$(cat "${NB_DIR_2}/home/.index")" == \
     "one.md${_NEWLINE}two.md${_NEWLINE}two-2.md"                     ]]

  # sync 6: pull changes from remote
  export NB_DIR="${NB_DIR_2}"

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "(6)\\n"
  printf "index 1:\\n"
  cat "${NB_DIR_1}/home/.index"
  printf "index 2:\\n"
  cat "${NB_DIR_2}/home/.index"

  [[ ${status} -eq 0                                                  ]]
  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count)" == 4                    ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count)" == 4                    ]]
  [[ "$(cat "${NB_DIR_1}/home/.index")" == \
     "one.md${_NEWLINE}two.md${_NEWLINE}two-2.md${_NEWLINE}one-2.md"  ]]
  [[ "$(cat "${NB_DIR_2}/home/.index")" == \
     "one.md${_NEWLINE}two.md${_NEWLINE}two-2.md${_NEWLINE}one-2.md"  ]]

  # add more notes to and remove notes from each clone

  export NB_DIR="${NB_DIR_1}"
  run "${_NB}" add "one-3.md" --content "Example content from 1."
  run "${_NB}" delete "two.md" --force

  export NB_DIR="${NB_DIR_2}"
  run "${_NB}" add "two-3.md" --content "Example content from 2."

  printf "(6.5)\\n"
  NB_DIR="${NB_DIR_1}" "${_NB}" count
  printf "index 1:\\n"
  cat "${NB_DIR_1}/home/.index"
  NB_DIR="${NB_DIR_2}" "${_NB}" count
  printf "index 2:\\n"
  cat "${NB_DIR_2}/home/.index"

  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count)" == 4 ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count)" == 5 ]]
  [[ "$(cat "${NB_DIR_1}/home/.index")" == \
    "one.md${_NEWLINE}${_NEWLINE}two-2.md${_NEWLINE}one-2.md${_NEWLINE}one-3.md"        ]]
  [[ "$(cat "${NB_DIR_2}/home/.index")" == \
    "one.md${_NEWLINE}two.md${_NEWLINE}two-2.md${_NEWLINE}one-2.md${_NEWLINE}two-3.md"  ]]

  # sync 7: push changes to remote
  export NB_DIR="${NB_DIR_2}"

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "(7)\\n"
  NB_DIR="${NB_DIR_1}" "${_NB}" count
  printf "index 1:\\n"
  cat "${NB_DIR_1}/home/.index"
  NB_DIR="${NB_DIR_2}" "${_NB}" count
  printf "index 2:\\n"
  cat "${NB_DIR_2}/home/.index"

  [[ ${status} -eq 0                                ]]
  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count)" == 4  ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count)" == 5  ]]
  [[ "$(cat "${NB_DIR_1}/home/.index")" == \
    "one.md${_NEWLINE}${_NEWLINE}two-2.md${_NEWLINE}one-2.md${_NEWLINE}one-3.md"        ]]
  [[ "$(cat "${NB_DIR_2}/home/.index")" == \
    "one.md${_NEWLINE}two.md${_NEWLINE}two-2.md${_NEWLINE}one-2.md${_NEWLINE}two-3.md"  ]]

  # sync 8: pull changes from remote
  export NB_DIR="${NB_DIR_1}"

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "(8)\\n"
  NB_DIR="${NB_DIR_1}" "${_NB}" count
  printf "index 1:\\n"
  cat "${NB_DIR_1}/home/.index"
  NB_DIR="${NB_DIR_2}" "${_NB}" count
  printf "index 2:\\n"
  cat "${NB_DIR_2}/home/.index"

  [[ ${status} -eq 0                                ]]
  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count)" == 5  ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count)" == 5  ]]
  [[ "$(cat "${NB_DIR_1}/home/.index")" == \
     "one.md${_NEWLINE}${_NEWLINE}two-2.md${_NEWLINE}one-2.md${_NEWLINE}two-3.md${_NEWLINE}one-3.md"  ]]
  [[ "$(cat "${NB_DIR_2}/home/.index")" == \
     "one.md${_NEWLINE}two.md${_NEWLINE}two-2.md${_NEWLINE}one-2.md${_NEWLINE}two-3.md"               ]]

  # sync 9: push changes to remote
  export NB_DIR="${NB_DIR_1}"

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "(9)\\n"
  NB_DIR="${NB_DIR_1}" "${_NB}" count
  printf "index 1:\\n"
  cat "${NB_DIR_1}/home/.index"
  NB_DIR="${NB_DIR_2}" "${_NB}" count
  printf "index 2:\\n"
  cat "${NB_DIR_2}/home/.index"

  [[ ${status} -eq 0                                ]]
  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count)" == 5  ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count)" == 5  ]]
  [[ "$(cat "${NB_DIR_1}/home/.index")" == \
     "one.md${_NEWLINE}${_NEWLINE}two-2.md${_NEWLINE}one-2.md${_NEWLINE}two-3.md${_NEWLINE}one-3.md"  ]]
  [[ "$(cat "${NB_DIR_2}/home/.index")" == \
     "one.md${_NEWLINE}two.md${_NEWLINE}two-2.md${_NEWLINE}one-2.md${_NEWLINE}two-3.md"               ]]

  # sync 10: pull changes from remote
  export NB_DIR="${NB_DIR_2}"

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "(10)\\n"
  NB_DIR="${NB_DIR_1}" "${_NB}" count
  printf "index 1:\\n"
  cat "${NB_DIR_1}/home/.index"
  NB_DIR="${NB_DIR_2}" "${_NB}" count
  printf "index 2:\\n"
  cat "${NB_DIR_2}/home/.index"

  [[ ${status} -eq 0                                ]]
  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count)" == 5  ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count)" == 5  ]]
  [[ "$(cat "${NB_DIR_1}/home/.index")" == \
     "one.md${_NEWLINE}${_NEWLINE}two-2.md${_NEWLINE}one-2.md${_NEWLINE}two-3.md${_NEWLINE}one-3.md"  ]]
  [[ "$(cat "${NB_DIR_2}/home/.index")" == \
     "one.md${_NEWLINE}${_NEWLINE}two-2.md${_NEWLINE}one-2.md${_NEWLINE}two-3.md${_NEWLINE}one-3.md"  ]]
}

@test "'sync' succeeds when one file is edited on two clones." {
  # skip

  _setup_notebooks

  export NB_DIR="${NB_DIR_1}"

  run "${_NB}" add "one.md" --content "Example content from 1.

- Line 3 List Item
- Line 4 List Item
- Line 5 List Item
"
  run "${_NB}" sync

  export NB_DIR="${NB_DIR_2}"

  run "${_NB}" sync

  # ls -la "${NB_DIR_2}"

  _sed_i 's/Line 4/Line n/' "${NB_DIR_2}/home/one.md"

  run "${_NB}" &>/dev/null
  run "${_NB}" sync

  export NB_DIR="${NB_DIR_1}"

  _sed_i 's/Line 4/Line x/' "${NB_DIR_1}/home/one.md"

  run "${_NB}" &>/dev/null
  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  cat "${NB_DIR_1}/home/one.md"

  [[ ${status} -eq 0                              ]]
  [[ ${output} =~ Files\ containing\ conflicts\:  ]]
  [[ ${output} =~ home\:one\.md                   ]]

  grep -q '<<<<<<< HEAD'        "${NB_DIR_1}/home/one.md"
  grep -q '\- Line n List Item' "${NB_DIR_1}/home/one.md"
  grep -q '======='             "${NB_DIR_1}/home/one.md"
  grep -q '\- Line x List Item' "${NB_DIR_1}/home/one.md"
  grep -q '>>>>>>>'             "${NB_DIR_1}/home/one.md"
  grep -q '\[nb\] Commit'       "${NB_DIR_1}/home/one.md"
  grep -q '\- Line 5 List Item' "${NB_DIR_1}/home/one.md"
}

@test "'sync' succeeds when multiple files are edited on two clones." {
  # skip
  _setup_notebooks

  export NB_DIR="${NB_DIR_1}"

  run "${_NB}" add "one.md" --content "Example content from 1.

- Line 3 List Item
- Line 4 List Item
- Line 5 List Item
"

  run "${_NB}" add "two.md" --content "Example content from 1.

- Line 3 List Item
- Line 4 List Item
- Line 5 List Item
"

  run "${_NB}" add "three.md" --content "Example content from 1.

- Line 3 List Item
- Line 4 List Item
- Line 5 List Item
"
  run "${_NB}" sync

  export NB_DIR="${NB_DIR_2}"

  run "${_NB}" sync

  # ls -la "${NB_DIR_2}"

  _sed_i 's/Line 4/Line n/' "${NB_DIR_2}/home/one.md"
  _sed_i 's/Line 4/Line n/' "${NB_DIR_2}/home/two.md"
  _sed_i 's/Line 4/Line n/' "${NB_DIR_2}/home/three.md"

  run "${_NB}" &>/dev/null
  run "${_NB}" sync

  export NB_DIR="${NB_DIR_1}"

  _sed_i 's/Line 4/Line x/' "${NB_DIR_1}/home/one.md"
  _sed_i 's/Line 4/Line x/' "${NB_DIR_1}/home/two.md"
  _sed_i 's/Line 4/Line x/' "${NB_DIR_1}/home/three.md"

  run "${_NB}" &>/dev/null
  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  cat "${NB_DIR_1}/home/one.md"

  [[ ${status} -eq 0                              ]]
  [[ ${output} =~ Files\ containing\ conflicts\:  ]]
  [[ ${output} =~ home\:one\.md                   ]]
  [[ ${output} =~ home\:two\.md                   ]]
  [[ ${output} =~ home\:three\.md                 ]]

  grep -q '<<<<<<< HEAD'        "${NB_DIR_1}/home/one.md"
  grep -q '\- Line n List Item' "${NB_DIR_1}/home/one.md"
  grep -q '======='             "${NB_DIR_1}/home/one.md"
  grep -q '\- Line x List Item' "${NB_DIR_1}/home/one.md"
  grep -q '>>>>>>>'             "${NB_DIR_1}/home/one.md"
  grep -q '\[nb\] Commit'       "${NB_DIR_1}/home/one.md"
  grep -q '\- Line 5 List Item' "${NB_DIR_1}/home/one.md"

  grep -q '<<<<<<< HEAD'        "${NB_DIR_1}/home/two.md"
  grep -q '\- Line n List Item' "${NB_DIR_1}/home/two.md"
  grep -q '======='             "${NB_DIR_1}/home/two.md"
  grep -q '\- Line x List Item' "${NB_DIR_1}/home/two.md"
  grep -q '>>>>>>>'             "${NB_DIR_1}/home/two.md"
  grep -q '\[nb\] Commit'       "${NB_DIR_1}/home/two.md"
  grep -q '\- Line 5 List Item' "${NB_DIR_1}/home/two.md"

  grep -q '<<<<<<< HEAD'        "${NB_DIR_1}/home/three.md"
  grep -q '\- Line n List Item' "${NB_DIR_1}/home/three.md"
  grep -q '======='             "${NB_DIR_1}/home/three.md"
  grep -q '\- Line x List Item' "${NB_DIR_1}/home/three.md"
  grep -q '>>>>>>>'             "${NB_DIR_1}/home/three.md"
  grep -q '\[nb\] Commit'       "${NB_DIR_1}/home/three.md"
  grep -q '\- Line 5 List Item' "${NB_DIR_1}/home/three.md"
}

@test "'sync' succeeds when the same filename is added on two clones." {
  # skip
  _setup_notebooks

  export NB_DIR="${NB_DIR_1}"

  run "${_NB}" add "one.md" --content "Example content from 1.

- Line 3 List Item
- Line 4 List Item
- Line 5 List Item
"
  run "${_NB}" sync

  export NB_DIR="${NB_DIR_2}"

  run "${_NB}" add "one.md" --content "Example different content from 2.

This content is unique to 2.
"

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "1:one.md\\n"
  cat "${NB_DIR_1}/home/one.md"
  printf "2:one.md\\n"
  cat "${NB_DIR_2}/home/one.md"

  [[ ${status} -eq 0                              ]]
  [[ ${output} =~ Files\ containing\ conflicts\:  ]]
  [[ ${output} =~ home\:one\.md                   ]]

  grep -q '<<<<<<< HEAD'              "${NB_DIR_2}/home/one.md"
  grep -q 'Example content from 1.'   "${NB_DIR_2}/home/one.md"
  grep -q '\- Line 3 List Item'       "${NB_DIR_2}/home/one.md"
  grep -q '======='                   "${NB_DIR_2}/home/one.md"
  grep -q 'Example different content' "${NB_DIR_2}/home/one.md"
  grep -q '>>>>>>>'                   "${NB_DIR_2}/home/one.md"
  grep -q '\[nb\] Add\: one.md'       "${NB_DIR_2}/home/one.md"
}

@test "'sync' succeeds when an encrypted file is edited on two clones." {
  # skip

  _setup_notebooks

  export NB_DIR="${NB_DIR_1}"

  run "${_NB}" add "one.md"       \
    --encrypt --password password \
    --content "Example content from 1.

- Line 3 List Item
- Line 4 List Item
- Line 5 List Item
"
  run "${_NB}" sync

  [[ -e "${NB_DIR_1}/home/one.md.enc"                     ]]
  [[ ! -e "${NB_DIR_1}/home/one--conflicted-copy.md.enc"  ]]

  [[ ! -e "${NB_DIR_2}/home/one.md.enc"                   ]]
  [[ ! -e "${NB_DIR_2}/home/one--conflicted-copy.md.enc"  ]]

  export NB_DIR="${NB_DIR_2}"

  [[ ! "$(
          "${_NB}" show one.md.enc --password password --print --no-color
        )" =~ Edit\ content\ from\ 1\.                    ]]
  [[ ! "$(
          "${_NB}" show one.md.enc --password password --print --no-color
        )" =~ Edit\ content\ from\ 2\.                    ]]

  run "${_NB}" sync

  [[ -e "${NB_DIR_1}/home/one.md.enc"                     ]]
  [[ ! -e "${NB_DIR_1}/home/one--conflicted-copy.md.enc"  ]]

  [[ -e "${NB_DIR_2}/home/one.md.enc"                     ]]
  [[ ! -e "${NB_DIR_2}/home/one--conflicted-copy.md.enc"  ]]

  [[ "$(_get_hash "${NB_DIR_1}/home/one.md.enc")" == \
     "$(_get_hash "${NB_DIR_2}/home/one.md.enc")"         ]]

  ls -la "${NB_DIR_2}"

  echo "Edit content from 2." | "${_NB}" edit 1 --password password

  run "${_NB}" sync

  [[ -e "${NB_DIR_1}/home/one.md.enc"                     ]]
  [[ ! -e "${NB_DIR_1}/home/one--conflicted-copy.md.enc"  ]]

  [[ -e "${NB_DIR_2}/home/one.md.enc"                     ]]
  [[ ! -e "${NB_DIR_2}/home/one--conflicted-copy.md.enc"  ]]

  [[ "$(_get_hash "${NB_DIR_1}/home/one.md.enc")" != \
     "$(_get_hash "${NB_DIR_2}/home/one.md.enc")"         ]]

  [[ "$(
        "${_NB}" show one.md.enc --password password --print --no-color
      )" =~ Edit\ content\ from\ 2\.                      ]]

  export NB_DIR="${NB_DIR_1}"

  _before="$(
    _get_hash "${NB_DIR_1}/home/one.md.enc"
  )"

  echo "Edit content from 1." | "${_NB}" edit 1 --password password

  _after="$(
    _get_hash "${NB_DIR_1}/home/one.md.enc"
  )"

  printf "\${_before}:  %s\\n" "${_before}"
  printf "\${_after}:   %s\\n" "${_after}"

  [[ "${_before}" != "${_after}"      ]]

  [[ "$(
        "${_NB}" show one.md.enc --password password --print --no-color
      )" =~ Edit\ content\ from\ 1\.  ]]

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "$(_get_hash "${NB_DIR_1}/home/one.md.enc")" != \
     "$(_get_hash "${NB_DIR_2}/home/one.md.enc")"         ]]

  [[ ${status} -eq 0                                      ]]

  [[ -e "${NB_DIR_1}/home/one.md.enc"                     ]]
  [[ -e "${NB_DIR_1}/home/one--conflicted-copy.md.enc"    ]]

  [[ -e "${NB_DIR_2}/home/one.md.enc"                     ]]
  [[ ! -e "${NB_DIR_2}/home/one--conflicted-copy.md.enc"  ]]

  [[ "$(_get_hash "${NB_DIR_1}/home/one.md.enc")" != \
     "$(_get_hash "${NB_DIR_2}/home/one.md.enc")"         ]]

  [[ "$(_get_hash "${NB_DIR_1}/home/one--conflicted-copy.md.enc")" == \
     "$(_get_hash "${NB_DIR_2}/home/one.md.enc")"         ]]

  [[ ${output} =~ Conflicted\ copies\ of\ binary\ files\: ]]
  [[ ${output} =~ home\:one\-\-conflicted-copy\.md\.enc   ]]

  [[ "$(
        "${_NB}" show one.md.enc --password password --print --no-color
      )" =~ Edit\ content\ from\ 1\.                      ]]
  [[ "$(
        "${_NB}" show one--conflicted-copy.md.enc --password password --print --no-color
      )" =~ Edit\ content\ from\ 2\.                      ]]

  export NB_DIR="${NB_DIR_2}"

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                                                ]]

  [[ -e "${NB_DIR_1}/home/one.md.enc"                               ]]
  [[ -e "${NB_DIR_1}/home/one--conflicted-copy.md.enc"              ]]

  [[ -e "${NB_DIR_2}/home/one.md.enc"                               ]]
  [[ -e "${NB_DIR_2}/home/one--conflicted-copy.md.enc"              ]]

  [[ "$(_get_hash "${NB_DIR_1}/home/one.md.enc")" == \
     "$(_get_hash "${NB_DIR_2}/home/one.md.enc")"                   ]]

  [[ "$(_get_hash "${NB_DIR_1}/home/one--conflicted-copy.md.enc")" == \
     "$(_get_hash "${NB_DIR_2}/home/one--conflicted-copy.md.enc")"  ]]

  [[ "$(_get_hash "${NB_DIR_1}/home/one.md.enc")" != \
     "$(_get_hash "${NB_DIR_1}/home/one--conflicted-copy.md.enc")"  ]]

  [[ "$(
        "${_NB}" show one.md.enc --password password --print --no-color
      )" =~ Edit\ content\ from\ 1\.                                ]]
  [[ "$(
        "${_NB}" show one--conflicted-copy.md.enc --password password --print --no-color
      )" =~ Edit\ content\ from\ 2\.                                ]]
}

@test "'sync' notebooks exist after setup." {
  _setup_notebooks

  [[ -d "${_GIT_REMOTE_PATH}"     ]]
  [[ "${NB_DIR_1}" == "${NB_DIR}" ]]
  [[ -d "${NB_DIR_1}/home/.git"   ]]
  [[ -d "${NB_DIR_2}/home/.git"   ]]
}
