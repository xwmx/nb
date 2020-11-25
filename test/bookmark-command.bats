#!/usr/bin/env bats

load test_helper

# no argument #################################################################

@test "'bookmark' command with no argument exits with 0, prints message, and lists." {
  {
    "${_NB}" init
  }

  run "${_BOOKMARK}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0
  [[ ${status} -eq 0 ]]

  # Does not create note file
  _files=($(ls "${NB_DIR}/home/"))
  [[ "${#_files[@]}" -eq 0 ]]

  # Does not create git commit
  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  ! git log | grep -q '\[nb\] Add'

  # Prints help information
  [[ "${lines[0]}" =~ ^Add ]]
}

# <url> or <list option...> argument ##########################################

@test "'bookmark <query>' command exits with 0 and displays a list of bookmarks with titles." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first.md"
# one
line two
line three
line four
HEREDOC
    "${_NB}" add "second.bookmark.md" -c "<${_BOOKMARK_URL}>"
    cat <<HEREDOC | "${_NB}" add "third.md"
line one
line two
line three
line four
line example
HEREDOC
    "${_NB}" add "fourth.bookmark.md" -c "<${_BOOKMARK_URL}>" \
      --title "Example Bookmark Title"
    cat <<HEREDOC | "${_NB}" add "fifth.md"
# three
line two
line three
line four
HEREDOC
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_BOOKMARK}" example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ Example\ Bookmark\ Title ]] && [[ "${lines[0]}" =~ 4 ]]
  [[ "${#lines[@]}" == "1" ]]
}

@test "'bookmark --sort' command exits with 0 and displays a sorted list of bookmarks." {
  {
    "${_NB}" init
    cat <<HEREDOC | "${_NB}" add "first.md"
# one
line two
line three
line four
HEREDOC
    "${_NB}" add "second.bookmark.md" -c "<${_BOOKMARK_URL}>"
    cat <<HEREDOC | "${_NB}" add "third.md"
line one
line two
line three
line four
HEREDOC
    "${_NB}" add "fourth.bookmark.md" -c "<${_BOOKMARK_URL}>" \
      --title "Example Bookmark Title"
    cat <<HEREDOC | "${_NB}" add "fifth.md"
# three
line two
line three
line four
HEREDOC
    _files=($(ls "${NB_DIR}/home/"))
  }

  run "${_BOOKMARK}" --sort

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ second.bookmark.md       ]] && [[ "${lines[0]}" =~ 2 ]]
  [[ "${lines[1]}" =~ Example\ Bookmark\ Title ]] && [[ "${lines[1]}" =~ 4 ]]
}

@test "'bookmark' command with valid <url> argument creates new note without errors." {
  {
    "${_NB}" init
  }

  run "${_BOOKMARK}" "${_BOOKMARK_URL}"

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

@test "'bookmark' with invalid <url> argument creates new bookmark without downloading." {
  {
    "${_NB}" init
  }

  run "${_NB}" bookmark 'http://invalid-url'

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note with bookmark filename
  [[ "${_filename}}" =~ [A-Za-z0-9]+.bookmark.md ]]

  # Creates new note file with content
  [[ "${#_files[@]}" -eq 1 ]]

  _bookmark_content="# (invalid-url)

<http://invalid-url>"

  printf "cat file: '%s'\\n" "$(cat "${NB_DIR}/home/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"

  diff <(cat "${NB_DIR}/home/${_filename}") <(printf "%s\\n" "${_bookmark_content}")

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

  # Prints error message
  _message="${_ERROR_PREFIX} Unable to download page at $(_color_primary "http://invalid-url")"
  [[ "${lines[0]}" == "${_message}" ]]

  # Prints output
  [[ "${output}" =~ Added:                    ]]
  [[ "${output}" =~ [0-9]+                    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.bookmark.md  ]]
}
