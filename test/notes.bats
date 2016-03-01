#!/usr/bin/env bats

load test_helper

# `notes` (pre-init) ##########################################################

@test "\`notes\` (pre-init) exits with status 1 and prints \`ls\` ouput." {
  {
    printf "\${NOTES_DIR}: %s\n" "${NOTES_DIR}"
    printf "\${NOTESRC_PATH}: %s\n" "${NOTESRC_PATH}"
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
  [[ "${status}" -eq 1 ]]

  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  _expected="\
# home:
0 notes.

Add a note:
  notes add
Usage information:
  notes help"
  _compare "${_expected}" "${output}"
  [[ "${_expected}" == "${output}" ]]
}

# `notes` (empty repo) ########################################################

@test "\`notes\` with empty repo exits with status 1 and \`ls\` output." {
  run "${_NOTES}"
  [[ "${status}" -eq 1 ]]
}

@test "\`notes\` with an empty repo prints error." {
  run "${_NOTES}"
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  _expected="\
# home:
0 notes.

Add a note:
  notes add
Usage information:
  notes help"
  _compare "${_expected}" "${output}"
  [[ "${_expected}" == "${output}" ]]
}

# `notes` (non-empty repo) ####################################################

@test "\`notes\` with a non-empty repo exits with 0 and prints list." {
  {
    "${_NOTES}" add "# one"
    sleep 1
    "${_NOTES}" add "# two"
    sleep 1
    "${_NOTES}" add "# three"
    _files=($(ls -t "${NOTES_DATA_DIR}/"))
  }

  run "${_NOTES}"
  printf "\${status}: %s\n" "${status}"
  printf "\${output}: '%s'\n" "${output}"
  _compare "${_files[*]}" "${lines[*]}"

  [[ "${status}" -eq 0 ]]
  [[ "${lines[1]}" =~ three ]]
  [[ "${lines[2]}" =~ two   ]]
  [[ "${lines[3]}" =~ one   ]]
}
