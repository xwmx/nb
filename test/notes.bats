#!/usr/bin/env bats

load test_helper

# `notes` (pre-init) ##########################################################

@test "\`notes\` (pre-init) exits with status 0 and prints \`ls\` ouput." {
  {
    printf "\${NOTES_DIR}: %s\\n" "${NOTES_DIR}"
    printf "\${NOTESRC_PATH}: %s\\n" "${NOTESRC_PATH}"
    if [[ "${NOTES_DIR}" =~ /tmp/notes_test ]] &&
       [[ -e "${NOTES_DIR}" ]]
    then
      rm -rf "${NOTES_DIR}"
      [[ ! -e "${NOTES_DIR}" ]]
    fi
    if [[ "${NOTESRC_PATH}" =~ /tmp/notes_test ]] &&
       [[ -e "${NOTESRC_PATH}" ]]
    then
      rm -rf "${NOTESRC_PATH}"
      [[ ! -e "${NOTESRC_PATH}" ]]
    fi
  }

  run "${_NOTES}"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${status}" -eq 0 ]]

  [[ "${lines[8]}" == "Initializing..." ]]
  [[ "${lines[9]}" =~ Created ]]
  [[ "${lines[10]}" =~ Created ]]
  [[ "${lines[11]}" =~ Created ]]
  [[ "${lines[14]}" == "0 notes." ]]
  [[ "${lines[15]}" == "Add a note:" ]]
  [[ "${lines[16]}" == "  $(_highlight 'notes add')" ]]
  [[ "${lines[17]}" == "Help information:" ]]
  [[ "${lines[18]}" == "  $(_highlight 'notes help')" ]]
}

# `notes` (empty repo) ########################################################

@test "\`notes\` with empty repo exits with status 0 and \`ls\` output." {
  run "${_NOTES}" init
  run "${_NOTES}"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]
  [[ "${lines[1]}" =~ ---- ]]
  [[ "${lines[2]}" == "0 notes." ]]
  [[ "${lines[3]}" == "Add a note:" ]]
  [[ "${lines[4]}" == "  $(_highlight 'notes add')" ]]
  [[ "${lines[5]}" == "Help information:" ]]
  [[ "${lines[6]}" == "  $(_highlight 'notes help')" ]]
}

# `notes` (non-empty repo) ####################################################

@test "\`notes\` with a non-empty repo exits with 0 and prints list." {
  {
    run "${_NOTES}" init
    "${_NOTES}" add "first.md" --title "one"
    "${_NOTES}" add "second.md" --title "two"
    "${_NOTES}" add "third.md" --title "three"
    _files=($(ls -t "${_NOTEBOOK_PATH}/"))
  }

  run "${_NOTES}"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${_files[*]}" "${lines[*]}"

  [[ "${status}" -eq 0 ]]
  [[ "${lines[2]}" =~ three ]]
  [[ "${lines[3]}" =~ two   ]]
  [[ "${lines[4]}" =~ one   ]]
}
