#!/usr/bin/env bats

load test_helper

@test "\`env\` exits with status 0." {
  _expected="\
EDITOR=${BATS_TEST_DIRNAME}/fixtures/bin/mock_editor
NOTES_AUTO_SYNC=1
NOTES_DIR=${_TMP_DIR}/.notes
NOTES_DATA_DIR=${_TMP_DIR}/.notes/home
NOTES_DEFAULT_EXTENSION=md
NOTES_ENCRYPTION_TOOL=openssl
NOTES_HIGHLIGHT_COLOR=$(tput colors)
NOTESRC_PATH=${_TMP_DIR}/.notesrc"

  run "${_NOTES}" env
  [ ${status} -eq 0 ]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${_expected}: '%s'\\n" "${_expected}"

  [[ "${_expected}" == "${output}" ]]
}
