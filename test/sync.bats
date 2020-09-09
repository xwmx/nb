#!/usr/bin/env bats

load test_helper

_setup_notebooks() {
  _setup_remote_repo

  export NB_DIR_1="${_TMP_DIR}/notebooks-1"
  export NB_DIR_2="${_TMP_DIR}/notebooks-2"

  export NB_DIR="${NB_DIR_1}"

  run "${_NB}" init "${_GIT_REMOTE_URL}"

  export NB_DIR="${NB_DIR_2}"

  run "${_NB}" init "${_GIT_REMOTE_URL}"

  export NB_DIR="${NB_DIR_1}"
}

@test "\`sync\` notebooks exist after setup" {
  {
    _setup_notebooks
  }

  [[ "${NB_DIR_1}" == "${NB_DIR}" ]]
  [[ -d "${NB_DIR_1}/home/.git"   ]]
  [[ -d "${NB_DIR_2}/home/.git"   ]]
}

@test "\`sync\` succeeds when files are added to both clones" {
  {
    _setup_notebooks
    run "${_NB}" add "one.md" --content "Example content from 1."

    export NB_DIR="${NB_DIR_2}"
    run "${_NB}" add "two.md" --content "Example content from 2."

    export NB_DIR="${NB_DIR_1}"
  }

  # Sync 1, sending changes to remote
  run "${_NB}" sync

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

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

  # Sync 2, pulling changes from remote, rebasing, and sending new changes back
  # to remote.
  run "${_NB}" sync

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "index 1:\\n"
  cat "${NB_DIR_1}/home/.index"
  printf "index 2:\\n"
  cat "${NB_DIR_2}/home/.index"

  [[ ${status} -eq 0                                                  ]]
  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count)" == 1                    ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count)" == 2                    ]]
  [[ "$(cat "${NB_DIR_1}/home/.index")" == "one.md"                   ]]
  [[ "$(cat "${NB_DIR_2}/home/.index")" == "one.md${_NEWLINE}two.md"  ]]

  # Sync 1, pulling changes from remote
  export NB_DIR="${NB_DIR_1}"

  run "${_NB}" sync

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

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

  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count)" == 3                    ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count)" == 3                    ]]
  [[ "$(cat "${NB_DIR_1}/home/.index")" == "one.md${_NEWLINE}two.md${_NEWLINE}one-2.md"  ]]
  [[ "$(cat "${NB_DIR_2}/home/.index")" == "one.md${_NEWLINE}two.md${_NEWLINE}two-2.md"  ]]

  # Sync 2, sending new changes to remote.
  export NB_DIR="${NB_DIR_2}"

  run "${_NB}" sync

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  printf "index 1:\\n"
  cat "${NB_DIR_1}/home/.index"
  printf "index 2:\\n"
  cat "${NB_DIR_2}/home/.index"

  [[ ${status} -eq 0                                                  ]]
  [[ "$(NB_DIR="${NB_DIR_1}" "${_NB}" count)" == 3                    ]]
  [[ "$(NB_DIR="${NB_DIR_2}" "${_NB}" count)" == 3                    ]]
  [[ "$(cat "${NB_DIR_1}/home/.index")" == "one.md${_NEWLINE}two.md${_NEWLINE}one-2.md"  ]]
  [[ "$(cat "${NB_DIR_2}/home/.index")" == "one.md${_NEWLINE}two.md${_NEWLINE}two-2.md"  ]]

  # Sync 1, pulling changes from remote, rebasing, and sending new changes back
  # to remote.
  export NB_DIR="${NB_DIR_1}"

  run "${_NB}" sync

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

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

  # Sync 2, pulling changes from remote.
  export NB_DIR="${NB_DIR_2}"

  run "${_NB}" sync

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

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
}
