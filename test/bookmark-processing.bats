#!/usr/bin/env bats

load test_helper

@test "'bookmark' extracts title and meta description tag content." {
  {
    "${_NB}" init
  }

  run "${_NB}" bookmark "${_BOOKMARK_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"

  # Returns status 0

  [[ "${status}"    -eq   0                         ]]

  # Creates new note with bookmark filename

  [[ "${_filename}" =~    [A-Za-z0-9]+.bookmark.md  ]]

  # Creates new note file with content

  [[ "${#_files[@]}" -eq  1                         ]]

  diff                                              \
    <(cat "${NB_DIR}/home/${_filename}")            \
    <(cat <<HEREDOC
# Example Domain

<file://${NB_TEST_BASE_PATH}/fixtures/example.com.html>

## Description

Example description.

## Content

$(cat "${NB_TEST_BASE_PATH}/fixtures/example.com.md")
HEREDOC
    )

  # Creates git commit

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Add'

  # Adds to index

  [[ -e "${NB_DIR}/home/.index"               ]]

  diff                                        \
    <(ls "${NB_DIR}/home")                    \
    <(cat "${NB_DIR}/home/.index")

  # Prints output

  [[ "${output}" =~ Added:                    ]]
  [[ "${output}" =~ [0-9]+                    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.bookmark.md  ]]
}

@test "'bookmark' extracts open graph title and description tag content." {
  {
    "${_NB}" init
  }

  run "${_NB}" bookmark "${_OG_BOOKMARK_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"

  # Returns status 0
  #
  [[ "${status}"    -eq   0                         ]]

  # Creates new note with bookmark filename

  [[ "${_filename}" =~    [A-Za-z0-9]+.bookmark.md  ]]

  # Creates new note file with content

  [[ "${#_files[@]}" -eq  1                         ]]

  diff                                              \
    <(cat "${NB_DIR}/home/${_filename}")            \
    <(cat <<HEREDOC
# Example OG Title

<file://${NB_TEST_BASE_PATH}/fixtures/example.com-og.html>

## Description

Example OG description.

## Content

$(cat "${NB_TEST_BASE_PATH}/fixtures/example.com.md")
HEREDOC
    )

  # Creates git commit

  while [[ -n "$(git -C "${NB_DIR}/home" status --porcelain)" ]]
  do
    sleep 1
  done
  git -C "${NB_DIR}/home" log | grep -q '\[nb\] Add'

  # Adds to index

  [[ -e "${NB_DIR}/home/.index"               ]]

  diff                                        \
    <(ls "${NB_DIR}/home")                    \
    <(cat "${NB_DIR}/home/.index")

  # Prints output

  [[ "${output}" =~ Added:                    ]]
  [[ "${output}" =~ [0-9]+                    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.bookmark.md  ]]
}
