#!/usr/bin/env bats

load test_helper

# rebuild #####################################################################

@test "'index rebuild' with folder path rebuilds a missing index in the current folder only." {
  {
    "${_NB}" init

    # Add blank line to root-level .index to confirm blank lines are retained:

    printf "\\n" > "${_NOTEBOOK_PATH}/.index"

    wc -l < "${_NOTEBOOK_PATH}/.index" | tr -d ' '

    diff <(wc -l < "${_NOTEBOOK_PATH}/.index" | tr -d ' ') <(printf "1\\n")

    # Create directories:

    mkdir -p "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"

    [[ -d "${_NOTEBOOK_PATH}/Example Folder"                ]]
    [[ -d "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"  ]]

    # Add files:

    cat <<HEREDOC > "${_NOTEBOOK_PATH}/two.bookmark.md"
# Root-Level Example Title Two

<https://root-2.example.test>
HEREDOC

    cat <<HEREDOC > "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/one.bookmark.md"
# Example Title One

<https://1.example.test>
HEREDOC

    cat <<HEREDOC > "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/two.bookmark.md"
# Example Title Two

<https://2.example.test>
HEREDOC
    cat <<HEREDOC > "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/three.bookmark.md"
# Example Title Three

<https://3.example.test>
HEREDOC

    [[ -f "${_NOTEBOOK_PATH}/two.bookmark.md"                                 ]]
    [[ -f "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/one.bookmark.md"    ]]
    [[ -f "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/two.bookmark.md"    ]]
    [[ -f "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/three.bookmark.md"  ]]

    # Confirm the initial .index file configuration::

    printf ".index: '%s'\\n" "$(cat "${_NOTEBOOK_PATH}/.index")"

    [[   -e "${_NOTEBOOK_PATH}/.index"                              ]]
    [[ ! "$(cat "${_NOTEBOOK_PATH}/.index")" =~ Example\ Folder     ]]
    [[ ! "$(cat "${_NOTEBOOK_PATH}/.index")" =~ two.bookmark.md     ]]

    [[ ! -e "${_NOTEBOOK_PATH}/Example Folder/.index"               ]]
    [[ ! -e "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index" ]]
  }

  # Run `index rebuild`:

  _INDEX_FOLDER_PATH="${_NOTEBOOK_PATH}/Example Folder/Sample Folder" \
    run "${_NB}" index rebuild

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat

  cat "${_NOTEBOOK_PATH}/.index"

  # Verify existence of .index files:

  [[   -e "${_NOTEBOOK_PATH}/.index"                              ]]
  [[ ! -e "${_NOTEBOOK_PATH}/Example Folder/.index"               ]]
  [[   -e "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index" ]]

  # Verify .index file contents:

  printf ".index: '%s'\\n" "$(cat "${_NOTEBOOK_PATH}/.index")"
  sed -n "/^two.bookmark.md$/=" "${_NOTEBOOK_PATH}/.index"

  [[ "$(sed -n "/^Example\ Folder$/=" "${_NOTEBOOK_PATH}/.index")" == "" ]]
  [[ "$(sed -n "/^two.bookmark.md$/=" "${_NOTEBOOK_PATH}/.index")" == "" ]]

  diff <(cat "${_NOTEBOOK_PATH}/.index") \
       <(printf "\\n")

  [[ "$(cat "${_NOTEBOOK_PATH}/.index")" != "$(ls -t -r "${_NOTEBOOK_PATH}")" ]]

  cat "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index"

  [[ "$(cat "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index")"   =~ one.bookmark.md    ]]
  [[ "$(cat "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index")"   =~ two.bookmark.md    ]]
  [[ "$(cat "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index")"   =~ three.bookmark.md  ]]

  [[ "$(cat "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index")" == \
       "$(ls -t -r "${_NOTEBOOK_PATH}/Example Folder/Sample Folder")" ]]

  # Verify the absense of a .index file in the notebook parent:

  [[ ! -e "${_NOTEBOOK_PATH}/../.index" ]]
}

@test "'index rebuild --ancestors' with folder path rebuilds the index in all ancestors." {
  {
    "${_NB}" init

    # Add blank line to root-level .index to confirm blank lines are retained:

    printf "\\n" > "${_NOTEBOOK_PATH}/.index"

    wc -l < "${_NOTEBOOK_PATH}/.index" | tr -d ' '

    diff <(wc -l < "${_NOTEBOOK_PATH}/.index" | tr -d ' ') <(printf "1\\n")

    # Create directories:

    mkdir -p "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"

    [[ -d "${_NOTEBOOK_PATH}/Example Folder"                ]]
    [[ -d "${_NOTEBOOK_PATH}/Example Folder/Sample Folder"  ]]

    # Add files:

    cat <<HEREDOC > "${_NOTEBOOK_PATH}/two.bookmark.md"
# Root-Level Example Title Two

<https://root-2.example.test>
HEREDOC

    cat <<HEREDOC > "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/one.bookmark.md"
# Example Title One

<https://1.example.test>
HEREDOC

    cat <<HEREDOC > "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/two.bookmark.md"
# Example Title Two

<https://2.example.test>
HEREDOC
    cat <<HEREDOC > "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/three.bookmark.md"
# Example Title Three

<https://3.example.test>
HEREDOC

    [[ -f "${_NOTEBOOK_PATH}/two.bookmark.md"                                 ]]
    [[ -f "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/one.bookmark.md"    ]]
    [[ -f "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/two.bookmark.md"    ]]
    [[ -f "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/three.bookmark.md"  ]]

    # Confirm the initial .index file configuration::

    printf ".index: '%s'\\n" "$(cat "${_NOTEBOOK_PATH}/.index")"

    [[   -e "${_NOTEBOOK_PATH}/.index"                              ]]
    [[ ! "$(cat "${_NOTEBOOK_PATH}/.index")" =~ Example\ Folder     ]]
    [[ ! "$(cat "${_NOTEBOOK_PATH}/.index")" =~ two.bookmark.md     ]]

    [[ ! -e "${_NOTEBOOK_PATH}/Example Folder/.index"               ]]
    [[ ! -e "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index" ]]
  }

  # Run `index rebuild`:

  _INDEX_FOLDER_PATH="${_NOTEBOOK_PATH}/Example Folder/Sample Folder" \
    run "${_NB}" index rebuild --ancestors

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat

  cat "${_NOTEBOOK_PATH}/.index"

  # Verify existence of .index files:

  [[ -e "${_NOTEBOOK_PATH}/.index"                              ]]
  [[ -e "${_NOTEBOOK_PATH}/Example Folder/.index"               ]]
  [[ -e "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index" ]]

  # Verify .index file contents:

  printf ".index: '%s'\\n" "$(cat "${_NOTEBOOK_PATH}/.index")"
  sed -n "/^two.bookmark.md$/=" "${_NOTEBOOK_PATH}/.index"

  [[ "$(sed -n "/^two.bookmark.md$/=" "${_NOTEBOOK_PATH}/.index")" == "1" ]]
  [[ "$(sed -n "/^Example\ Folder$/=" "${_NOTEBOOK_PATH}/.index")" == "2" ]]

  diff <(cat "${_NOTEBOOK_PATH}/.index") \
       <(echo "two.bookmark.md${_NEWLINE}Example Folder")

  [[ "$(cat "${_NOTEBOOK_PATH}/.index")" == "$(ls -t -r "${_NOTEBOOK_PATH}")" ]]

  [[ "$(cat "${_NOTEBOOK_PATH}/Example Folder/.index")" =~ Sample\ Folder ]]

  [[ "$(cat "${_NOTEBOOK_PATH}/Example Folder/.index")" == \
       "$(ls -t -r "${_NOTEBOOK_PATH}/Example Folder")" ]]

  cat "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index"

  [[ "$(cat "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index")"   =~ one.bookmark.md    ]]
  [[ "$(cat "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index")"   =~ two.bookmark.md    ]]
  [[ "$(cat "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index")"   =~ three.bookmark.md  ]]

  [[ "$(cat "${_NOTEBOOK_PATH}/Example Folder/Sample Folder/.index")" == \
       "$(ls -t -r "${_NOTEBOOK_PATH}/Example Folder/Sample Folder")" ]]

  # Verify the absense of a .index file in the notebook parent:

  [[ ! -e "${_NOTEBOOK_PATH}/../.index" ]]
}

