#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031,SC2063

load test_helper

# no argument #################################################################

@test "\`add\` with no arguments creates new note file created with \$EDITOR." {
  run "${_NOTES}" init
  run "${_NOTES}" add
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates a new note file with $EDITOR
  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 1 ]]
  grep -q '# mock_editor' "${_NOTEBOOK_PATH}"/*

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[NOTES\] Add'
}

# <content> argument ##########################################################

@test "\`add\` with content argument creates new note without errors." {
  run "${_NOTES}" init
  run "${_NOTES}" add "# Content"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note file with content
  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 1 ]]
  grep -q '# Content' "${_NOTEBOOK_PATH}"/*

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[NOTES\] Add'

  # Adds to index
  [[ -e "${_NOTEBOOK_PATH}/.index" ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Added\ \[[0-9]+\]\ [A-Za-z0-9]+.md ]]
}

@test "\`add\` with scope creates new note without errors." {
  run "${_NOTES}" init
  run "${_NOTES}" notebooks add Example
  run "${_NOTES}" Example:add "# Content"
  _NOTEBOOK_PATH="${NOTES_DIR}/Example"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note file with content
  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 1 ]]
  grep -q '# Content' "${_NOTEBOOK_PATH}"/*

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[NOTES\] Add'

  # Adds to index
  [[ -e "${_NOTEBOOK_PATH}/.index" ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Added\ \[Example:[0-9]+\]\ Example:[A-Za-z0-9]+.md ]]
}

# --content option ############################################################


@test "\`add\` with --content option exits with 0, creates new note, creates commit." {
  run "${_NOTES}" init
  run "${_NOTES}" add --content "# Content"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]

  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 1 ]]
  grep -q '# Content' "${_NOTEBOOK_PATH}"/*

  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[NOTES\] Add'
}

@test "\`add\` with empty --content option exits with 1" {
  run "${_NOTES}" init
  run "${_NOTES}" add --content
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]

  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 0 ]]
}

# --filename option ###########################################################


@test "\`add\` with --filename option exits with 0, creates new note, creates commit." {
  run "${_NOTES}" init
  run "${_NOTES}" add --filename example.md
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]

  _files=($(ls "${_NOTEBOOK_PATH}/"))
  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"
  [[ "${#_files[@]}" -eq 1 ]]

  cd "${_NOTEBOOK_PATH}" || return 1

  [[ -n "$(ls example.md)" ]]
  grep -q '# mock_editor' "${_NOTEBOOK_PATH}"/*

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[NOTES\] Add'
}

@test "\`add\` with empty --filename option exits with 1" {
  run "${_NOTES}" init
  run "${_NOTES}" add --filename
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]

  cd "${_NOTEBOOK_PATH}" || return 1
  ls "${_NOTEBOOK_PATH}/"
  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 0 ]]
}

# --title option ##############################################################


@test "\`add\` with --title option exits with 0, creates new note, creates commit." {
  run "${_NOTES}" init
  run "${_NOTES}" add --title "Example Title"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]

  _files=($(ls "${_NOTEBOOK_PATH}/"))
  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"
  [[ "${#_files[@]}" -eq 1 ]]

  cd "${_NOTEBOOK_PATH}" || return 1

  [[ -n "$(ls Example_Title.md)" ]]
  grep -q '# mock_editor' "${_NOTEBOOK_PATH}"/*

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[NOTES\] Add'
}

@test "\`add\` with empty --title option exits with 1" {
  run "${_NOTES}" init
  run "${_NOTES}" add --title
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]

  cd "${_NOTEBOOK_PATH}" || return 1
  ls "${_NOTEBOOK_PATH}/"
  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 0 ]]
}

# --type option ###############################################################

@test "\`add --type org\` with content argument creates a new .org note file." {
  run "${_NOTES}" init
  run "${_NOTES}" add  "* Content" --type org

  [[ ${status} -eq 0 ]]

  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 1 ]]
  grep -q '* Content' "${_NOTEBOOK_PATH}"/*
  [[ "${_files[0]}" =~ org$ ]]
}

@test "\`add --type ''\` without argument exits with 1." {
  run "${_NOTES}" init
  run "${_NOTES}" add  "* Content" --type

  [[ ${status} -eq 1 ]]

  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 0 ]]
}

# --encrypt option ############################################################

@test "\`add --encrypt\` with content argument creates a new .enc note file." {
  run "${_NOTES}" init
  run "${_NOTES}" add  "* Content" --encrypt --password=example

  [[ ${status} -eq 0 ]]

  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 1 ]]
  [[ "${_files[0]}" =~ enc$ ]]
  [[ "$(file "${_NOTEBOOK_PATH}/${_files[0]}" | cut -d: -f2)" =~ encrypted|openssl ]]
}

# --password option ###########################################################

@test "\`add --password\` without argument exits with 1." {
  run "${_NOTES}" init
  run "${_NOTES}" add  "* Content" --encrypt --password

  [[ ${status} -eq 1 ]]

  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 0 ]]
}

# piped #######################################################################

@test "\`add\` with piped content creates new note without errors." {
  run "${_NOTES}" init
  run bash -c "echo '# Piped' | \"${_NOTES}\" add"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note file
  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 1 ]]
  grep -q '# Piped' "${_NOTEBOOK_PATH}"/*

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  git log | grep -q '\[NOTES\] Add'

  # Adds to index
  [[ -e "${_NOTEBOOK_PATH}/.index" ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Added\ \[[0-9]+\]\ [A-Za-z0-9]+.md ]]
}

@test "\`add --type org\` with piped content creates a new .org note file." {
  run "${_NOTES}" init
  run bash -c "echo '# Piped' | \"${_NOTES}\" add --type org"

  [[ ${status} -eq 0 ]]

  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 1 ]]
  grep -q '# Piped' "${_NOTEBOOK_PATH}"/*
  [[ "${_files[0]}" =~ org$ ]]
}

@test "\`add --type ''\` with piped content exits with 1." {
  run "${_NOTES}" init
  run bash -c "echo '# Piped' | \"${_NOTES}\" add --type"

  [[ ${status} -eq 1 ]]

  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 0 ]]
}

# help ########################################################################

@test "\`help add\` exits with status 0." {
  run "${_NOTES}" help add
  [[ ${status} -eq 0 ]]
}

@test "\`help add\` returns usage information." {
  run "${_NOTES}" help add
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" =~  notes\ add ]]
}
