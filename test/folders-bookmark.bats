#!/usr/bin/env bats

load test_helper

# no argument #################################################################

@test "'bookmark <folder>/' with no argument exits with 0, prints message, and lists." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type folder

    [[   -d "${NB_DIR}/home/Example Folder"         ]]
    [[   -f "${NB_DIR}/home/Example Folder/.index"  ]]
  }

  run "${_NB}" bookmark Example\ Folder/

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 0:

  [[ ${status} -eq 0          ]]

  # Does not create note file:

  _files=($(ls "${NB_DIR}/home/"))
  [[ "${#_files[@]}" -eq 1    ]]

  # Does not create git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  ! git log | grep -q '\[nb\] Add'

  # Prints help information:

  [[ "${lines[0]}" =~ 0\ bookmarks. ]]
  [[ "${lines[2]}" =~ 1/\ \<url\>   ]]
}

# `bookmark url` ##############################################################

@test "'bookmark url <folder>/<id>' with invalid <id> prints error." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder" --type folder
    "${_NB}" bookmark Example\ Folder/ "${_BOOKMARK_URL}"

    _files=($(ls "${NB_DIR}/home/Example Folder")) && _filename="${_files[0]}"

    [[ -d "${NB_DIR}/home/Example Folder"               ]]
    [[ -f "${NB_DIR}/home/Example Folder/${_filename}"  ]]
  }

  run "${_NB}" bookmark url Example\ Folder/99

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 1 ]]

  # Prints output
  [[ "${output}" =~ Not\ found ]]
}

@test "'bookmark url' prints note url." {
  {
    "${_NB}" init
    "${_NB}" add "Example Folder" --type folder
    "${_NB}" bookmark Example\ Folder/ "${_BOOKMARK_URL}"

    _files=($(ls "${NB_DIR}/home/Example Folder")) && _filename="${_files[0]}"

    [[ -d "${NB_DIR}/home/Example Folder"               ]]
    [[ -f "${NB_DIR}/home/Example Folder/${_filename}"  ]]
  }

  run "${_NB}" bookmark url Example\ Folder/1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Prints output
  [[ "${output}" == "${_BOOKMARK_URL}" ]]
}

@test "'bookmark url' with multiple URLs prints first url in <>." {
  {
    "${_NB}" init
    "${_NB}" add Example\ Folder/example.bookmark.md \
      --content "\
https://example.com
<${_BOOKMARK_URL}>
<https://example.com>"

    _files=($(ls "${NB_DIR}/home/Example Folder")) && _filename="${_files[0]}"

    [[ -d "${NB_DIR}/home/Example Folder"               ]]
    [[ -f "${NB_DIR}/home/Example Folder/${_filename}"  ]]
  }

  run "${_NB}" bookmark url Example\ Folder/1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Prints output
  [[ "${output}" == "${_BOOKMARK_URL}" ]]
}

# <url> #######################################################################

@test "'bookmark <folder>/<folder> <url>' (no slash) with valid <url> argument creates new bookmark and folder without errors." {
  {
    "${_NB}" init

    [[ ! -d "${NB_DIR}/home/Example Folder"                       ]]
    [[ ! -f "${NB_DIR}/home/Example Folder/.index"                ]]
    [[ ! -d "${NB_DIR}/home/Example Folder/Sample Folder"         ]]
    [[ ! -f "${NB_DIR}/home/Example Folder/Sample Folder/.index"  ]]
  }

  run "${_NB}" bookmark Example\ Folder/Sample\ Folder "${_BOOKMARK_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0        ]]

  # Creates folder:

  [[   -d "${NB_DIR}/home/Example Folder"                       ]]
  [[   -f "${NB_DIR}/home/Example Folder/.index"                ]]
  [[ ! -d "${NB_DIR}/home/Example Folder/Sample Folder"         ]]
  [[ ! -f "${NB_DIR}/home/Example Folder/Sample Folder/.index"  ]]

  # Creates new file with bookmark filename in first-level folder:

  _files=($(ls "${NB_DIR}/home/Example Folder")) && _filename="${_files[0]}"

  [[        "${_filename}" =~ [A-Za-z0-9]+.bookmark.md    ]]
  [[    -f  "${NB_DIR}/home/Example Folder/${_filename}"  ]]
  [[ !  -f  "${NB_DIR}/home/${_filename}"                 ]]

  # Creates new file with content:

  [[ "${#_files[@]}" -eq 1  ]]

  _bookmark_content="\
# Example Domain

<file://${NB_TEST_BASE_PATH}/fixtures/example.com.html>

## Description

Example description.

## Content

$(cat "${NB_TEST_BASE_PATH}/fixtures/example.com.md")"

  printf "cat file: '%s'\\n" "$(cat "${NB_DIR}/home/Example Folder/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"

  diff                                                  \
    <(cat "${NB_DIR}/home/Example Folder/${_filename}") \
    <(printf "%s\\n" "${_bookmark_content}")

  grep -q '# Example Domain' "${NB_DIR}/home/Example Folder"/*

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/Example Folder/.index"    ]]

  diff                                            \
    <(ls  "${NB_DIR}/home/Example Folder/")       \
    <(cat "${NB_DIR}/home/Example Folder/.index")

  # Prints output:

  [[ "${output}" =~ Added:                                    ]]
  [[ "${output}" =~ [0-9]+                                    ]]
  [[ "${output}" =~ Example\ Folder/[A-Za-z0-9]+.bookmark.md  ]]
}

@test "'bookmark <folder> <url>' (no slash) with valid <url> argument creates new bookmark at root level without errors." {
  {
    "${_NB}" init

    [[ ! -d "${NB_DIR}/home/Example Folder"        ]]
    [[ ! -f "${NB_DIR}/home/Example Folder/.index" ]]
  }

  run "${_NB}" bookmark Example\ Folder "${_BOOKMARK_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0        ]]

  # Does not create folder:

  [[ ! -d "${NB_DIR}/home/Example Folder"        ]]
  [[ ! -f "${NB_DIR}/home/Example Folder/.index" ]]

  # Creates new file with bookmark filename:

  _files=($(ls "${NB_DIR}/home")) && _filename="${_files[0]}"

  [[        "${_filename}" =~ [A-Za-z0-9]+.bookmark.md    ]]
  [[    -f  "${NB_DIR}/home/${_filename}"                 ]]

  # Creates new file with content:

  [[ "${#_files[@]}" -eq 1  ]]

  _bookmark_content="\
# Example Domain

<file://${NB_TEST_BASE_PATH}/fixtures/example.com.html>

## Description

Example description.

## Content

$(cat "${NB_TEST_BASE_PATH}/fixtures/example.com.md")"

  printf "cat file: '%s'\\n" "$(cat "${NB_DIR}/home/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"

  diff                                                  \
    <(cat "${NB_DIR}/home/${_filename}") \
    <(printf "%s\\n" "${_bookmark_content}")

  grep -q '# Example Domain' "${NB_DIR}/home"/*

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                             \
    <(ls  "${NB_DIR}/home/")       \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${output}" =~ Added:                    ]]
  [[ "${output}" =~ [0-9]+                    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.bookmark.md  ]]
}

@test "'bookmark <folder>/ <url>' with valid <url> argument creates new bookmark and folder without errors." {
  {
    "${_NB}" init

    [[ ! -d "${NB_DIR}/home/Example Folder"        ]]
    [[ ! -f "${NB_DIR}/home/Example Folder/.index" ]]
  }

  run "${_NB}" bookmark Example\ Folder/ "${_BOOKMARK_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0        ]]

  # Creates folder:

  [[   -d "${NB_DIR}/home/Example Folder"        ]]
  [[   -f "${NB_DIR}/home/Example Folder/.index" ]]

  # Creates new file with bookmark filename:

  _files=($(ls "${NB_DIR}/home/Example Folder")) && _filename="${_files[0]}"

  [[        "${_filename}" =~ [A-Za-z0-9]+.bookmark.md    ]]
  [[    -f  "${NB_DIR}/home/Example Folder/${_filename}"  ]]
  [[ !  -f  "${NB_DIR}/home/${_filename}"                 ]]

  # Creates new file with content:

  [[ "${#_files[@]}" -eq 1  ]]

  _bookmark_content="\
# Example Domain

<file://${NB_TEST_BASE_PATH}/fixtures/example.com.html>

## Description

Example description.

## Content

$(cat "${NB_TEST_BASE_PATH}/fixtures/example.com.md")"

  printf "cat file: '%s'\\n" "$(cat "${NB_DIR}/home/Example Folder/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"

  diff                                                  \
    <(cat "${NB_DIR}/home/Example Folder/${_filename}") \
    <(printf "%s\\n" "${_bookmark_content}")

  grep -q '# Example Domain' "${NB_DIR}/home/Example Folder"/*

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/Example Folder/.index"    ]]

  diff                                            \
    <(ls  "${NB_DIR}/home/Example Folder/")       \
    <(cat "${NB_DIR}/home/Example Folder/.index")

  # Prints output:

  [[ "${output}" =~ Added:                                    ]]
  [[ "${output}" =~ [0-9]+                                    ]]
  [[ "${output}" =~ Example\ Folder/[A-Za-z0-9]+.bookmark.md  ]]
}

@test "'bookmark <folder>/<folder>/ <url>' with valid <url> argument creates new bookmark and folder without errors." {
  {
    "${_NB}" init

    [[ ! -d "${NB_DIR}/home/Example Folder"                       ]]
    [[ ! -f "${NB_DIR}/home/Example Folder/.index"                ]]
    [[ ! -d "${NB_DIR}/home/Example Folder/Sample Folder"         ]]
    [[ ! -f "${NB_DIR}/home/Example Folder/Sample Folder/.index"  ]]
  }

  run "${_NB}" bookmark Example\ Folder/Sample\ Folder/ "${_BOOKMARK_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ ${status} -eq 0        ]]

  # Creates folders:

    [[   -d "${NB_DIR}/home/Example Folder"                       ]]
    [[   -f "${NB_DIR}/home/Example Folder/.index"                ]]
    [[   -d "${NB_DIR}/home/Example Folder/Sample Folder"         ]]
    [[   -f "${NB_DIR}/home/Example Folder/Sample Folder/.index"  ]]

  # Creates new file with bookmark filename:

  _files=($(ls "${NB_DIR}/home/Example Folder/Sample Folder")) &&
    _filename="${_files[0]}"

  [[        "${_filename}" =~ [A-Za-z0-9]+.bookmark.md                  ]]
  [[    -f  "${NB_DIR}/home/Example Folder/Sample Folder/${_filename}"  ]]
  [[ !  -f  "${NB_DIR}/home/Example Folder/${_filename}"                ]]
  [[ !  -f  "${NB_DIR}/home/${_filename}"                               ]]

  # Creates new file with content:

  [[ "${#_files[@]}" -eq 1  ]]

  _bookmark_content="\
# Example Domain

<file://${NB_TEST_BASE_PATH}/fixtures/example.com.html>

## Description

Example description.

## Content

$(cat "${NB_TEST_BASE_PATH}/fixtures/example.com.md")"

  printf "cat file: '%s'\\n" "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"

  diff                                                                \
    <(cat "${NB_DIR}/home/Example Folder/Sample Folder/${_filename}") \
    <(printf "%s\\n" "${_bookmark_content}")

  grep -q '# Example Domain' "${NB_DIR}/home/Example Folder/Sample Folder"/*

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/Example Folder/Sample Folder/.index"    ]]

  diff                                                          \
    <(ls  "${NB_DIR}/home/Example Folder/Sample Folder/")       \
    <(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")

  # Prints output:

  [[ "${output}" =~ Added:                                                  ]]
  [[ "${output}" =~ [0-9]+                                                  ]]
  [[ "${output}" =~ Example\ Folder/Sample\ Folder/[A-Za-z0-9]+.bookmark.md ]]
}

# <list option...> arguments ##################################################

# TODO
# @test "'bookmark <folder>/ <query>' exits with 0 and displays a list of bookmarks with titles." {
#   {
#     "${_NB}" init
#     cat <<HEREDOC | "${_NB}" add "Example Folder/first.md"
# # one
# line two
# line three
# line four
# HEREDOC
#     "${_NB}" add "Example Folder/second.bookmark.md" -c "<${_BOOKMARK_URL}>"
#     cat <<HEREDOC | "${_NB}" add "Example Folder/third.md"
# line one
# line two
# line three
# line four
# line example
# HEREDOC
#     "${_NB}" add "Example Folder/fourth.bookmark.md" -c "<${_BOOKMARK_URL}>" \
#       --title "Example Bookmark Title"
#     cat <<HEREDOC | "${_NB}" add "Example Folder/fifth.md"
# # three
# line two
# line three
# line four
# HEREDOC
#     _files=($(ls "${NB_DIR}/home/"))
#   }

#   run "${_NB}" bookmark Example\ Folder/ example

#   printf "\${status}: '%s'\\n" "${status}"
#   printf "\${output}: '%s'\\n" "${output}"
#   printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

#   [[ ${status} -eq 0                            ]]
#   [[ "${lines[0]}" =~ Example\ Bookmark\ Title  ]] && [[ "${lines[0]}" =~ 4 ]]
#   [[ "${#lines[@]}" == "1"                      ]]
# }
