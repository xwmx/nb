#!/usr/bin/env bats

load test_helper

# no argument #################################################################

@test "\`add\` with no arguments exits with status 0." {
  run "${_NOTES}" init
  run "${_NOTES}" add
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ${status} -eq 0 ]]
}

@test "\`add\` with no arguments creates a new note file using \`\$EDITOR\`." {
  run "${_NOTES}" init
  run "${_NOTES}" add
  _files=($(ls "${NOTES_DATA_DIR}/"))
  [[ "${#_files[@]}" -eq 1 ]]
  [[ $(grep '# mock_editor' "${NOTES_DATA_DIR}"/*) ]]
}

@test "\`add\` with no arguments creates git commit." {
  run "${_NOTES}" init
  run "${_NOTES}" add
  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Add') ]]
}

# argument ####################################################################

@test "\`add\` with argument exits with status 0." {
  run "${_NOTES}" init
  run "${_NOTES}" add "# Content"
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ${status} -eq 0 ]]
}

@test "\`add\` with argument creates a new note file." {
  run "${_NOTES}" init
  run "${_NOTES}" add  "# Content"
  _files=($(ls "${NOTES_DATA_DIR}/"))
  [[ "${#_files[@]}" -eq 1 ]]
  [[ $(grep '# Content' "${NOTES_DATA_DIR}"/*) ]]
}

@test "\`add\` with argument creates git commit." {
  run "${_NOTES}" init
  run "${_NOTES}" add "# Content"
  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Add') ]]
}

@test "\`add\` with argument prints output." {
  run "${_NOTES}" init
  run "${_NOTES}" add  "# Content"
  _files=($(ls "${NOTES_DATA_DIR}/"))
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ${output} =~ Added ]]
}

@test "\`add --type org\` with argument creates a new .org note file." {
  run "${_NOTES}" init
  run "${_NOTES}" add  "* Content" --type org

  [[ ${status} -eq 0 ]]

  _files=($(ls "${NOTES_DATA_DIR}/"))
  [[ "${#_files[@]}" -eq 1 ]]
  [[ $(grep '* Content' "${NOTES_DATA_DIR}"/*) ]]
  [[ "${_files[0]}" =~ org$ ]]
}

@test "\`add --type ''\` with argument exits with 1." {
  run "${_NOTES}" init
  run "${_NOTES}" add  "* Content" --type

  [[ ${status} -eq 1 ]]

  _files=($(ls "${NOTES_DATA_DIR}/"))
  [[ "${#_files[@]}" -eq 0 ]]
}

# piped #######################################################################

@test "\`add\` with piped content exits with status 0." {
  run "${_NOTES}" init
  run bash -c 'echo "# Piped" | "${_NOTES}" add'
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ${status} -eq 0 ]]
}

@test "\`add\` with piped content creates a new note file." {
  run "${_NOTES}" init
  run bash -c 'echo "# Piped" | "${_NOTES}" add'
  _files=($(ls "${NOTES_DATA_DIR}/"))
  [[ "${#_files[@]}" -eq 1 ]]
  [[ $(grep '# Piped' "${NOTES_DATA_DIR}"/*) ]]
}

@test "\`add\` with piped content creates git commit." {
  run "${_NOTES}" init
  run bash -c 'echo "# Piped" | "${_NOTES}" add'
  cd "${NOTES_DATA_DIR}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Add') ]]
}

@test "\`add\` with piped content creates git commit." {
  run "${_NOTES}" init
  run bash -c 'echo "# Piped" | "${_NOTES}" add'
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ ${output} =~ Added ]]
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
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" == "  notes add [<note>] [--type <type>]" ]]
}
