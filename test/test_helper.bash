###############################################################################
# test_helper.bash
#
# Test helper for Bats: Bash Automated Testing System.
#
# https://github.com/sstephenson/bats
###############################################################################

setup() {
  # `$_NOTES`
  #
  # The location of the `notes` script being tested.
  export _NOTES="${BATS_TEST_DIRNAME}/../notes"

  export _TMP_DIR="$(mktemp -d /tmp/notes_test.XXXXXX)" || exit 1

  export NOTES_DIR="${_TMP_DIR}/.notes"
  export NOTES_DATA_DIR="${NOTES_DIR}/data"
  export NOTESRC_PATH="${_TMP_DIR}/.notesrc"

  export _GIT_REMOTE_URL="file://${BATS_TEST_DIRNAME}/../"

  if [[ ! "${NOTES_DIR}"      =~ ^/tmp/notes_test ]] ||
     [[ ! "${NOTES_DATA_DIR}" =~ ^/tmp/notes_test ]] ||
     [[ ! "${NOTESRC_PATH}"   =~ ^/tmp/notes_test ]]
  then
    exit 1
  fi
}

teardown() {
  if [[ -n "${_TMP_DIR:-}" ]] &&
     [[ -e "${_TMP_DIR}"   ]] &&
     [[ "${_TMP_DIR}" =~ ^/tmp/notes_test ]]
  then
    rm -rf "${_TMP_DIR:-/tmp/notes_test._TMP_DIR}"
  fi
}

###############################################################################
# Helpers
###############################################################################

# _compare()
#
# Usage:
#   _compare <expected> <actual>
#
# Description:
#   Compare the content of a variable against an expected value. When used
#   within a `@test` block the output is only displayed when the test fails.
_compare() {
  local _expected="${1:-}"
  local _actual="${2:-}"
  printf "expected:\n%s\n" "${_expected}"
  printf "actual:\n%s\n" "${_actual}"
}
