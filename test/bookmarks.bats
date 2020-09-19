#!/usr/bin/env bats

load test_helper

# `bookmarks` #################################################################

@test "\`bookmarks\` exits with 0 and displays a list of bookmarks with titles." {
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
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" bookmarks

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                            ]]
  [[ "${lines[0]}" =~ Add                       ]] && [[ "${lines[0]}" =~ Help  ]]
  [[ "${lines[1]}" =~ ---                       ]]
  [[ "${lines[2]}" =~ Example\ Bookmark\ Title  ]] && [[ "${lines[2]}" =~ 4     ]]
  [[ "${lines[3]}" =~ second.bookmark.md        ]] && [[ "${lines[3]}" =~ 2     ]]
}

# `bookmarks --sort` ##########################################################

@test "\`bookmarks --sort\` exits with 0 and displays a sorted list of bookmarks." {
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
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}" bookmarks --sort

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"
  printf "\${_files[@]}: '%s'\\n" "${_files[@]}"

  [[ ${status} -eq 0                            ]]
  [[ "${lines[0]}" =~ second.bookmark.md        ]] && [[ "${lines[0]}" =~ 2 ]]
  [[ "${lines[1]}" =~ Example\ Bookmark\ Title  ]] && [[ "${lines[1]}" =~ 4 ]]
}
