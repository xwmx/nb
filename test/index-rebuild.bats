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

    echo "" > "${NB_DIR}/home/.index"

    [[ "$(cat "${NB_DIR}/home/.index")" == "" ]]
  }

  run "${_NB}" index rebuild

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  ls -t -r "${NB_DIR}/home"

  [[ ${status} -eq 0                                                    ]]
  [[ "$(cat "${NB_DIR}/home/.index")" == "$(ls -t -r "${NB_DIR}/home")" ]]
}

@test "'index rebuild' creates git commit." {
  {
    "${_NB}" init
    "${_NB}" add

    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"

    "${_NB}" delete "${_filename}" --force
    "${_NB}" add
  }

  run "${_NB}" index rebuild

  cd "${NB_DIR}/home" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Rebuild Index'
}

@test "'index rebuild' with no index creates git commit with operation-specific message." {
  {
    "${_NB}" init
    "${_NB}" notebooks add one
    "${_NB}" use one
    "${_NB}" add --filename "example.md"

    [[   -e "${NB_DIR:?}/one/.index"      ]]
    [[   -e "${NB_DIR:?}/one/example.md"  ]]

    rm "${NB_DIR:?}/one/.index"

    "${_NB}" git checkpoint

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
