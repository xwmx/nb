#!/usr/bin/env bats

load test_helper

export _BOOKMARK_URL="file://${BATS_TEST_DIRNAME}/fixtures/example.com.html"
export _OG_BOOKMARK_URL="file://${BATS_TEST_DIRNAME}/fixtures/example.com-og.html"

@test "\`bookmark\` extracts title and meta description tag content." {
  {
    run "${_NB}" init
  }

  run "${_NB}" bookmark "${_BOOKMARK_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note with bookmark filename
  [[ "${_filename}}" =~ [A-Za-z0-9]+.bookmark.md ]]

  # Creates new note file with content
  [[ "${#_files[@]}" -eq 1 ]]

  _bookmark_content="\
# Example Domain

<file://${BATS_TEST_DIRNAME}/fixtures/example.com.html>

## Description

Example description.

## Content

$(cat "${BATS_TEST_DIRNAME}/fixtures/example.com.md")"

  printf "cat file: '%s'\\n" "$(cat "${_NOTEBOOK_PATH}/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"

  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" == "${_bookmark_content}" ]]
  grep -q '# Example Domain' "${_NOTEBOOK_PATH}"/*

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index
  [[ -e "${_NOTEBOOK_PATH}/.index"                                      ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Added:                    ]]
  [[ "${output}" =~ [0-9]+                    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.bookmark.md  ]]
}

@test "\`bookmark\` extracts open graph title and description tag content." {
  {
    run "${_NB}" init
  }

  run "${_NB}" bookmark "${_OG_BOOKMARK_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note with bookmark filename
  [[ "${_filename}}" =~ [A-Za-z0-9]+.bookmark.md ]]

  # Creates new note file with content
  [[ "${#_files[@]}" -eq 1 ]]

  _bookmark_content="\
# Example OG Title

<file://${BATS_TEST_DIRNAME}/fixtures/example.com-og.html>

## Description

Example OG description.

## Content

$(cat "${BATS_TEST_DIRNAME}/fixtures/example.com.md")"

  printf "cat file: '%s'\\n" "$(cat "${_NOTEBOOK_PATH}/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"

  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" == "${_bookmark_content}" ]]
  grep -q '# Example OG Title' "${_NOTEBOOK_PATH}"/*

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index
  [[ -e "${_NOTEBOOK_PATH}/.index"                                      ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Added:                    ]]
  [[ "${output}" =~ [0-9]+                    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.bookmark.md  ]]
}
