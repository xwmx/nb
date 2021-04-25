#!/usr/bin/env bats

load test_helper

# `unarchive` #################################################################

@test "'unarchive' exits with 0 and unarchives the current notebook." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks use "Example Notebook"

    diff                                    \
      <("${_NB}" notebooks current --name)  \
      <(printf "Example Notebook\\n")

    "${_NB}" archive

    [[    -f "${NB_DIR}/Example Notebook/.archived" ]]
  }

  run "${_NB}" unarchive

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                                   ]]
  [[ "${output}"  ==  "$(_color_primary "Example Notebook") unarchived."  ]]

  [[ !  -f "${NB_DIR}/Example Notebook/.archived"   ]]

  # Creates git commit

  cd "${NB_DIR}/Example Notebook" || return 1

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done

  git log | grep '\[nb\] Unarchived'
}

@test "'unarchive <name>' exits with 0 and unarchives notebook <name>." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    diff                                    \
      <("${_NB}" notebooks current --name)  \
      <(printf "home\\n")

    "${_NB}" archive "Example Notebook"

    [[    -f "${NB_DIR}/Example Notebook/.archived" ]]
  }

  run "${_NB}" unarchive "Example Notebook"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                                   ]]
  [[ "${output}"  ==  "$(_color_primary "Example Notebook") unarchived."  ]]

  [[ !  -f "${NB_DIR}/Example Notebook/.archived"   ]]

  # Creates git commit

  cd "${NB_DIR}/Example Notebook" || return 1

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done

  git log | grep '\[nb\] Unarchived'
}

@test "'archive' does not create git commit if already archived." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks use "Example Notebook"

    diff                                    \
      <("${_NB}" notebooks current --name)  \
      <(printf "Example Notebook\\n")

    [[ !  -f "${NB_DIR}/Example Notebook/.archived" ]]
  }

  run "${_NB}" unarchive

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                             ]]

  # NOTE: Spinner changes output in unexpected ways.
  [[ "${output}"  =~  Example\ Notebook             ]]
  [[ "${output}"  =~  unarchived\.$                 ]]

  [[ !  -f "${NB_DIR}/Example Notebook/.archived"   ]]

  # Does not create git commit

  cd "${NB_DIR}/Example Notebook" || return 1

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done

  ! git log | grep -q '\[nb\] Unarchived'
}
