#!/usr/bin/env bats

load test_helper

# --no-request ################################################################

@test "'bookmark --no-request' creates bookmark without requesting content." {
  {
    "${_NB}" init
  }

  run "${_NB}" bookmark "${_BOOKMARK_URL}" --no-request

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note with bookmark filename
  [[ "${_filename}" =~ [A-Za-z0-9]+.bookmark.md ]]

  # Creates new note file with content
  [[ "${#_files[@]}" -eq 1 ]]

  diff                                                                            \
    <(printf "<file://%s/fixtures/example.com.html>\\n" "${NB_TEST_BASE_PATH}")   \
    <(cat "${NB_DIR}/home/${_filename}")

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

# no argument #################################################################

@test "'bookmark' with no argument exits with 0, prints message, and lists." {
  {
    "${_NB}" init
    "${_NB}" add "Bookmark One.bookmark.md" -c "<${_BOOKMARK_URL}>"
    "${_NB}" add "Bookmark Two.bookmark.md" -c "<${_BOOKMARK_URL}>"
  }

  run "${_NB}" bookmark

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # exits with status 0

  [[ "${status}" -eq 0          ]]

  # does not create new file

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 2    ]]

  # does not create git commit

  cd "${NB_DIR}/home" || return 1

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done

  ! git log | grep -q '\[nb\] Add'

  # prints output

  [[ "${lines[0]}" =~ ^Add:\ .*nb\ \<url\>.*\ Help:\ .*nb\ help\ bookmark ]]
  [[ "${lines[1]}" =~ [^-]------------------------------------[^-]        ]]
}

@test "'<notebook>:bookmark' with no argument exits with 0, prints message, and lists with selector in header." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add                                  \
      "Example Notebook:Bookmark One.bookmark.md" \
      -c "<${_BOOKMARK_URL}>"

    "${_NB}" add                                  \
      "Example Notebook:Bookmark Two.bookmark.md" \
      -c "<${_BOOKMARK_URL}>"
  }

  run "${_NB}" Example\ Notebook:bookmark

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # exits with status 0

  [[ "${status}" -eq 0      ]]

  # does not create new file

  [[ -z "$(ls "${NB_DIR}/home/")" ]]

  # does not create git commit

  cd "${NB_DIR}/home" || return 1

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done

  ! git log | grep -q '\[nb\] Add'

  # prints output

  [[ "${lines[0]}" =~ \
        ^Add:\ .*nb\ Example\\\ Notebook:\ \<url\>.*\ Help:\ .*nb\ help\ bookmark ]]
  [[ "${lines[1]}" =~ \
        [^-]-------------------------------------------------------[^-]           ]]
}

# --tags option ###############################################################

@test "'bookmark' with --tags and no argument exits with 1 and prints message." {
  {
    "${_NB}" init
  }

  run "${_NB}" bookmark "${_BOOKMARK_URL}" --tags --filename "example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 1:

  [[ "${status}" -eq 1 ]]

  # Does not create new bookmark file:

  [[ ! -f "${NB_DIR}/home/example.bookmark.md" ]]

  # Prints output:

  [[ "${lines[0]}" =~ !.*\ .*--tags.*\ requires\ a\ valid\ argument. ]]
}

@test "'bookmark' with --tags option creates new bookmark with tags." {
  {
    "${_NB}" init
  }

  run "${_NB}" bookmark "${_BOOKMARK_URL}" --tags tag1,tag2 --filename "example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0 ]]

  # Creates new bookmark file with content:

  [[ -f "${NB_DIR}/home/example.bookmark.md" ]]

  diff                                          \
    <(cat "${NB_DIR}/home/example.bookmark.md") \
    <(cat <<HEREDOC
# Example Domain

<file://${NB_TEST_BASE_PATH}/fixtures/example.com.html>

## Description

Example description.

## Tags

#tag1 #tag2

## Content

$(cat "${NB_TEST_BASE_PATH}/fixtures/example.com.md")
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${lines[0]}" =~ Added:\ .*[.*1.*].*\ .*example.bookmark.md ]]
}

@test "'bookmark' with --tags option and hashtags creates new bookmark with tags." {
  {
    "${_NB}" init
  }

  run "${_NB}" bookmark     \
    "${_BOOKMARK_URL}"      \
    --tags '#tag1','#tag2'  \
    -c "Example comment."   \
    --filename "example"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0:

  [[ "${status}" -eq 0 ]]

  # Creates new bookmark file with content:

  [[ -f "${NB_DIR}/home/example.bookmark.md" ]]

  diff                                          \
    <(cat "${NB_DIR}/home/example.bookmark.md") \
    <(cat <<HEREDOC
# Example Domain

<file://${NB_TEST_BASE_PATH}/fixtures/example.com.html>

## Description

Example description.

## Comment

Example comment.

## Tags

#tag1 #tag2

## Content

$(cat "${NB_TEST_BASE_PATH}/fixtures/example.com.md")
HEREDOC
)

  # Creates git commit:

  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'

  # Adds to index:

  [[ -e "${NB_DIR}/home/.index" ]]

  diff                      \
    <(ls "${NB_DIR}/home")  \
    <(cat "${NB_DIR}/home/.index")

  # Prints output:

  [[ "${lines[0]}" =~ Added:\ .*[.*1.*].*\ .*example.bookmark.md ]]
}

# <url> or <list option...> argument ##########################################

@test "'bookmark <query>' exits with 0 and displays a list of bookmarks with titles." {
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

  run "${_NB}" bookmark example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                            ]]
  [[ "${lines[0]}" =~ Example\ Bookmark\ Title  ]] && [[ "${lines[0]}" =~ 4 ]]
  [[ "${#lines[@]}" == "1"                      ]]
}

@test "'bookmark --sort' exits with 0 and displays a sorted list of bookmarks." {
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

  run "${_NB}" bookmark --sort

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                            ]]
  [[ "${lines[0]}" =~ second.bookmark.md        ]] && [[ "${lines[0]}" =~ 2 ]]
  [[ "${lines[1]}" =~ Example\ Bookmark\ Title  ]] && [[ "${lines[1]}" =~ 4 ]]
}

@test "'bookmark -n <num>' exits with 0 and displays limited list." {
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

  run "${_NB}" bookmark -n 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                          ]]
  [[ "${lines[0]}" =~ second.bookmark.md      ]] && [[ "${lines[0]}" =~ 2 ]]
  [[ "${lines[1]}" == '1 omitted. 2 total.'   ]]
}

@test "'bookmark' with valid <url> argument creates new note without errors." {
  {
    "${_NB}" init
  }

  run "${_NB}" bookmark "${_BOOKMARK_URL}"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"

  # Returns status 0
  [[ ${status} -eq 0        ]]

  # Creates new note with bookmark filename
  [[ "${_filename}" =~ [A-Za-z0-9]+.bookmark.md ]]

  # Creates new note file with content
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

@test "'bookmark' with pdf <url> argument creates new note without errors." {
  {
    "${_NB}" init
  }

  run "${_NB}" bookmark "file://${NB_TEST_BASE_PATH}/fixtures/example.pdf"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note with bookmark filename
  [[ "${_filename}" =~ [A-Za-z0-9]+.bookmark.md ]]

  # Creates new note file with content
  [[ "${#_files[@]}" -eq 1 ]]

  _bookmark_content="<file://${NB_TEST_BASE_PATH}/fixtures/example.pdf>"

  printf "cat file: '%s'\\n" "$(cat "${NB_DIR}/home/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"

  [[ "$(cat "${NB_DIR}/home/${_filename}")" == "${_bookmark_content}" ]]

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
  [[ ${status} -eq 0        ]]

  # Creates new note with bookmark filename
  [[ "${_filename}" =~ [A-Za-z0-9]+.bookmark.md ]]

  # Creates new note file with content
  [[ "${#_files[@]}" -eq 1  ]]

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

# --comment option ############################################################

@test "'bookmark' with --comment option creates new note with comment." {
  {
    "${_NB}" init
  }

  run "${_NB}" bookmark "${_BOOKMARK_URL}" --comment "New comment."

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0        ]]

  # Creates new note file with content
  _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"
  [[ "${#_files[@]}" -eq 1  ]]

  _bookmark_content="\
# Example Domain

<file://${NB_TEST_BASE_PATH}/fixtures/example.com.html>

## Description

Example description.

## Comment

New comment.

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

# --quote option ##############################################################

@test "'bookmark' with --quote option creates new note with quote." {
  {
    "${_NB}" init
  }

  run "${_NB}" bookmark "${_BOOKMARK_URL}" --quote "Quote line 1.

Quote line 2."
  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note file with content
  _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"
  [[ "${#_files[@]}" -eq 1 ]]

  _bookmark_content="\
# Example Domain

<file://${NB_TEST_BASE_PATH}/fixtures/example.com.html>

## Description

Example description.

## Quote

> Quote line 1.
>
> Quote line 2.

## Content

$(cat "${NB_TEST_BASE_PATH}/fixtures/example.com.md")"

  _file_content="$(cat "${NB_DIR}/home/${_filename}")"

  printf "\${_file_content}: '%s'\\n" "${_file_content}"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"

  diff -u <(echo "${_file_content}") <(echo "${_bookmark_content}")

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

# --save-source option ########################################################

@test "'bookmark --save-source' creates new note with HTML content." {
  {
    "${_NB}" init
  }

  run "${_NB}" bookmark "${_BOOKMARK_URL}" --save-source

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note with bookmark filename
  [[ "${_filename}" =~ [A-Za-z0-9]+.bookmark.md ]]

  # Creates new note file with content
  [[ "${#_files[@]}" -eq 1 ]]

  _bookmark_content="\
# Example Domain

<file://${NB_TEST_BASE_PATH}/fixtures/example.com.html>

## Description

Example description.

## Content

$(cat "${NB_TEST_BASE_PATH}/fixtures/example.com.md")

## Source

\`\`\`html
$(cat "${NB_TEST_BASE_PATH}/fixtures/example.com.html")
\`\`\`"

  # TODO: vim highlighting bug \`"

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

# --skip-content option #######################################################

@test "'bookmark' with --skip-content option creates new note with no page content." {
  {
    "${_NB}" init
  }

  run "${_NB}" bookmark "${_BOOKMARK_URL}" --skip-content

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note file with content
  _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"
  [[ "${#_files[@]}" -eq 1 ]]

  _bookmark_content="\
# Example Domain

<file://${NB_TEST_BASE_PATH}/fixtures/example.com.html>

## Description

Example description."

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

# --title option ##############################################################

@test "'bookmark' with --title option creates new note with title." {
  {
    "${_NB}" init
  }

  run "${_NB}" bookmark "${_BOOKMARK_URL}" --title "New Title"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note file with content
  _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"
  [[ "${#_files[@]}" -eq 1 ]]

  _bookmark_content="\
# New Title

<file://${NB_TEST_BASE_PATH}/fixtures/example.com.html>

## Description

Example description.

## Content

$(cat "${NB_TEST_BASE_PATH}/fixtures/example.com.md")"

  printf "cat file: '%s'\\n" "$(cat "${NB_DIR}/home/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"

  [[ "$(cat "${NB_DIR}/home/${_filename}")" == "${_bookmark_content}" ]]
  grep -q '# New Title' "${NB_DIR}/home"/*

  # Creates git commit
  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep '\[nb\] Add'

  # Adds to index
  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]

  # Prints output
  [[ "${output}" =~ Added:                    ]]
  [[ "${output}" =~ [0-9]+                    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.bookmark.md  ]]
}

# --related option ############################################################

@test "'bookmark' with invalid --related <url> argument exits with 1." {
  {
    "${_NB}" init
  }

  run "${_NB}" bookmark --related

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 1
  [[ ${status} -eq 1 ]]

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
  [[ "${lines[0]}" =~ requires\ a\ valid\ argument ]]
}

@test "'bookmark' with one --related URL creates new note." {
  {
    "${_NB}" init
  }

  run "${_NB}" bookmark "${_BOOKMARK_URL}" --related https://example.net

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note file with content
  _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"
  [[ "${#_files[@]}" -eq 1 ]]

  _bookmark_content="\
# Example Domain

<file://${NB_TEST_BASE_PATH}/fixtures/example.com.html>

## Description

Example description.

## Related

- <https://example.net>

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

@test "'bookmark' with three --related URLs creates new note." {
  {
    "${_NB}" init
  }

  run "${_NB}" bookmark "${_BOOKMARK_URL}" \
    --related https://example.net \
    --related https://example.org \
    --related https://example.example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note file with content
  _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"
  [[ "${#_files[@]}" -eq 1 ]]

  _bookmark_content="\
# Example Domain

<file://${NB_TEST_BASE_PATH}/fixtures/example.com.html>

## Description

Example description.

## Related

- <https://example.net>
- <https://example.org>
- <https://example.example>

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

# --encrypt option ############################################################

@test "'bookmark --encrypt' with content argument creates a new .enc bookmark." {
  {
    "${_NB}" init
  }

  run "${_NB}" bookmark "${_BOOKMARK_URL}" --encrypt --password=example

  [[ ${status} -eq 0 ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 1                                                      ]]
  [[ "${_files[0]}" =~ enc$                                                     ]]
  [[ "$(file "${NB_DIR}/home/${_files[0]}" | cut -d: -f2)" =~ encrypted|openssl ]]
}

@test "'bookmark --encrypt --password' without argument exits with 1." {
  {
    "${_NB}" init
  }

  run "${_NB}" bookmark "${_BOOKMARK_URL}" --encrypt --password

  [[ ${status} -eq 1        ]]

  _files=($(ls "${NB_DIR}/home/"))

  [[ "${#_files[@]}" -eq 0  ]]
}

# --filename option ###########################################################

@test "'add' with --filename option exits with 0, creates new note, creates commit." {
  {
    "${_NB}" init
  }

  run "${_NB}" bookmark "${_BOOKMARK_URL}" --filename example.bookmark.md

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]

  _files=($(ls "${NB_DIR}/home/"))
  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}" -eq 1 ]]

  cd "${NB_DIR}/home" || return 1

  [[ -n "$(ls example.bookmark.md)" ]]
  grep -q '# Example Domain' "${NB_DIR}/home"/*

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

@test "'add' with --filename option uses specified extension." {
  {
    "${_NB}" init
  }

  run "${_NB}" bookmark "${_BOOKMARK_URL}" --filename example.org

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]

  _files=($(ls "${NB_DIR}/home/"))
  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}" -eq 1 ]]

  cd "${NB_DIR}/home" || return 1

  [[ -n "$(ls example.org)" ]]
  grep -q '# Example Domain' "${NB_DIR}/home"/*

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

@test "'add' with extension-less --filename option uses default extension." {
  {
    "${_NB}" init
  }

  run "${_NB}" bookmark "${_BOOKMARK_URL}" --filename example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]

  _files=($(ls "${NB_DIR}/home/"))
  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"

  [[ "${#_files[@]}" -eq 1 ]]

  cd "${NB_DIR}/home" || return 1

  [[ -n "$(ls example.bookmark.md)" ]]
  grep -q '# Example Domain' "${NB_DIR}/home"/*

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Add'
}

# `bookmark delete` ###########################################################

@test "'bookmark delete' deletes properly without errors." {
  {
    "${_NB}" init
    "${_NB}" bookmark "${_BOOKMARK_URL}"

    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"

    [[ -e "${NB_DIR}/home/${_filename}" ]]

    _original_index="$(cat "${NB_DIR}/home/.index")"
  }

  run "${_NB}" delete 1 --force

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Deletes note file
  [[ ! -e "${NB_DIR}/home/${_filename}" ]]

  # Creates git commit
  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Delete'

  # Deletes entry from index
  [[ -e "${NB_DIR}/home/.index"                                   ]]
  [[ "$(ls "${NB_DIR}/home")" == "$(cat "${NB_DIR}/home/.index")" ]]
  [[ "${_original_index}" != "$(cat "${NB_DIR}/home/.index")"     ]]

  # Prints output
  [[ "${output}" =~ Deleted:                  ]]
  [[ "${output}" =~ [0-9]+                    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.bookmark.md  ]]
}

# `bookmark edit` #############################################################

@test "'bookmark edit' edits properly without errors." {
  {
    "${_NB}" init
    "${_NB}" bookmark "${_BOOKMARK_URL}"
    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"
    _original="$(cat "${NB_DIR}/home/${_filename}")"
  }

  run "${_NB}" bookmark edit 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Updates note file
  diff                                    \
    <(cat "${NB_DIR}/home/${_filename}")  \
    <(printf "%s\\n" "${_original}")      &&
      return 1


  # Creates git commit
  cd "${NB_DIR}/home" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[nb\] Edit'

  # Prints output
  [[ "${output}" =~ Updated:                  ]]
  [[ "${output}" =~ [0-9]+                    ]]
  [[ "${output}" =~ [A-Za-z0-9]+.bookmark.md  ]]
}

# `bookmark url` ##############################################################

@test "'bookmark url' with invalid note prints error." {
  {
    "${_NB}" init
    "${_NB}" bookmark "${_BOOKMARK_URL}"
  }

  run "${_NB}" bookmark url 99

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
    "${_NB}" bookmark "${_BOOKMARK_URL}"
  }

  run "${_NB}" bookmark url 1

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
    "${_NB}" add example.bookmark.md \
      --content "\
https://example.com
<${_BOOKMARK_URL}>
<https://example.com>"
  }

  run "${_NB}" bookmark url 1

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Prints output
  [[ "${output}" == "${_BOOKMARK_URL}" ]]
}

# encrypted ###################################################################

@test "'bookmark url' with encrypted bookmark should print without errors." {
  {
    "${_NB}" init
    "${_NB}" bookmark "${_BOOKMARK_URL}" --encrypt --password=example
    _files=($(ls "${NB_DIR}/home/")) && _filename="${_files[0]}"
  }

  run "${_NB}" bookmark url 1 --password=example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Prints output
  [[ "${output}" == "${_BOOKMARK_URL}" ]]
}

# `bookmark list` #############################################################

@test "'bookmark list' exits with 0 and displays a list of bookmarks with titles." {
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

  run "${_NB}" bookmark list

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                            ]]
  [[ "${lines[0]}" =~ Example\ Bookmark\ Title  ]] && [[ "${lines[0]}" =~ 4 ]]
  [[ "${lines[1]}" =~ second.bookmark.md        ]] && [[ "${lines[1]}" =~ 2 ]]
}

@test "'bookmark list' with no bookmarks prints message." {
  {
    "${_NB}" init
    _expected="0 bookmarks.

Add a bookmark:
  $(_color_primary 'nb <url>')
Help information:
  $(_color_primary 'nb help bookmark')"
  }

  run "${_NB}" bookmark list

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${_expected}: '%s'\\n" "${_expected}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                ]]
  [[ "${_expected}" == "${output}"  ]]
}

# `bookmark list --sort` ######################################################

@test "'bookmark list --sort' exits with 0 and displays a sorted list of bookmarks." {
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

  run "${_NB}" bookmark list --sort

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ ${status} -eq 0                            ]]
  [[ "${lines[0]}" =~ second.bookmark.md        ]] && [[ "${lines[0]}" =~ 2 ]]
  [[ "${lines[1]}" =~ Example\ Bookmark\ Title  ]] && [[ "${lines[1]}" =~ 4 ]]
}

# help ########################################################################

@test "'help bookmark' exits with status 0 and prints." {
  run "${_NB}" help bookmark

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                ]]
  [[ "${lines[0]}" =~ Usage.*:      ]]
  [[ "${lines[1]}" =~  nb\ bookmark ]]
}

@test "'bookmark help' exits with status 0 and prints." {
  {
    "${_NB}" init
  }

  run "${_NB}" bookmark help

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                ]]
  [[ "${lines[0]}" =~ Usage.*:      ]]
  [[ "${lines[1]}" =~  nb\ bookmark ]]
}
