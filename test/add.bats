#!/usr/bin/env bats

load test_helper

# no argument #################################################################

@test "\`add\` with no arguments creates new note file created with $EDITOR." {
  run "${_NOTES}" init
  run "${_NOTES}" add
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates a new note file with $EDITOR
  _files=($(ls "${NOTES_DATA_DIR}/"))
  [[ "${#_files[@]}" -eq 1 ]]
  [[ $(grep '# mock_editor' "${NOTES_DATA_DIR}"/*) ]]

  # Creates git commit
  cd "${NOTES_DATA_DIR}" || return 1
  printf "\$(git log): '%s'\n" "$(git log)"
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Add') ]]

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
  _files=($(ls "${NOTES_DATA_DIR}/"))
  [[ "${#_files[@]}" -eq 1 ]]
  [[ $(grep '# Content' "${NOTES_DATA_DIR}"/*) ]]

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
  [[ "${output}" =~ Added\ home:[A-Za-z0-9]+.md ]]
}

# --content option ############################################################


@test "\`add\` with --content option exits with 0, creates new note, creates commit." {
  run "${_NOTES}" init
  run "${_NOTES}" add --content "# Content"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]

  _files=($(ls "${NOTES_DATA_DIR}/"))
  [[ "${#_files[@]}" -eq 1 ]]
  [[ $(grep '# Content' "${NOTES_DATA_DIR}"/*) ]]

  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Add') ]]
}

@test "\`add\` with empty --content option exits with 1" {
  run "${_NOTES}" init
  run "${_NOTES}" add --content
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]

  _files=($(ls "${NOTES_DATA_DIR}/"))
  [[ "${#_files[@]}" -eq 0 ]]
}

# --filename option ###########################################################


@test "\`add\` with --filename option exits with 0, creates new note, creates commit." {
  run "${_NOTES}" init
  run "${_NOTES}" add --filename example.md
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]

  _files=($(ls "${NOTES_DATA_DIR}/"))
  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"
  [[ "${#_files[@]}" -eq 1 ]]

  cd "${NOTES_DATA_DIR}" || return 1

  [[ -n "$(ls example.md)" ]]
  [[ $(grep '# mock_editor' "${NOTES_DATA_DIR}"/*) ]]

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Add') ]]
}

@test "\`add\` with empty --filename option exits with 1" {
  run "${_NOTES}" init
  run "${_NOTES}" add --filename
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]

  cd "${NOTES_DATA_DIR}" || return 1
  ls "${NOTES_DATA_DIR}/"
  _files=($(ls "${NOTES_DATA_DIR}/"))
  [[ "${#_files[@]}" -eq 0 ]]
}

# --title option ##############################################################


@test "\`add\` with --title option exits with 0, creates new note, creates commit." {
  run "${_NOTES}" init
  run "${_NOTES}" add --title "Example Title"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]

  _files=($(ls "${NOTES_DATA_DIR}/"))
  printf "\${_files[*]}: '%s'\\n" "${_files[*]:-}"
  [[ "${#_files[@]}" -eq 1 ]]

  cd "${NOTES_DATA_DIR}" || return 1

  [[ -n "$(ls Example_Title.md)" ]]
  [[ $(grep '# mock_editor' "${NOTES_DATA_DIR}"/*) ]]

  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Add') ]]
}

@test "\`add\` with empty --title option exits with 1" {
  run "${_NOTES}" init
  run "${_NOTES}" add --title
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 1 ]]

  cd "${NOTES_DATA_DIR}" || return 1
  ls "${NOTES_DATA_DIR}/"
  _files=($(ls "${NOTES_DATA_DIR}/"))
  [[ "${#_files[@]}" -eq 0 ]]
}

# --type option ###############################################################

@test "\`add --type org\` with content argument creates a new .org note file." {
  run "${_NOTES}" init
  run "${_NOTES}" add  "* Content" --type org

  [[ ${status} -eq 0 ]]

  _files=($(ls "${NOTES_DATA_DIR}/"))
  [[ "${#_files[@]}" -eq 1 ]]
  [[ $(grep '* Content' "${NOTES_DATA_DIR}"/*) ]]
  [[ "${_files[0]}" =~ org$ ]]
}

@test "\`add --type ''\` without argument exits with 1." {
  run "${_NOTES}" init
  run "${_NOTES}" add  "* Content" --type

  [[ ${status} -eq 1 ]]

  _files=($(ls "${NOTES_DATA_DIR}/"))
  [[ "${#_files[@]}" -eq 0 ]]
}

# --encrypt option ############################################################

@test "\`add --encrypt\` with content argument creates a new .enc note file." {
  run "${_NOTES}" init
  run "${_NOTES}" add  "* Content" --encrypt --password=example

  [[ ${status} -eq 0 ]]

  _files=($(ls "${NOTES_DATA_DIR}/"))
  [[ "${#_files[@]}" -eq 1 ]]
  [[ "${_files[0]}" =~ enc$ ]]
  [[ "$(file "${NOTES_DATA_DIR}/${_files[0]}" | cut -d: -f2)" =~ encrypted|openssl ]]

  # Deletes temp files.
  [[ ! "$(ls /tmp/notes*)" ]]
}

# --password option ###########################################################

@test "\`add --password\` without argument exits with 1." {
  run "${_NOTES}" init
  run "${_NOTES}" add  "* Content" --encrypt --password

  [[ ${status} -eq 1 ]]

  _files=($(ls "${NOTES_DATA_DIR}/"))
  [[ "${#_files[@]}" -eq 0 ]]
}

# piped #######################################################################

@test "\`add\` with piped content creates new note without errors." {
  run "${_NOTES}" init
  run bash -c 'echo "# Piped" | "${_NOTES}" add'
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note file
  _files=($(ls "${NOTES_DATA_DIR}/"))
  [[ "${#_files[@]}" -eq 1 ]]
  [[ $(grep '# Piped' "${NOTES_DATA_DIR}"/*) ]]

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
  [[ "${output}" =~ Added\ home:[A-Za-z0-9]+.md ]]
}

@test "\`add --type org\` with piped content creates a new .org note file." {
  run "${_NOTES}" init
  run bash -c 'echo "# Piped" | "${_NOTES}" add --type org'

  [[ ${status} -eq 0 ]]

  _files=($(ls "${NOTES_DATA_DIR}/"))
  [[ "${#_files[@]}" -eq 1 ]]
  [[ $(grep '# Piped' "${NOTES_DATA_DIR}"/*) ]]
  [[ "${_files[0]}" =~ org$ ]]
}

@test "\`add --type ''\` with piped content exits with 1." {
  run "${_NOTES}" init
  run bash -c 'echo "# Piped" | "${_NOTES}" add --type'

  [[ ${status} -eq 1 ]]

  _files=($(ls "${NOTES_DATA_DIR}/"))
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
  [[ "${lines[1]}" == "  notes add [<filename> | <content>] [-c | --content <content>]" ]]
}
