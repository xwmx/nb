load test_helper

@test "'sync' returns error with missing remote branch." {
  {
    _setup_remote_repo

    export NB_DIR_1="${_TMP_DIR}/nbdir-1"
    export NB_DIR_2="${_TMP_DIR}/nbdir-2"

    export NB_DIR="${NB_DIR_1}"

    "${_NB}" init "${_GIT_REMOTE_URL}"

    export NB_DIR="${NB_DIR_2}"

    "${_NB}" init "${_GIT_REMOTE_URL}"

    export NB_DIR="${NB_DIR_1}"

    git -C "${NB_DIR_1}/home" checkout -b example-branch
    git -C "${NB_DIR_1}/home" branch -D master

    NB_AUTO_SYNC=0 "${_NB}" add "one.md" --content "Example content from 1."

    [[ -f "${NB_DIR_1}/home/one.md"   ]]
    [[ ! -f "${NB_DIR_2}/home/one.md" ]]
  }

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status}      -eq 1                           ]]
  [[ "${lines[0]}"  =~  Remote\ branch\ not\ found: ]]
  [[ "${lines[0]}"  =~  example-branch              ]]
  [[ ! "${output}"  =~  Done                        ]]
}
