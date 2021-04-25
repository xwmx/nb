#!/usr/bin/env bats

load test_helper

# <name> validation ###########################################################

@test "'archive <reserved>' exits with 1 and prints error message." {
  {
    "${_NB}" init

    cd "${_TMP_DIR}"

    diff                                    \
      <("${_NB}" notebooks current --name)  \
      <(printf "home\\n")

    declare _names=(
      ".cache"
      ".current"
      ".plugins"
      ".readme"
      "readme"
      "readme.md"
    )
  }

  declare __name=
  for     __name in "${_names[@]}"
  do
    run "${_NB}" archive "${__name}"

    printf "\${status}: '%s'\\n" "${status}"
    printf "\${output}: '%s'\\n" "${output}"

    [[ "${status}"    -eq 1               ]]
    [[ "${lines[0]}"  =~  Name\ reserved  ]]
    [[ "${lines[0]}"  =~  ${__name}       ]]
  done
}

# `archive` ###################################################################

@test "'ar' exits with 0 and archives the current notebook." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks use "Example Notebook"

    diff                                    \
      <("${_NB}" notebooks current --name)  \
      <(printf "Example Notebook\\n")

    [[ !  -f "${NB_DIR}/Example Notebook/.archived" ]]
  }

  run "${_NB}" ar

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                                 ]]
  [[ "${output}"  ==  "$(_color_primary "Example Notebook") archived."  ]]

  [[    -f "${NB_DIR}/Example Notebook/.archived"   ]]

  # Creates git commit

  cd "${NB_DIR}/Example Notebook" || return 1

  while [[ -n "$(git status --porcelain)"           ]]
  do
    sleep 1
  done

  git log | grep -q '\[nb\] Archived'

  cd "${_TMP_DIR}"

  run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                                         ]]

  [[ "${lines[0]}"  =~  ^[[:space:]][[:space:]]*.*home.*\ .*·.*\ \[1\ archived\]$ ]]
  [[ "${output}"    =~  0\ items\.                                                ]]
}

@test "'archive' exits with 0 and archives 'home' when it's the current notebook." {
  {
    "${_NB}" init

    diff                                    \
      <("${_NB}" notebooks current --name)  \
      <(printf "home\\n")

    [[ !  -f "${NB_DIR}/Example Notebook/.archived"         ]]
  }

  run "${_NB}" archive

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                     ]]
  [[ "${output}"  ==  "$(_color_primary "home") archived."  ]]

  [[    -f "${NB_DIR}/home/.archived"                       ]]

  # Creates git commit

  cd "${NB_DIR}/home" || return 1

  while [[ -n "$(git status --porcelain)"                   ]]
  do
    sleep 1
  done

  git log | grep -q '\[nb\] Archived'

  cd "${_TMP_DIR}"

  run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                         ]]

  [[ "${lines[0]}"  =~  ^[[:space:]][[:space:]]*\[1\ archived\]$  ]]
  [[ "${output}"    =~  0\ items\.                                ]]
}

@test "'archive' exits with 0 and archives the current notebook." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks use "Example Notebook"

    diff                                    \
      <("${_NB}" notebooks current --name)  \
      <(printf "Example Notebook\\n")

    [[ !  -f "${NB_DIR}/Example Notebook/.archived" ]]
  }

  run "${_NB}" archive

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                                 ]]
  [[ "${output}"  ==  "$(_color_primary "Example Notebook") archived."  ]]

  [[    -f "${NB_DIR}/Example Notebook/.archived"   ]]

  # Creates git commit

  cd "${NB_DIR}/Example Notebook" || return 1

  while [[ -n "$(git status --porcelain)"           ]]
  do
    sleep 1
  done

  git log | grep -q '\[nb\] Archived'

  cd "${_TMP_DIR}"

  run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                                         ]]

  [[ "${lines[0]}"  =~  ^[[:space:]][[:space:]]*.*home.*\ .*·.*\ \[1\ archived\]$ ]]
  [[ "${output}"    =~  0\ items\.                                                ]]
}

@test "'archive <name>' exits with 0 and archives notebook <name>." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    diff                                    \
      <("${_NB}" notebooks current --name)  \
      <(printf "home\\n")

    [[ !  -f "${NB_DIR}/Example Notebook/.archived" ]]
  }

  run "${_NB}" archive "Example Notebook"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                                 ]]
  [[ "${output}"  ==  "$(_color_primary "Example Notebook") archived."  ]]

  [[    -f "${NB_DIR}/Example Notebook/.archived"   ]]

  # Creates git commit

  cd "${NB_DIR}/Example Notebook" || return 1

  while [[ -n "$(git status --porcelain)"           ]]
  do
    sleep 1
  done

  git log | grep -q '\[nb\] Archived'

  cd "${_TMP_DIR}"

  run "${_NB}" ls

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0                                                         ]]

  [[ "${lines[0]}"  =~  ^[[:space:]][[:space:]]*.*home.*\ .*·.*\ \[1\ archived\]$ ]]
  [[ "${output}"    =~  0\ items\.                                                ]]
}

@test "'archive' does not create git commit if already archived." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" notebooks use "Example Notebook"

    diff                                    \
      <("${_NB}" notebooks current --name)  \
      <(printf "Example Notebook\\n")

    touch "${NB_DIR}/Example Notebook/.archived"

    [[    -f "${NB_DIR}/Example Notebook/.archived" ]]
  }

  run "${_NB}" archive

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                             ]]

  # NOTE: Spinner changes output in unexpected ways.
  [[ "${output}"  =~  Example\ Notebook             ]]
  [[ "${output}"  =~  archived\.$                   ]]

  [[    -f "${NB_DIR}/Example Notebook/.archived"   ]]

  # Does not create git commit

  cd "${NB_DIR}/Example Notebook" || return 1

  while [[ -n "$(git status --porcelain)"           ]]
  do
    sleep 1
  done

  ! git log | grep -q '\[nb\] Archived'
}

# `unarchive` #################################################################

@test "'unar' exits with 0 and unarchives the current notebook." {
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

  run "${_NB}" unar

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0                                                   ]]
  [[ "${output}"  ==  "$(_color_primary "Example Notebook") unarchived."  ]]

  [[ !  -f "${NB_DIR}/Example Notebook/.archived"   ]]

  # Creates git commit

  cd "${NB_DIR}/Example Notebook" || return 1

  while [[ -n "$(git status --porcelain)"           ]]
  do
    sleep 1
  done

  git log | grep '\[nb\] Unarchived'
}

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

  while [[ -n "$(git status --porcelain)"           ]]
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

  while [[ -n "$(git status --porcelain)"           ]]
  do
    sleep 1
  done

  git log | grep '\[nb\] Unarchived'
}

@test "'unarchive' does not create git commit if already archived." {
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

  while [[ -n "$(git status --porcelain)"           ]]
  do
    sleep 1
  done

  ! git log | grep -q '\[nb\] Unarchived'
}
