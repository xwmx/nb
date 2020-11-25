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
  [[ ${status} -eq 0 ]]

  # Creates new note with bookmark filename
  [[ "${_filename}}" =~ [A-Za-z0-9]+.bookmark.md ]]

  # Creates new note file with content
  [[ "${#_files[@]}" -eq 1 ]]

  _bookmark_content="\
# Example Domain

<file://${NB_TEST_BASE_PATH}/fixtures/example.com.html>

## Description

Example description.

## Content

$(cat "${NB_TEST_BASE_PATH}/fixtures/example.com.md")"

  printf "cat file: '%s'\\n" "$(cat "${NB_DIR}/home/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"

  [[ "$(cat "${NB_DIR}/home/${_filename}")" == "${_bookmark_content}" ]]
  grep -q '# Example Domain' "${NB_DIR}/home"/*

  # Creates git commit
  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index
  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]

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
  [[ ${status} -eq 0 ]]

  # Creates new note with bookmark filename
  [[ "${_filename}}" =~ [A-Za-z0-9]+.bookmark.md ]]

  # Creates new note file with content
  [[ "${#_files[@]}" -eq 1 ]]

  _bookmark_content="\
# Example OG Title

<file://${NB_TEST_BASE_PATH}/fixtures/example.com-og.html>

## Description

Example OG description.

## Content

$(cat "${NB_TEST_BASE_PATH}/fixtures/example.com.md")"

  printf "cat file: '%s'\\n" "$(cat "${NB_DIR}/home/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"

  [[ "$(cat "${NB_DIR}/home/${_filename}")" == "${_bookmark_content}" ]]
  grep -q '# Example OG Title' "${NB_DIR}/home"/*

  # Creates git commit
  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index
  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]

  # Prints output
  [[ "${output}" =~ Added:                    ]]
  [[ "${output}" =~ [0-9]+                    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.bookmark.md  ]]
}
