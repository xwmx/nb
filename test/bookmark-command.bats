#!/usr/bin/env bats

load test_helper

# no argument #################################################################

@test "\`bookmark\` with no argument exits with 0, prints message, and lists." {
  {
    run "${_NOTES}" init
  }

  run "${_BOOKMARK}"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0
  [[ ${status} -eq 0 ]]

  # Does not create note file
  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 0 ]]

  # Does not create git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ ! $(git log | grep '\[NOTES\] Add') ]]

  # Prints help information
  [[ "${lines[0]}" =~ Add\ a\ bookmark ]]
}

# <url> argument ##############################################################

@test "\`bookmark\` with invalid <url> argument exits with 1." {
  {
    run "${_NOTES}" init
  }

  run "${_BOOKMARK}" 'invalid url'
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 1
  [[ ${status} -eq 1 ]]

  # Does not create note file
  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 0 ]]

  # Does not create git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ ! $(git log | grep '\[NOTES\] Add') ]]

  # Prints help information
  [[ "${lines[0]}" == "Unable to download page at 'invalid url'" ]]
}

@test "\`bookmark\` with valid <url> argument creates new note without errors." {
  {
    run "${_NOTES}" init
  }

  run "${_BOOKMARK}" "${_BOOKMARK_URL}"
  printf "\${status}: %s\\n" "${status}"
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

## Content

Example Domain
==============

This domain is for use in illustrative examples in documents. You may use this domain in literature without prior coordination or asking for permission.

[More information\...](https://www.iana.org/domains/example)"
  printf "cat file: '%s'\\n" "$(cat "${_NOTEBOOK_PATH}/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" == "${_bookmark_content}" ]]
  [[ $(grep '# Example Domain' "${_NOTEBOOK_PATH}"/*) ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Add') ]]

  # Adds to index
  [[ -e "${_NOTEBOOK_PATH}/.index" ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Added\ \[[0-9]+\]\ [A-Za-z0-9]+.bookmark.md ]]
}
