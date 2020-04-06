#!/usr/bin/env bats

load test_helper

_BOOKMARK_URL="file://${BATS_TEST_DIRNAME}/fixtures/example.net.html"

# no argument #################################################################

@test "\`bookmark\` with no argument exits with 1." {
  {
    run "${_NOTES}" init
  }

  run "${_NOTES}" bookmark
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 1
  [[ ${status} -eq 1 ]]

  # Does not create note file
  _files=($(ls "${NOTES_DATA_DIR}/"))
  [[ "${#_files[@]}" -eq 0 ]]

  # Does not create git commit
  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ ! $(git log | grep '\[NOTES\] Add') ]]

  # Prints help information
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" =~ notes\ bookmark ]]
}

# <url> argument ##############################################################

@test "\`bookmark\` with invalid <url> argument exits with 1." {
  {
    run "${_NOTES}" init
  }

  run "${_NOTES}" bookmark 'invalid url'
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 1
  [[ ${status} -eq 1 ]]

  # Does not create note file
  _files=($(ls "${NOTES_DATA_DIR}/"))
  [[ "${#_files[@]}" -eq 0 ]]

  # Does not create git commit
  cd "${NOTES_DATA_DIR}" || return 1
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

  run "${_NOTES}" bookmark "${_BOOKMARK_URL}"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note with bookmark filename
  [[ "${_filename}}" =~ [A-Za-z0-9]+-bookmark.md ]]

  # Creates new note file with content
  [[ "${#_files[@]}" -eq 1 ]]
  _bookmark_content="\
# Example Domain

<file://${BATS_TEST_DIRNAME}/fixtures/example.net.html>

## Description

Example description."
  printf "cat file: '%s'\\n" "$(cat "${NOTES_DATA_DIR}/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"
  [[ "$(cat "${NOTES_DATA_DIR}/${_filename}")" == "${_bookmark_content}" ]]
  [[ $(grep '# Example Domain' "${NOTES_DATA_DIR}"/*) ]]

  # Creates git commit
  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Add') ]]

  # Adds to index
  [[ -e "${NOTES_DATA_DIR}/.index" ]]
  [[ "$(ls "${NOTES_DATA_DIR}")" == "$(cat "${NOTES_DATA_DIR}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Added\ \[[0-9]+\]\ [A-Za-z0-9]+-bookmark.md ]]
}

# --clip option ###############################################################

@test "\`bookmark\` with --clip option creates new note with clipping." {
  {
    run "${_NOTES}" init
  }

  run "${_NOTES}" bookmark "${_BOOKMARK_URL}" --clip
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note file with content
  _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  [[ "${#_files[@]}" -eq 1 ]]
  _bookmark_content="\
# Example Domain

<file://${BATS_TEST_DIRNAME}/fixtures/example.net.html>

## Description

Example description.

## Content

Example Domain
==============

This domain is for use in illustrative examples in documents. You may
use this domain in literature without prior coordination or asking for
permission.

[More information...](https://www.iana.org/domains/example)"
  printf "cat file: '%s'\\n" "$(cat "${NOTES_DATA_DIR}/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"
  [[ "$(cat "${NOTES_DATA_DIR}/${_filename}")" == "${_bookmark_content}" ]]
  [[ $(grep '# Example Domain' "${NOTES_DATA_DIR}"/*) ]]

  # Creates git commit
  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Add') ]]

  # Adds to index
  [[ -e "${NOTES_DATA_DIR}/.index" ]]
  [[ "$(ls "${NOTES_DATA_DIR}")" == "$(cat "${NOTES_DATA_DIR}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Added\ \[[0-9]+\]\ [A-Za-z0-9]+-bookmark.md ]]
}

# --description option ########################################################

@test "\`bookmark\` with --description option creates new note with description." {
  {
    run "${_NOTES}" init
  }

  run "${_NOTES}" bookmark "${_BOOKMARK_URL}" --description "New description."
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note file with content
  _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  [[ "${#_files[@]}" -eq 1 ]]
  _bookmark_content="\
# Example Domain

<file://${BATS_TEST_DIRNAME}/fixtures/example.net.html>

## Description

New description."
  printf "cat file: '%s'\\n" "$(cat "${NOTES_DATA_DIR}/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"
  [[ "$(cat "${NOTES_DATA_DIR}/${_filename}")" == "${_bookmark_content}" ]]
  [[ $(grep '# Example Domain' "${NOTES_DATA_DIR}"/*) ]]

  # Creates git commit
  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Add') ]]

  # Adds to index
  [[ -e "${NOTES_DATA_DIR}/.index" ]]
  [[ "$(ls "${NOTES_DATA_DIR}")" == "$(cat "${NOTES_DATA_DIR}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Added\ \[[0-9]+\]\ [A-Za-z0-9]+-bookmark.md ]]
}

# --tags option ###############################################################

@test "\`bookmark\` with --tags option creates new note with tags." {
  {
    run "${_NOTES}" init
  }

  run "${_NOTES}" bookmark "${_BOOKMARK_URL}" --tags tag1,tag2
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note file with content
  _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  [[ "${#_files[@]}" -eq 1 ]]
  _bookmark_content="\
# Example Domain

<file://${BATS_TEST_DIRNAME}/fixtures/example.net.html>

## Description

Example description.

## Tags

#tag1 #tag2"
  printf "cat file: '%s'\\n" "$(cat "${NOTES_DATA_DIR}/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"
  [[ "$(cat "${NOTES_DATA_DIR}/${_filename}")" == "${_bookmark_content}" ]]
  [[ $(grep '# Example Domain' "${NOTES_DATA_DIR}"/*) ]]

  # Creates git commit
  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Add') ]]

  # Adds to index
  [[ -e "${NOTES_DATA_DIR}/.index" ]]
  [[ "$(ls "${NOTES_DATA_DIR}")" == "$(cat "${NOTES_DATA_DIR}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Added\ \[[0-9]+\]\ [A-Za-z0-9]+-bookmark.md ]]
}

@test "\`bookmark\` with --tags option and hashtags creates new note with tags." {
  {
    run "${_NOTES}" init
  }

  run "${_NOTES}" bookmark "${_BOOKMARK_URL}" --tags '#tag1','#tag2'
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note file with content
  _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  [[ "${#_files[@]}" -eq 1 ]]
  _bookmark_content="\
# Example Domain

<file://${BATS_TEST_DIRNAME}/fixtures/example.net.html>

## Description

Example description.

## Tags

#tag1 #tag2"
  printf "cat file: '%s'\\n" "$(cat "${NOTES_DATA_DIR}/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"
  [[ "$(cat "${NOTES_DATA_DIR}/${_filename}")" == "${_bookmark_content}" ]]
  [[ $(grep '# Example Domain' "${NOTES_DATA_DIR}"/*) ]]

  # Creates git commit
  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Add') ]]

  # Adds to index
  [[ -e "${NOTES_DATA_DIR}/.index" ]]
  [[ "$(ls "${NOTES_DATA_DIR}")" == "$(cat "${NOTES_DATA_DIR}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Added\ \[[0-9]+\]\ [A-Za-z0-9]+-bookmark.md ]]
}

# --title option ##############################################################

@test "\`bookmark\` with --title option creates new note with title." {
  {
    run "${_NOTES}" init
  }

  run "${_NOTES}" bookmark "${_BOOKMARK_URL}" --title "New Title"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note file with content
  _files=($(ls "${NOTES_DATA_DIR}/")) && _filename="${_files[0]}"
  [[ "${#_files[@]}" -eq 1 ]]
  _bookmark_content="\
# New Title

<file://${BATS_TEST_DIRNAME}/fixtures/example.net.html>

## Description

Example description."
  printf "cat file: '%s'\\n" "$(cat "${NOTES_DATA_DIR}/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"
  [[ "$(cat "${NOTES_DATA_DIR}/${_filename}")" == "${_bookmark_content}" ]]
  [[ $(grep '# New Title' "${NOTES_DATA_DIR}"/*) ]]

  # Creates git commit
  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Add') ]]

  # Adds to index
  [[ -e "${NOTES_DATA_DIR}/.index" ]]
  [[ "$(ls "${NOTES_DATA_DIR}")" == "$(cat "${NOTES_DATA_DIR}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Added\ \[[0-9]+\]\ [A-Za-z0-9]+-bookmark.md ]]
}

# help ########################################################################

@test "\`help bookmark\` exits with status 0 and prints." {
  run "${_NOTES}" help bookmark

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]

  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" =~  notes\ bookmark ]]
}
