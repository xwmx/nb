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

  export _TMP_DIR
  _TMP_DIR="$(mktemp -d /tmp/notes_test.XXXXXX)" || exit 1

  export NOTES_DIR="${_TMP_DIR}/.notes"
  export _NOTEBOOK_PATH="${NOTES_DIR}/home"
  export NOTESRC_PATH="${_TMP_DIR}/.notesrc"
  export NOTES_HIGHLIGHT_COLOR=3

  export _GIT_REMOTE_PATH="${_TMP_DIR}/remote"
  export _GIT_REMOTE_URL="file://${_GIT_REMOTE_PATH}"

  if [[ -z "${EDITOR:-}" ]] || [[ ! "${EDITOR:-}" =~ mock_editor ]]
  then
    export EDITOR="${BATS_TEST_DIRNAME}/fixtures/bin/mock_editor"
  fi

  # Use empty `notes` script in environment to avoid depending on `notes`
  # being available in `$PATH`.
  export PATH="${BATS_TEST_DIRNAME}/fixtures/bin:${PATH}"

  if [[ ! "${NOTES_DIR}"      =~ ^/tmp/notes_test ]] ||
     [[ ! "${_NOTEBOOK_PATH}" =~ ^/tmp/notes_test ]] ||
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
    rm -rf "${_TMP_DIR}"
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
  printf "expected:\\n%s\\n" "${_expected}"
  printf "actual:\\n%s\\n" "${_actual}"
}

# _setup_remote_repo()
#
# Usage:
#   _setup_remote_repo
#
# Description:
#   Initialize and add initial commit to a git repository at
#   `$_GIT_REMOTE_URL`.
_setup_remote_repo() {
  if [[ -n "${_GIT_REMOTE_PATH}" ]] &&
     [[ "${_GIT_REMOTE_PATH}" =~ ^/tmp/notes_test ]]
  then
    mkdir "${_GIT_REMOTE_PATH}" &&
      cd "${_GIT_REMOTE_PATH}"  &&
      git init                  &&
      touch '.keep'             &&
      git add --all             &&
      git commit -a -m "Initial commit."
  fi
}
