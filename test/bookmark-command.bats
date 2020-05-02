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
  [[ "${lines[0]}" =~ ^Add ]]
}

# <url> or <list option...> argument ##########################################

@test "\`bookmark\` with invalid <url> argument exits with 1." {
  {
    run "${_NOTES}" init
  }

  run "${_BOOKMARK}" 'http invalid url'
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
  [[ "${lines[0]}" == "Unable to download page at 'http invalid url'" ]]
}

@test "\`bookmark <query>\` exits with 0 and displays a list of bookmarks with titles." {
  {
    "${_NOTES}" init
    cat <<HEREDOC | "${_NOTES}" add "first.md"
# one
line two
line three
line four
HEREDOC
    "${_NOTES}" add "second.bookmark.md" -c "<${_BOOKMARK_URL}>"
    cat <<HEREDOC | "${_NOTES}" add "third.md"
line one
line two
line three
line four
line example
HEREDOC
    "${_NOTES}" add "fourth.bookmark.md" -c "<${_BOOKMARK_URL}>" \
      --title "Example Bookmark Title"
    cat <<HEREDOC | "${_NOTES}" add "fifth.md"
# three
line two
line three
line four
HEREDOC
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_BOOKMARK}" example

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ Example\ Bookmark\ Title ]] && [[ "${lines[0]}" =~ 4 ]]
  [[ "${#lines[@]}" == "1" ]]
}

@test "\`bookmark --sort\` exits with 0 and displays a sorted list of bookmarks." {
  {
    "${_NOTES}" init
    cat <<HEREDOC | "${_NOTES}" add "first.md"
# one
line two
line three
line four
HEREDOC
    "${_NOTES}" add "second.bookmark.md" -c "<${_BOOKMARK_URL}>"
    cat <<HEREDOC | "${_NOTES}" add "third.md"
line one
line two
line three
line four
HEREDOC
    "${_NOTES}" add "fourth.bookmark.md" -c "<${_BOOKMARK_URL}>" \
      --title "Example Bookmark Title"
    cat <<HEREDOC | "${_NOTES}" add "fifth.md"
# three
line two
line three
line four
HEREDOC
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_BOOKMARK}" --sort

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ second.bookmark.md       ]] && [[ "${lines[0]}" =~ 2 ]]
  [[ "${lines[1]}" =~ Example\ Bookmark\ Title ]] && [[ "${lines[1]}" =~ 4 ]]
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

## Page Content

$(cat "${BATS_TEST_DIRNAME}/fixtures/example.com.md")"
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
