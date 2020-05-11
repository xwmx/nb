#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

load test_helper

# `nb` (pre-init) ##########################################################

@test "\`nb\` (pre-init) exits with status 0 and prints \`ls\` ouput." {
  {
    printf "\${NB_DIR}: %s\\n" "${NB_DIR}"
    printf "\${NBRC_PATH}: %s\\n" "${NBRC_PATH}"
    if [[ "${NB_DIR}" =~ /tmp/nb_test ]] &&
       [[ -e "${NB_DIR}" ]]
    then
      rm -rf "${NB_DIR}"
      [[ ! -e "${NB_DIR}" ]]
    fi
    if [[ "${NBRC_PATH}" =~ /tmp/nb_test ]] &&
       [[ -e "${NBRC_PATH}" ]]
    then
      rm -rf "${NBRC_PATH}"
      [[ ! -e "${NBRC_PATH}" ]]
    fi
  }

  run "${_NB}"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ "${status}" -eq 0 ]]

  [[ "${lines[8]}" == "Initializing..." ]]
  [[ "${lines[9]}" =~ Created ]]
  [[ "${lines[10]}" =~ Created ]]
  [[ "${lines[11]}" =~ Created ]]
  [[ "${lines[14]}" == "0 notes." ]]
  [[ "${lines[15]}" == "Add a note:" ]]
  [[ "${lines[16]}" == "  $(_highlight 'nb add')" ]]
  [[ "${lines[17]}" == "Help information:" ]]
  [[ "${lines[18]}" == "  $(_highlight 'nb help')" ]]
}

# `nb` (empty repo) ########################################################

@test "\`nb\` with empty repo exits with status 0 and \`ls\` output." {
  run "${_NB}" init
  run "${_NB}"

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" -eq 0 ]]
  [[ "${lines[1]}" =~ ---- ]]
  [[ "${lines[2]}" == "0 notes." ]]
  [[ "${lines[3]}" == "Add a note:" ]]
  [[ "${lines[4]}" == "  $(_highlight 'nb add')" ]]
  [[ "${lines[5]}" == "Help information:" ]]
  [[ "${lines[6]}" == "  $(_highlight 'nb help')" ]]
}

# `nb` (non-empty repo) ####################################################

@test "\`nb\` with a non-empty repo exits with 0 and prints list." {
  {
    run "${_NB}" init
    "${_NB}" add "first.md" --title "one"
    "${_NB}" add "second.md" --title "two"
    "${_NB}" add "third.md" --title "three"
    _files=($(ls -t "${_NOTEBOOK_PATH}/"))
  }

  run "${_NB}"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${_files[*]}" "${lines[*]}"

  [[ "${status}" -eq 0 ]]
  [[ "${lines[2]}" =~ three ]]
  [[ "${lines[3]}" =~ two   ]]
  [[ "${lines[4]}" =~ one   ]]
}

# `nb` NB_DIR ###########################################################

@test "\`nb\` with invalid NB_DIR exits with 1." {
  {
    run "${_NB}" init
  }

  NB_DIR='/' run "${_NB}"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _compare "${_files[*]}" "${lines[*]}"

  [[ "${status}" -eq 1 ]]
  [[ "${lines[0]}" =~ NB_DIR\ is\ not\ valid ]]
}
