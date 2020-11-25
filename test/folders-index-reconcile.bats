#!/usr/bin/env bats

load test_helper

# reconcile ###################################################################

@test "'index reconcile' with folder path reconciles the index in the current folder only." {
  {
    "${_NB}" init

    # Add blank line to root-level .index to confirm blank lines are retained:

    printf "\\n" > "${NB_DIR}/home/.index"

    wc -l < "${NB_DIR}/home/.index" | tr -d ' '

    diff <(wc -l < "${NB_DIR}/home/.index" | tr -d ' ') <(printf "1\\n")

    # Create directories:

    mkdir -p "${NB_DIR}/home/Example Folder/Sample Folder"

    [[ -d "${NB_DIR}/home/Example Folder"                ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"  ]]

    # Add files:

    cat <<HEREDOC > "${NB_DIR}/home/two.bookmark.md"
# Root-Level Example Title Two

<https://root-2.example.test>
HEREDOC

    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/one.bookmark.md"
# Example Title One

<https://1.example.test>
HEREDOC

    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/two.bookmark.md"
# Example Title Two

<https://2.example.test>
HEREDOC
    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/three.bookmark.md"
# Example Title Three

<https://3.example.test>
HEREDOC

    [[ -f "${NB_DIR}/home/two.bookmark.md"                                 ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/one.bookmark.md"    ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/two.bookmark.md"    ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/three.bookmark.md"  ]]

    # Confirm the initial .index file configuration::

    printf ".index: '%s'\\n" "$(cat "${NB_DIR}/home/.index")"

    [[   -e "${NB_DIR}/home/.index"                              ]]
    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ Example\ Folder     ]]
    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ two.bookmark.md     ]]

    [[ ! -e "${NB_DIR}/home/Example Folder/.index"               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]
  }

  # Run `index reconcile`:

  run "${_NB}" index reconcile "${NB_DIR}/home/Example Folder/Sample Folder"

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat

  cat "${NB_DIR}/home/.index"

  # Verify existence of .index files:

  [[   -e "${NB_DIR}/home/.index"                              ]]
  [[ ! -e "${NB_DIR}/home/Example Folder/.index"               ]]
  [[   -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]

  # Verify .index file contents:

  printf ".index: '%s'\\n" "$(cat "${NB_DIR}/home/.index")"
  sed -n "/^two.bookmark.md$/=" "${NB_DIR}/home/.index"

  [[ "$(sed -n "/^Example\ Folder$/=" "${NB_DIR}/home/.index")" == "" ]]
  [[ "$(sed -n "/^two.bookmark.md$/=" "${NB_DIR}/home/.index")" == "" ]]

  diff <(cat "${NB_DIR}/home/.index") \
       <(printf "\\n")

  [[ "$(cat "${NB_DIR}/home/.index")" != "$(ls -t -r "${NB_DIR}/home")" ]]

  cat "${NB_DIR}/home/Example Folder/Sample Folder/.index"

  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ one.bookmark.md    ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ two.bookmark.md    ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ three.bookmark.md  ]]

  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")" == \
       "$(ls -t -r "${NB_DIR}/home/Example Folder/Sample Folder")" ]]

  # Verify the absense of a .index file in the notebook parent:

  [[ ! -e "${NB_DIR}/home/../.index" ]]
}

@test "'index reconcile --ancestors' with folder path reconciles the index in all ancestors." {
  {
    "${_NB}" init

    # Add blank line to root-level .index to confirm blank lines are retained:

    printf "\\n" > "${NB_DIR}/home/.index"

    wc -l < "${NB_DIR}/home/.index" | tr -d ' '

    diff <(wc -l < "${NB_DIR}/home/.index" | tr -d ' ') <(printf "1\\n")

    # Create directories:

    mkdir -p "${NB_DIR}/home/Example Folder/Sample Folder"

    [[ -d "${NB_DIR}/home/Example Folder"                ]]
    [[ -d "${NB_DIR}/home/Example Folder/Sample Folder"  ]]

    # Add files:

    cat <<HEREDOC > "${NB_DIR}/home/two.bookmark.md"
# Root-Level Example Title Two

<https://root-2.example.test>
HEREDOC

    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/one.bookmark.md"
# Example Title One

<https://1.example.test>
HEREDOC

    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/two.bookmark.md"
# Example Title Two

<https://2.example.test>
HEREDOC
    cat <<HEREDOC > "${NB_DIR}/home/Example Folder/Sample Folder/three.bookmark.md"
# Example Title Three

<https://3.example.test>
HEREDOC

    [[ -f "${NB_DIR}/home/two.bookmark.md"                                 ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/one.bookmark.md"    ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/two.bookmark.md"    ]]
    [[ -f "${NB_DIR}/home/Example Folder/Sample Folder/three.bookmark.md"  ]]

    # Confirm the initial .index file configuration::

    printf ".index: '%s'\\n" "$(cat "${NB_DIR}/home/.index")"

    [[   -e "${NB_DIR}/home/.index"                              ]]
    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ Example\ Folder     ]]
    [[ ! "$(cat "${NB_DIR}/home/.index")" =~ two.bookmark.md     ]]

    [[ ! -e "${NB_DIR}/home/Example Folder/.index"               ]]
    [[ ! -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]
  }

  # Run `index reconcile`:

  run "${_NB}" index reconcile "${NB_DIR}/home/Example Folder/Sample Folder" --ancestors

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  "${_NB}" git log --stat

  cat "${NB_DIR}/home/.index"

  # Verify existence of .index files:

  [[ -e "${NB_DIR}/home/.index"                              ]]
  [[ -e "${NB_DIR}/home/Example Folder/.index"               ]]
  [[ -e "${NB_DIR}/home/Example Folder/Sample Folder/.index" ]]

  # Verify .index file contents:

  printf ".index: '%s'\\n" "$(cat "${NB_DIR}/home/.index")"
  sed -n "/^two.bookmark.md$/=" "${NB_DIR}/home/.index"

  [[ "$(sed -n "/^Example\ Folder$/=" "${NB_DIR}/home/.index")" == "2" ]]
  [[ "$(sed -n "/^two.bookmark.md$/=" "${NB_DIR}/home/.index")" == "3" ]]

  diff <(cat "${NB_DIR}/home/.index") \
       <(echo "${_NEWLINE}Example Folder${_NEWLINE}two.bookmark.md")

  [[ "$(cat "${NB_DIR}/home/.index")" != "$(ls -t -r "${NB_DIR}/home")" ]]

  [[ "$(cat "${NB_DIR}/home/Example Folder/.index")" =~ Sample\ Folder ]]

  [[ "$(cat "${NB_DIR}/home/Example Folder/.index")" == \
       "$(ls -t -r "${NB_DIR}/home/Example Folder")" ]]

  cat "${NB_DIR}/home/Example Folder/Sample Folder/.index"

  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ one.bookmark.md    ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ two.bookmark.md    ]]
  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")"   =~ three.bookmark.md  ]]

  [[ "$(cat "${NB_DIR}/home/Example Folder/Sample Folder/.index")" == \
       "$(ls -t -r "${NB_DIR}/home/Example Folder/Sample Folder")" ]]

  # Verify the absense of a .index file in the notebook parent:

  [[ ! -e "${NB_DIR}/home/../.index" ]]
}
