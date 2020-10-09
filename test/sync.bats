#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

load test_helper

_setup_notebooks() {
  _setup_remote_repo

  export NB_DIR_1="${_TMP_DIR}/notebook-1"
  export NB_DIR_2="${_TMP_DIR}/notebook-2"

  export NB_DIR="${NB_DIR_1}"

  run "${_NB}" init "${_GIT_REMOTE_URL}"

  export NB_DIR="${NB_DIR_2}"

  run "${_NB}" init "${_GIT_REMOTE_URL}"

  export NB_DIR="${NB_DIR_1}"
}

@test "\`sync\` notebooks exist after setup" {
  _setup_notebooks

  [[ -d "${_GIT_REMOTE_PATH}"     ]]
  [[ "${NB_DIR_1}" == "${NB_DIR}" ]]
  [[ -d "${NB_DIR_1}/home/.git"   ]]
  [[ -d "${NB_DIR_2}/home/.git"   ]]
}

# remote set && sync #########################################################

@test "\`sync\` returns error with missing remote branch." {
  {
    _setup_notebooks

    git -C "${_TMP_DIR}/notebook-1/home" checkout -b example-branch
    git -C "${_TMP_DIR}/notebook-1/home" branch -d master

    run "${_NB}" remote set "${_GIT_REMOTE_URL}" --force

     NB_AUTO_SYNC=0 run "${_NB}" add "one.md" --content "Example content from 1."

    [[ -f "${NB_DIR_1}/home/one.md"   ]]
    [[ ! -f "${NB_DIR_2}/home/one.md" ]]
  }

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Remote\ branch\ not\ found: ]]
  [[ "${lines[0]}" =~ example-branch              ]]
  [[ ${status} -eq 0                              ]]
}

@test "\`sync\` fails gracefully with invalid remote." {
  {
    _setup_notebooks

    run "${_NB}" remote remove --force

    [[ "$("${_NB}" remote)" =~ No\ remote ]]

    run "${_NB}" add "one.md" --content "Example content from 1."

    [[ -f "${NB_DIR_1}/home/one.md"   ]]
    [[ ! -f "${NB_DIR_2}/home/one.md" ]]
  }

  run "${_NB}" remote set "https://example.test/invalid.git" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Remote\ set\ to ]]
  [[ "${lines[0]}" =~ invalid         ]]
  [[ ${status} -eq 0                  ]]

  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                  ]]
  [[ "$output}" =~ Unable\ to\ fetch  ]]
}

@test "\`sync\` succeeds after \`remote set\`" {
  {
    _setup_notebooks

    run "${_NB}" remote remove --force

    [[ "$("${_NB}" remote)" =~ No\ remote ]]

    run "${_NB}" add "one.md" --content "Example content from 1."

    [[ -f "${NB_DIR_1}/home/one.md"   ]]
    [[ ! -f "${NB_DIR_2}/home/one.md" ]]
  }

  run "${_NB}" remote set "${_GIT_REMOTE_URL}" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[0]}" =~ Remote\ set\ to     ]]
  [[ "${lines[0]}" =~ ${_GIT_REMOTE_URL}  ]]
  [[ ${status} -eq 0                      ]]

  # Sync 1, send changes to remote
  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  export NB_DIR="${NB_DIR_2}"

  # Sync 2, pull changes from remote
  run "${_NB}" sync

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0              ]]
  [[ -f "${NB_DIR_2}/home/one.md" ]]
}

# sync ########################################################################

@test "\`sync\` succeeds when files are added and removed from two clones" {
  # skip
  {
    _setup_notebooks
    run "${_NB}" add "one.md" --content "Example content from 1."

    export NB_DIR="${NB_DIR_2}"
    run "${_NB}" add "two.md" --content "Example content from 2."

    export NB_DIR="${NB_DIR_1}"
  }

  # Sync 1, send changes to remote
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

  # Sync 2, pull changes from remote, rebasing, and sending new changes
  # back to remote
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

  # Sync 3, pull changes from remote
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

  # Sync 4, send new changes to remote
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

  # Sync 5, pull changes from remote, rebasing, and sending new changes back
  # to remote
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

  # Sync 6, pull changes from remote
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

  # Add more and remove notes to each clone

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

  # Sync 7, push changes to remote
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

  # Sync 8, pull changes from remote
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

  # Sync 9, push changes to remote
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

  # Sync 10, pull changes from remote
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

@test "\`sync\` succeeds when one file is edited on two clones" {
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

@test "\`sync\` succeeds when multiple files are edited on two clones" {
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

@test "\`sync\` succeeds when the same filename is added on two clones" {
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

@test "\`sync\` succeeds when an encrypted file is edited on two clones" {
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
