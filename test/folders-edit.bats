#!/usr/bin/env bats

load test_helper

# <filename> ##################################################################

@test "'edit folder/<filename>' with encrypted file edits properly without errors." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --content "<https://example.test>"                    \
      --encrypt                                             \
      --password password

    declare _relative_path="Example Folder/Example File.bookmark.md.enc"

    declare _original_hash=
    _original_hash="$(
      _get_hash "${NB_DIR}/home/${_relative_path}"
    )"
  }

  run "${_NB}" edit "${_relative_path}" --password password

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates file:

  [[ "$(_get_hash "${NB_DIR}/home/${_relative_path}")" != "${_original_hash}" ]]


  [[  "$(
        "${_NB}" show "${_relative_path}" \
          --print                         \
          --no-color                      \
          --password password
      )" =~ mock_editor ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:                                      ]]
  [[ "${output}" =~ Example\ Folder/1                             ]]
  [[ "${output}" =~ 🔖\ 🔒                                        ]]
  [[ "${output}" =~ Example\ Folder/Example\ File.bookmark.md.enc ]]
}

# error handling ##############################################################


@test "'edit folder/<filename>' with invalid filename returns with error and message." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --content "<https://example.test>"
  }

  run "${_NB}" edit "Example Folder/not-valid" --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 1:

  [[ ${status} -eq 1 ]]

  # Does not update file:

  [[ ! "$(cat "${NB_DIR}/home/Example Folder/Example File.bookmark.md")" =~ mock_editor ]]

  # Does not create git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)"   ]]
  do
    sleep 1
  done
  git log | grep -v -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Not\ found:               ]]
  [[ "${output}" =~ Example\ Folder/not-valid ]]
}

# <filename> ##################################################################

@test "'edit folder/<filename>' edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --content "<https://example.test>"
  }

  run "${_NB}" edit "Example Folder/Example File.bookmark.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates file:

  [[ "$(cat "${NB_DIR}/home/Example Folder/Example File.bookmark.md")" =~ mock_editor ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:                                    ]]
  [[ "${output}" =~ Example\ Folder/1                           ]]
  [[ "${output}" =~ 🔖                                          ]]
  [[ "${output}" =~ Example\ Folder/Example\ File.bookmark.md   ]]
}

@test "'edit folder/folder/<filename>' edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --content "<https://example.test>"
  }

  run "${_NB}" edit "Example Folder/Sample Folder/Example File.bookmark.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates file:

  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md")" =~ mock_editor ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:                                                  ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/1                          ]]
  [[ "${output}" =~ 🔖                                                        ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/Example\ File.bookmark.md  ]]
}

@test "'edit notebook:folder/<filename>' edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --content "<https://example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" edit "home:Example Folder/Example File.bookmark.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates file:

  [[ "$(cat "${NB_DIR}/home/Example Folder/Example File.bookmark.md")" =~ mock_editor ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:                                        ]]
  [[ "${output}" =~ home:Example\ Folder/1                          ]]
  [[ "${output}" =~ 🔖                                              ]]
  [[ "${output}" =~ home:Example\ Folder/Example\ File.bookmark.md  ]]
}

@test "'edit notebook:folder/folder/<filename>' edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --content "<https://example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" edit "home:Example Folder/Sample Folder/Example File.bookmark.md"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates file:

  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md")" =~ mock_editor ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:                                                      ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/1                         ]]
  [[ "${output}" =~ 🔖                                                            ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/Example\ File.bookmark.md ]]
}

# <id> ########################################################################

@test "'edit folder/<id>' edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --content "<https://example.test>"
  }

  run "${_NB}" edit "Example Folder/1"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates file:

  [[ "$(cat "${NB_DIR}/home/Example Folder/Example File.bookmark.md")" =~ mock_editor ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:                                    ]]
  [[ "${output}" =~ Example\ Folder/1                           ]]
  [[ "${output}" =~ 🔖                                          ]]
  [[ "${output}" =~ Example\ Folder/Example\ File.bookmark.md   ]]
}

@test "'edit folder/folder/<id>' edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --content "<https://example.test>"
  }

  run "${_NB}" edit "Example Folder/Sample Folder/1"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates file:

  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md")" =~ mock_editor ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:                                                  ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/1                          ]]
  [[ "${output}" =~ 🔖                                                        ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/Example\ File.bookmark.md  ]]
}

@test "'edit notebook:folder/<id>' edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --content "<https://example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" edit "home:Example Folder/1"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates file:

  [[ "$(cat "${NB_DIR}/home/Example Folder/Example File.bookmark.md")" =~ mock_editor ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:                                        ]]
  [[ "${output}" =~ home:Example\ Folder/1                          ]]
  [[ "${output}" =~ 🔖                                              ]]
  [[ "${output}" =~ home:Example\ Folder/Example\ File.bookmark.md  ]]
}

@test "'edit notebook:folder/folder/<id>' edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --content "<https://example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" edit "home:Example Folder/Sample Folder/1"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates file:

  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md")" =~ mock_editor ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:                                                      ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/1                         ]]
  [[ "${output}" =~ 🔖                                                            ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/Example\ File.bookmark.md ]]
}

# <title> #####################################################################

@test "'edit folder/<title>' edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --title   "Sample Title"                              \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --title   "Example Title"                             \
      --content "<https://example.test>"
  }

  run "${_NB}" edit "Example Folder/Example Title"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates file:

  [[ "$(cat "${NB_DIR}/home/Example Folder/Example File.bookmark.md")" =~ mock_editor ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:                                    ]]
  [[ "${output}" =~ Example\ Folder/1                           ]]
  [[ "${output}" =~ 🔖                                          ]]
  [[ "${output}" =~ Example\ Folder/Example\ File.bookmark.md   ]]
}

@test "'edit folder/folder/<title>' edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://example.test>"
  }

  run "${_NB}" edit "Example Folder/Sample Folder/Example Title"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates file:

  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md")" =~ mock_editor ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:                                                  ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/1                          ]]
  [[ "${output}" =~ 🔖                                                        ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/Example\ File.bookmark.md  ]]
}

@test "'edit notebook:folder/<title>' edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                  \
      --title   "Sample Title"                              \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Example File.bookmark.md"  \
      --title   "Example Title"                             \
      --content "<https://example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" edit "home:Example Folder/Example Title"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates file:

  [[ "$(cat "${NB_DIR}/home/Example Folder/Example File.bookmark.md")" =~ mock_editor ]]

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:                                        ]]
  [[ "${output}" =~ home:Example\ Folder/1                          ]]
  [[ "${output}" =~ 🔖                                              ]]
  [[ "${output}" =~ home:Example\ Folder/Example\ File.bookmark.md  ]]
}

@test "'edit notebook:folder/folder/<title>' edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" add "Sample File.bookmark.md"                                \
      --title   "Sample Title"                                            \
      --content "<https://example.test>"

    "${_NB}" add "Example Folder/Sample Folder/Example File.bookmark.md"  \
      --title   "Example Title"                                           \
      --content "<https://example.test>"

    "${_NB}" notebooks add "one"
    "${_NB}" notebooks use "one"

    [[ "$("${_NB}" notebooks current)" == "one" ]]
  }

  run "${_NB}" edit "home:Example Folder/Sample Folder/Example Title"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0 ]]

  # Updates file:

  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/Example File.bookmark.md")" =~ mock_editor ]]

  # Creates git commit
  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output:

  [[ "${output}" =~ Updated:                                                      ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/1                         ]]
  [[ "${output}" =~ 🔖                                                            ]]
  [[ "${output}" =~ home:Example\ Folder/Sample\ Folder/Example\ File.bookmark.md ]]
}
