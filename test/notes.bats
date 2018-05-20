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

  [[ "${lines[6]}" == "Initializing..." ]]
  [[ "${lines[7]}" =~ Created ]]
  [[ "${lines[8]}" =~ Created ]]
  [[ "${lines[9]}" =~ Created ]]
  [[ "${lines[12]}" == "0 notes." ]]
  [[ "${lines[13]}" == "Add a note:" ]]
  [[ "${lines[14]}" == "  notes add" ]]
  [[ "${lines[15]}" == "Usage information:" ]]
  [[ "${lines[16]}" == "  notes help" ]]
}

# `notes` (empty repo) ########################################################

@test "\`notes\` with empty repo exits with status 1 and \`ls\` output." {
  run "${_NOTES}" init
  run "${_NOTES}"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${status}" -eq 1 ]]
}

@test "\`notes\` with an empty repo prints error." {
  run "${_NOTES}" init
  run "${_NOTES}"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${lines[1]}" =~ ---- ]]
  [[ "${lines[2]}" == "0 notes." ]]
  [[ "${lines[3]}" == "Add a note:" ]]
  [[ "${lines[4]}" == "  notes add" ]]
  [[ "${lines[5]}" == "Usage information:" ]]
  [[ "${lines[6]}" == "  notes help" ]]
}

# `notes` (non-empty repo) ####################################################

@test "\`notes\` with a non-empty repo exits with 0 and prints list." {
  {
    run "${_NOTES}" init
    "${_NOTES}" add "# one"
    sleep 1
    "${_NOTES}" add "# two"
    sleep 1
    "${_NOTES}" add "# three"
    _files=($(ls -t "${NOTES_DATA_DIR}/"))
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
