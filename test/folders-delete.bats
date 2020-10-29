#!/usr/bin/env bats

load test_helper

# error handling ##############################################################

@test "'delete folder/<filename>' with invalid filename returns with error and message." {
  {
    run "${_NB}" init
    run "${_NB}" add "Sample File.bookmark.md"                  \
      --content "<https://example.test>"

    run "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --content "<https://example.test>"

    [[   -e "${_NOTEBOOK_PATH}/Example Folder/Example File.bookmark.md"  ]]

  }

  run "${_NB}" delete "Example Folder/not-valid" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 1:

  [[ ${status} -eq 1 ]]

  # Does not delete file:

  [[   -e "${_NOTEBOOK_PATH}/Example Folder/Example File.bookmark.md"  ]]


  # Does not create git commit:

  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -v -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Not\ found:               ]]
  [[ "${output}" =~ Example\ Folder/not-valid ]]
}

# <filename> ##################################################################

@test "'delete folder/<filename>' deletes properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add "Sample File.bookmark.md"                  \
      --content "<https://example.test>"

    run "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --content "<https://example.test>"

    [[   -e "${_NOTEBOOK_PATH}/Example Folder/Example File.bookmark.md"  ]]

  }

  run "${_NB}" delete "Example Folder/Example File.bookmark.md" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Deletes file:

  [[ ! -e "${_NOTEBOOK_PATH}/Example Folder/Example File.bookmark.md"  ]]


  # Creates git commit:

  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Deleted:                                        ]]
  [[ "${output}" =~ Example\\\ Folder/1                             ]]
  [[ "${output}" =~ 🔖                                              ]]
  [[ "${output}" =~ Example\\\ Folder/Example\\\ File.bookmark.md   ]]
}

@test "'delete folder/folder/<filename>' deletes properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add "Sample File.bookmark.md"                                \
      --content "<https://example.test>"

    run "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --content "<https://example.test>"

    [[   -e "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/Example File.bookmark.md"  ]]
  }

  run "${_NB}" delete "Example Folder/Sample Folder/Example File.bookmark.md" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Deletes file:

  [[ ! -e "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/Example File.bookmark.md"  ]]


  # Creates git commit:

  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Deleted:                                                        ]]
  [[ "${output}" =~ Example\\\ Folder/Sample\\\ Folder/1                            ]]
  [[ "${output}" =~ 🔖                                                              ]]
  [[ "${output}" =~ Example\\\ Folder/Sample\\\ Folder/Example\\\ File.bookmark.md  ]]
}

@test "'delete notebook:folder/<filename>' deletes properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add "Sample File.bookmark.md"                  \
      --content "<https://example.test>"

    run "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --content "<https://example.test>"

    run "${_NB}" notebooks add "one"
    run "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    [[   -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md" ]]
  }

  run "${_NB}" delete "home:Example Folder/Example File.bookmark.md" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Deletes file:

  [[ ! -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Deleted:                                            ]]
  [[ "${output}" =~ home:Example\\\ Folder/1                            ]]
  [[ "${output}" =~ 🔖                                                  ]]
  [[ "${output}" =~ home:Example\\\ Folder/Example\\\ File.bookmark.md  ]]
}

@test "'delete notebook:folder/folder/<filename>' deletes properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add "Sample File.bookmark.md"                                \
      --content "<https://example.test>"

    run "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --content "<https://example.test>"

    run "${_NB}" notebooks add "one"
    run "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md" ]]
  }

  run "${_NB}" delete "home:Example Folder/Sample Folder/Example File.bookmark.md" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Deletes file:

  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Deleted:                                                            ]]
  [[ "${output}" =~ home:Example\\\ Folder/Sample\\\ Folder/1                           ]]
  [[ "${output}" =~ 🔖                                                                  ]]
  [[ "${output}" =~ home:Example\\\ Folder/Sample\\\ Folder/Example\\\ File.bookmark.md ]]
}

# <id> ########################################################################

@test "'delete folder/<id>' deletes properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add "Sample File.bookmark.md"                  \
      --content "<https://example.test>"

    run "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --content "<https://example.test>"

    [[   -e "${_NOTEBOOK_PATH}/Example Folder/Example File.bookmark.md" ]]
  }

  run "${_NB}" delete "Example Folder/1" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Deletes file:

  [[ ! -e "${_NOTEBOOK_PATH}/Example Folder/Example File.bookmark.md" ]]

  # Creates git commit:

  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Deleted:                                        ]]
  [[ "${output}" =~ Example\\\ Folder/1                             ]]
  [[ "${output}" =~ 🔖                                              ]]
  [[ "${output}" =~ Example\\\ Folder/Example\\\ File.bookmark.md   ]]
}

@test "'delete folder/folder/<id>' deletes properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add "Sample File.bookmark.md"                                \
      --content "<https://example.test>"

    run "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --content "<https://example.test>"

    [[   -e "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/Example File.bookmark.md" ]]
  }

  run "${_NB}" delete "Example Folder/Sample Folder/1" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Deletes file:

  [[ ! -e "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/Example File.bookmark.md" ]]

  # Creates git commit:

  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Deleted:                                                        ]]
  [[ "${output}" =~ Example\\\ Folder/Sample\\\ Folder/1                            ]]
  [[ "${output}" =~ 🔖                                                              ]]
  [[ "${output}" =~ Example\\\ Folder/Sample\\\ Folder/Example\\\ File.bookmark.md  ]]
}

@test "'delete notebook:folder/<id>' deletes properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add "Sample File.bookmark.md"                  \
      --content "<https://example.test>"

    run "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --content "<https://example.test>"

    run "${_NB}" notebooks add "one"
    run "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" delete "home:Example Folder/1" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Deletes file:

  [[ ! -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Deleted:                                            ]]
  [[ "${output}" =~ home:Example\\\ Folder/1                            ]]
  [[ "${output}" =~ 🔖                                                  ]]
  [[ "${output}" =~ home:Example\\\ Folder/Example\\\ File.bookmark.md  ]]
}

@test "'delete notebook:folder/folder/<id>' deletes properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add "Sample File.bookmark.md"                                \
      --content "<https://example.test>"

    run "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --content "<https://example.test>"

    run "${_NB}" notebooks add "one"
    run "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" delete "home:Example Folder/Sample Folder/1" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Deletes file:

  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Deleted:                                                            ]]
  [[ "${output}" =~ home:Example\\\ Folder/Sample\\\ Folder/1                           ]]
  [[ "${output}" =~ 🔖                                                                  ]]
  [[ "${output}" =~ home:Example\\\ Folder/Sample\\\ Folder/Example\\\ File.bookmark.md ]]
}

# <title> #####################################################################

@test "'delete folder/<title>' deletes properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add "Sample File.bookmark.md"                  \
      --title   "Sample Title"                                  \
      --content "<https://example.test>"

    run "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                 \
      --content "<https://example.test>"

    [[   -e "${_NOTEBOOK_PATH}/Example Folder/Example File.bookmark.md" ]]
  }

  run "${_NB}" delete "Example Folder/Example Title" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Deletes  file:

  [[ ! -e "${_NOTEBOOK_PATH}/Example Folder/Example File.bookmark.md" ]]

  # Creates git commit:

  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Deleted:                                        ]]
  [[ "${output}" =~ Example\\\ Folder/1                             ]]
  [[ "${output}" =~ 🔖                                              ]]
  [[ "${output}" =~ Example\\\ Folder/Example\\\ File.bookmark.md   ]]
}

@test "'delete folder/folder/<title>' deletes properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                                \
      --content "<https://example.test>"

    run "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                               \
      --content "<https://example.test>"

    [[   -e "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/Example File.bookmark.md" ]]
  }

  run "${_NB}" delete "Example Folder/Sample Folder/Example Title" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Deletes file:

  [[ ! -e "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/Example File.bookmark.md" ]]

  # Creates git commit:

  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Deleted:                                                        ]]
  [[ "${output}" =~ Example\\\ Folder/Sample\\\ Folder/1                            ]]
  [[ "${output}" =~ 🔖                                                              ]]
  [[ "${output}" =~ Example\\\ Folder/Sample\\\ Folder/Example\\\ File.bookmark.md  ]]
}

@test "'delete notebook:folder/<title>' deletes properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add "Sample File.bookmark.md"                  \
      --title   "Sample Title"                                  \
      --content "<https://example.test>"

    run "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                 \
      --content "<https://example.test>"

    run "${_NB}" notebooks add "one"
    run "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    [[   -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md" ]]
  }

  run "${_NB}" delete "home:Example Folder/Example Title" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Deletes file:

  [[ ! -e "${NB_DIR}/home/Example Folder/Example File.bookmark.md" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Deleted:                                            ]]
  [[ "${output}" =~ home:Example\\\ Folder/1                            ]]
  [[ "${output}" =~ 🔖                                                  ]]
  [[ "${output}" =~ home:Example\\\ Folder/Example\\\ File.bookmark.md  ]]
}

@test "'delete notebook:folder/folder/<title>' deletes properly without errors." {
  {
    run "${_NB}" init
    run "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                                \
      --content "<https://example.test>"

    run "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                               \
      --content "<https://example.test>"

    run "${_NB}" notebooks add "one"
    run "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]

    [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md" ]]
  }

  run "${_NB}" delete "home:Example Folder/Sample Folder/Example Title" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Deletes file:

  [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md" ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Prints output:

  [[ "${output}" =~ Deleted:                                                            ]]
  [[ "${output}" =~ home:Example\\\ Folder/Sample\\\ Folder/1                           ]]
  [[ "${output}" =~ 🔖                                                                  ]]
  [[ "${output}" =~ home:Example\\\ Folder/Sample\\\ Folder/Example\\\ File.bookmark.md ]]
}
