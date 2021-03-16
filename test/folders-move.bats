#!/usr/bin/env bats

load test_helper

# intermediate folders ########################################################

@test "'move notebook:folder/<id>' moves across notebooks and creates intermediate folders." {
  {
    "${_NB}" init
    "${_NB}" add "Test Folder/Sample File.bookmark.md"  \
      --title   "Sample Title"                          \
      --content "<https://1.example.test>"

    "${_NB}" notebooks add "one"

    [[   -d "${NB_DIR}/home/Test Folder"                                              ]]
    [[   -f "${NB_DIR}/home/Test Folder/Sample File.bookmark.md"                      ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder"                             ]]
    [[ ! -e "${NB_DIR}/one/Example Folder"                                            ]]
    [[ ! -e "${NB_DIR}/one/Example Folder/Sample Folder"                              ]]
    [[ ! -e "${NB_DIR}/one/Example Folder/Sample Folder/Demo Folder"                  ]]
    [[ ! -e "${NB_DIR}/one/Example Folder/Sample Folder/Demo Folder/Example File.md"  ]]
  }

  run "${_NB}" move                                                 \
    "Test Folder/1"                                                 \
    "one:Example Folder/Sample Folder/Demo Folder/Example File.md"  \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[   -d "${NB_DIR}/home/Test Folder"                                              ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample File.bookmark.md"                   ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder"                             ]]
  [[   -d "${NB_DIR}/one/Example Folder"                                            ]]
  [[   -d "${NB_DIR}/one/Example Folder/Sample Folder"                              ]]
  [[   -d "${NB_DIR}/one/Example Folder/Sample Folder/Demo Folder"                  ]]
  [[   -f "${NB_DIR}/one/Example Folder/Sample Folder/Demo Folder/Example File.md"  ]]

  # Creates git commits:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete:'

  cd "${NB_DIR}/one" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                                                        ]]
  [[ "${output}" =~ one:Example\ Folder/Sample\ Folder/Demo\ Folder/1                 ]]
  [[ "${output}" =~ one:Example\ Folder/Sample\ Folder/Demo\ Folder/Example\ File.md  ]]
}

@test "'move folder/<id>' moves and creates intermediate folders." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder/Sample File.bookmark.md"   \
      --title   "Sample Title"                              \
      --content "<https://1.example.test>"


    [[   -d "${NB_DIR}/home/Example Folder"                                           ]]
    [[   -f "${NB_DIR}/home/Example Folder/Sample File.bookmark.md"                   ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder"                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder"                 ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/Example File.md" ]]
  }

  run "${_NB}" move                                             \
    "Example Folder/1"                                          \
    "Example Folder/Sample Folder/Demo Folder/Example File.md"  \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[   -d "${NB_DIR}/home/Example Folder"                                           ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample File.bookmark.md"                   ]]
  [[   -d "${NB_DIR}/home/Example Folder/Sample Folder"                             ]]
  [[   -d "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder"                 ]]
  [[   -f "${NB_DIR}/home/Example Folder/Sample Folder/Demo Folder/Example File.md" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                                                    ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/Demo\ Folder/1                 ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/Demo\ Folder/Example\ File.md  ]]
}

# error handling ##############################################################

@test "'move folder/<filename>' with invalid filename returns with error and message." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --title   "Sample Title"                              \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --title   "Example Title"                             \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
    [[   -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                ]]
  }

  run "${_NB}" move             \
    "Example Folder/not-valid"  \
    "Example Folder/example.md" \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 1:

  [[ ${status} -eq 1 ]]

  # Does not move file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
  [[   -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                               ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                ]]

  # Does not create git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -v -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Not\ found:               ]]
  [[ "${output}" =~ Example\ Folder/not-valid ]]
}

# into folder/ ################################################################

@test "'move <notebook>:<selector> <notebook>:folder/' with existing folder moves item into folder." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"  \
      --title   "Sample Title"              \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder" --type folder

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                ]]
    [[   -d "${NB_DIR}/home/Example Folder"                         ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample File.bookmark.md" ]]
  }

  run "${_NB}" move           \
    "Sample File.bookmark.md" \
    "Example Folder/"         \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${NB_DIR}/home/Sample File.bookmark.md"                ]]
  [[   -d "${NB_DIR}/home/Example Folder"                         ]]
  [[   -e "${NB_DIR}/home/Example Folder/Sample File.bookmark.md" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                                ]]
  [[ "${output}" =~ Example\ Folder/1                         ]]
  [[ "${output}" =~ Example\ Folder/Sample\ File.bookmark.md  ]]
}

@test "'move <selector> folder/' creates folder and moves item into folder." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"  \
      --title   "Sample Title"              \
      --content "<https://1.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                ]]
    [[ ! -d "${NB_DIR}/home/Example Folder"                         ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample File.bookmark.md" ]]
  }

  run "${_NB}" move           \
    "Sample File.bookmark.md" \
    "Example Folder/"         \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${NB_DIR}/home/Sample File.bookmark.md"                ]]
  [[   -d "${NB_DIR}/home/Example Folder"                         ]]
  [[   -e "${NB_DIR}/home/Example Folder/Sample File.bookmark.md" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                                ]]
  [[ "${output}" =~ Example\ Folder/1                         ]]
  [[ "${output}" =~ Example\ Folder/Sample\ File.bookmark.md  ]]
}

@test "'move <notebook>:<selector> <notebook>:folder/' moves item into folder." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"  \
      --title   "Sample Title"              \
      --content "<https://1.example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    "${_NB}" notebooks add "two"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                ]]
    [[ ! -d "${NB_DIR}/home/Example Folder"                         ]]
    [[ ! -d "${NB_DIR}/two/Example Folder"                          ]]
    [[ ! -e "${NB_DIR}/two/Example Folder/Sample File.bookmark.md"  ]]
  }

  run "${_NB}" move                 \
    "home:Sample File.bookmark.md"  \
    "two:Example Folder/"           \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[ ! -e "${NB_DIR}/home/Sample File.bookmark.md"                ]]
  [[ ! -d "${NB_DIR}/home/Example Folder"                         ]]
  [[   -d "${NB_DIR}/two/Example Folder"                          ]]
  [[   -e "${NB_DIR}/two/Example Folder/Sample File.bookmark.md"  ]]

  # Creates git commits:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete:'

  cd "${NB_DIR}/two" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                                    ]]
  [[ "${output}" =~ two:Example\ Folder/1                         ]]
  [[ "${output}" =~ two:Example\ Folder/Sample\ File.bookmark.md  ]]
}

# <filename> ##################################################################

@test "'move notebook:folder/folder/<filename>' moves across notebooks and levels without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
    [[ ! -e "${NB_DIR}/one/example.md"                                              ]]
    [[ ! -e "${NB_DIR}/one/Example Folder/example.md"                               ]]
    [[ ! -e "${NB_DIR}/two/example.md"                                              ]]
    [[ ! -e "${NB_DIR}/two/Example Folder"                                          ]]
    [[ ! -e "${NB_DIR}/two/Example Folder/example.md"                               ]]

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks add "two"

    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" move                                               \
    "home:Example Folder/Sample Folder/Example File.bookmark.md"  \
    "two:Example Folder/example.md"                               \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates git commits:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete:'

  cd "${NB_DIR}/two" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add:'

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
  [[ ! -e "${NB_DIR}/one/example.md"                                              ]]
  [[ ! -e "${NB_DIR}/one/Example Folder/example.md"                               ]]
  [[ ! -e "${NB_DIR}/two/example.md"                                              ]]
  [[   -e "${NB_DIR}/two/Example Folder/example.md"                               ]]
  [[   -e "${NB_DIR}/two/Example Folder/.index"                                   ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to:                      ]]
  [[ "${output}" =~ two:Example\ Folder/1           ]]
  [[ "${output}" =~ two:Example\ Folder/example.md  ]]
}

@test "'move folder/<filename>' moves properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --title   "Sample Title"                              \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --title   "Example Title"                             \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
    [[   -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                ]]
  }

  run "${_NB}" move                           \
    "Example Folder/Example File.bookmark.md" \
    "Example Folder/example.md"               \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                               ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"                ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                  ]]
  [[ "${output}" =~ Example\ Folder/1           ]]
  [[ "${output}" =~ Example\ Folder/example.md  ]]
}

@test "'move folder/folder/<filename>' moves properly on same level without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"                ]]
  }

  run "${_NB}" move                                         \
    "Example Folder/Sample Folder/Example File.bookmark.md" \
    "Example Folder/Sample Folder/example.md"               \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"                ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to:                                                ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/1                          ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/example.md                 ]]
}

@test "'move folder/folder/<filename>' moves properly up one level without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
  }

  run "${_NB}" move                                         \
    "Example Folder/Sample Folder/Example File.bookmark.md" \
    "Example Folder/example.md"                             \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"                              ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to:                  ]]
  [[ "${output}" =~ Example\ Folder/2           ]]
  [[ "${output}" =~ Example\ Folder/example.md  ]]
}

@test "'move notebook:folder/<filename>' moves properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --title   "Sample Title"                              \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --title   "Example Title"                             \
      --content "<https://2.example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
    [[   -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                ]]
  }

  run "${_NB}" move                                 \
    "home:Example Folder/Example File.bookmark.md"  \
    "home:Example Folder/example.md"                \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                               ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"                ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                      ]]
  [[ "${output}" =~ home:Example\ Folder/1          ]]
  [[ "${output}" =~ home:Example\ Folder/example.md ]]
}

@test "'move notebook:folder/folder/<filename>' moves properly on same level without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"                ]]
  }

  run "${_NB}" move                                               \
    "home:Example Folder/Sample Folder/Example File.bookmark.md"  \
    "home:Example Folder/Sample Folder/example.md"                \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
  [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"                ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                                      ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/1           ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/example.md  ]]
}

@test "'move notebook:folder/folder/<filename>' moves properly up one level without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" move                                               \
    "home:Example Folder/Sample Folder/Example File.bookmark.md"  \
    "home:Example Folder/example.md"                              \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"                              ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to:                      ]]
  [[ "${output}" =~ home:Example\ Folder/2          ]]
  [[ "${output}" =~ home:Example\ Folder/example.md ]]
}

# <id> ########################################################################

@test "'move notebook:folder/folder/<id>' moves across notebooks and levels without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
    [[ ! -e "${NB_DIR}/one/example.md"                                              ]]
    [[ ! -e "${NB_DIR}/one/Example Folder/example.md"                               ]]
    [[ ! -e "${NB_DIR}/two/example.md"                                              ]]
    [[ ! -e "${NB_DIR}/two/Example Folder/example.md"                               ]]

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks add "two"

    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" move                       \
    "home:Example Folder/Sample Folder/1" \
    "two:Example Folder/example.md"       \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates git commits:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete:'

  cd "${NB_DIR}/two" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add:'

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
  [[ ! -e "${NB_DIR}/one/example.md"                                              ]]
  [[ ! -e "${NB_DIR}/one/Example Folder/example.md"                               ]]
  [[ ! -e "${NB_DIR}/two/example.md"                                              ]]
  [[   -e "${NB_DIR}/two/Example Folder/example.md"                               ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to:                      ]]
  [[ "${output}" =~ two:Example\ Folder/1           ]]
  [[ "${output}" =~ two:Example\ Folder/example.md  ]]
}

@test "'move folder/<id>' moves properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --title   "Sample Title"                              \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --title   "Example Title"                             \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
    [[   -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                ]]
  }

  run "${_NB}" move             \
    "Example Folder/1"          \
    "Example Folder/example.md" \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                               ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"                ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                  ]]
  [[ "${output}" =~ Example\ Folder/1           ]]
  [[ "${output}" =~ Example\ Folder/example.md  ]]
}

@test "'move folder/folder/<id>' moves properly on same level without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"                ]]
  }

  run "${_NB}" move                           \
    "Example Folder/Sample Folder/1"          \
    "Example Folder/Sample Folder/example.md" \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"                ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to:                                                ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/1                          ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/example.md                 ]]
}

@test "'move folder/folder/<id>' moves properly up one level without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
  }

  run "${_NB}" move                   \
    "Example Folder/Sample Folder/1"  \
    "Example Folder/example.md"       \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"                              ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to:                  ]]
  [[ "${output}" =~ Example\ Folder/2           ]]
  [[ "${output}" =~ Example\ Folder/example.md  ]]
}

@test "'move notebook:folder/<id>' moves properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --title   "Sample Title"                              \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --title   "Example Title"                             \
      --content "<https://2.example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
    [[   -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                ]]
  }

  run "${_NB}" move                   \
    "home:Example Folder/1"           \
    "home:Example Folder/example.md"  \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                               ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"                ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                      ]]
  [[ "${output}" =~ home:Example\ Folder/1          ]]
  [[ "${output}" =~ home:Example\ Folder/example.md ]]
}

@test "'move notebook:folder/folder/<id>' moves properly on same level without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"                ]]
  }

  run "${_NB}" move                                 \
    "home:Example Folder/Sample Folder/1"           \
    "home:Example Folder/Sample Folder/example.md"  \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
  [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"                ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                                      ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/1           ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/example.md  ]]
}

@test "'move notebook:folder/folder/<id>' moves properly up one level without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" move                       \
    "home:Example Folder/Sample Folder/1" \
    "home:Example Folder/example.md"      \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"                              ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to:                      ]]
  [[ "${output}" =~ home:Example\ Folder/2          ]]
  [[ "${output}" =~ home:Example\ Folder/example.md ]]
}

# <title> #####################################################################

@test "'move notebook:folder/folder/<title>' moves across notebooks and levels without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
    [[ ! -e "${NB_DIR}/one/example.md"                                              ]]
    [[ ! -e "${NB_DIR}/one/Example Folder/example.md"                               ]]
    [[ ! -e "${NB_DIR}/two/example.md"                                              ]]
    [[ ! -e "${NB_DIR}/two/Example Folder/example.md"                               ]]

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks add "two"

    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" move                                   \
    "home:Example Folder/Sample Folder/Example Title" \
    "two:Example Folder/example.md"                   \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates git commits:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete:'

  cd "${NB_DIR}/two" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add:'

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
  [[ ! -e "${NB_DIR}/one/example.md"                                              ]]
  [[ ! -e "${NB_DIR}/one/Example Folder/example.md"                               ]]
  [[ ! -e "${NB_DIR}/two/example.md"                                              ]]
  [[   -e "${NB_DIR}/two/Example Folder/example.md"                               ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to:                  ]]
  [[ "${output}" =~ Example\ Folder/1           ]]
  [[ "${output}" =~ Example\ Folder/example.md  ]]
}

@test "'move folder/<title>' moves properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --title   "Sample Title"                              \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --title   "Example Title"                             \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
    [[   -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                ]]
  }

  run "${_NB}" move                 \
    "Example Folder/Example Title"  \
    "Example Folder/example.md"     \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                               ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"                ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                  ]]
  [[ "${output}" =~ Example\ Folder/1           ]]
  [[ "${output}" =~ Example\ Folder/example.md  ]]
}

@test "'move folder/folder/<title>' moves properly on same level without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"                ]]
  }

  run "${_NB}" move                               \
    "Example Folder/Sample Folder/Example Title"  \
    "Example Folder/Sample Folder/example.md"     \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"                ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to:                                                ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/1                          ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/example.md                 ]]
}

@test "'move folder/folder/<title>' moves properly up one level without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
  }

  run "${_NB}" move                               \
    "Example Folder/Sample Folder/Example Title"  \
    "Example Folder/example.md"                   \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"                              ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to:                  ]]
  [[ "${output}" =~ Example\ Folder/2           ]]
  [[ "${output}" =~ Example\ Folder/example.md  ]]
}

@test "'move notebook:folder/<title>' moves properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --title   "Sample Title"                              \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --title   "Example Title"                             \
      --content "<https://2.example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
    [[   -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                ]]
  }

  run "${_NB}" move                     \
    "home:Example Folder/Example Title" \
    "home:Example Folder/example.md"    \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                  ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                               ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"                ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                      ]]
  [[ "${output}" =~ home:Example\ Folder/1          ]]
  [[ "${output}" =~ home:Example\ Folder/example.md ]]
}

@test "'move notebook:folder/folder/<title>' moves properly on same level without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"                ]]
  }

  run "${_NB}" move                                   \
    "home:Example Folder/Sample Folder/Example Title" \
    "home:Example Folder/Sample Folder/example.md"    \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]
  [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/example.md"                ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Prints output:

  [[ "${output}" =~ Moved\ to:                                      ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/1           ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/example.md  ]]
}

@test "'move notebook:folder/folder/<title>' moves properly up one level without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://1.example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://2.example.test>"

    [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
    [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/example.md"                              ]]

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" move                                   \
    "home:Example Folder/Sample Folder/Example Title" \
    "home:Example Folder/example.md"                  \
    --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Move:'

  # Moves file:

  [[   -e "${NB_DIR}/home/Sample File.bookmark.md"                                ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  [[ ! -e "${NB_DIR}/home/example.md"                                             ]]
  [[   -e "${NB_DIR}/home/Example Folder/example.md"                              ]]

  # Prints output:

  [[ "${output}" =~ Moved\ to:                      ]]
  [[ "${output}" =~ home:Example\ Folder/2          ]]
  [[ "${output}" =~ home:Example\ Folder/example.md ]]
}
