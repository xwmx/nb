#!/usr/bin/env bats

load test_helper

# `notes bookmarks` ###########################################################

@test "\`bookmarks\` exits with 0 and displays a list of bookmarks with titles." {
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

  run "${_NOTES}" bookmarks

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ Example\ Bookmark\ Title ]] && [[ "${lines[0]}" =~ 4 ]]
  [[ "${lines[1]}" =~ second.bookmark.md$      ]] && [[ "${lines[1]}" =~ 2 ]]
}

# `notes bookmarks` ###########################################################

@test "\`bookmarks --sort\` exits with 0 and displays a sorted list of bookmarks." {
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

  run "${_NOTES}" bookmarks --sort

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ second.bookmark.md$      ]] && [[ "${lines[0]}" =~ 2 ]]
  [[ "${lines[1]}" =~ Example\ Bookmark\ Title ]] && [[ "${lines[1]}" =~ 4 ]]
}
