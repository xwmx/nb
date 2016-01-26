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

  export NOTES_DIR="${BATS_TEST_DIRNAME}/tmp/.notes"
  export NOTES_DATA_DIR="${NOTES_DIR}/data"
  export NOTESRC_PATH="${BATS_TEST_DIRNAME}/tmp/.notesrc"
}

teardown() {
  if [[ -n "${NOTES_DIR:-}" ]] &&
     [[ -e "${NOTES_DIR}"   ]] &&
     [[ "${NOTES_DIR}" =~ tmp/.notes$ ]]
  then
    rm -rf "${NOTES_DIR}"
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
