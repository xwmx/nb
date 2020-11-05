#!/usr/bin/env bats

load test_helper

# index rebuild ###############################################################

@test "'index rebuild' rebuilds the index." {
  {
    "${_NB}" init
    "${_NB}" add "first.md"  --title "one"
    "${_NB}" add "second.md" --title "two"
    "${_NB}" add "third.md"  --title "three"

    "${_NB}" edit "second.md" --content "New conent."

    echo "" > "${_NOTEBOOK_PATH}/.index"

    [[ "$(cat "${_NOTEBOOK_PATH}/.index")" == "" ]]
  }

  run "${_NB}" index rebuild

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  ls -t -r "${_NOTEBOOK_PATH}"

  [[ ${status} -eq 0                                                          ]]
  [[ "$(cat "${_NOTEBOOK_PATH}/.index")" == "$(ls -t -r "${_NOTEBOOK_PATH}")" ]]
}

@test "'index rebuild' creates git commit." {
  {
    run "${_NB}" init
    run "${_NB}" add

    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"

    run "${_NB}" delete "${_filename}" --force
    run "${_NB}" add
  }

  run "${_NB}" index rebuild

  cd "${_NOTEBOOK_PATH}" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Rebuild Index'
}

@test "'index rebuild' with no index creates git commit with operation-specific message." {
  {
    run "${_NB}" init
    run "${_NB}" notebooks add one
    run "${_NB}" use one
    run "${_NB}" add --filename "example.md"

    [[   -e "${NB_DIR:?}/one/.index"      ]]
    [[   -e "${NB_DIR:?}/one/example.md"  ]]

    rm "${NB_DIR:?}/one/.index"

    run "${_NB}" git checkpoint

    [[ ! -e "${NB_DIR:?}/one/.index"      ]]
    [[   -e "${NB_DIR:?}/one/example.md"  ]]

    printf "End setup.\\n"
  }

  run "${_NB}" index rebuild

  [[ "${status}" == 0                   ]]

  [[   -e "${NB_DIR:?}/one/.index"      ]]
  [[   -e "${NB_DIR:?}/one/example.md"  ]]

  diff <(cat "${NB_DIR:?}/one/.index") <(printf "example.md\\n")

  cd "${NB_DIR:?}/one" || return 1

  git log --stat

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Initialize Index'
}
