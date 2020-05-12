###############################################################################
# test_helper.bash
#
# Test helper for Bats: Bash Automated Testing System.
#
# https://github.com/sstephenson/bats
###############################################################################

setup() {
  # `$_NB`
  #
  # The location of the `nb` script being tested.
  export _NB="${BATS_TEST_DIRNAME}/../nb"

  # `$_NB_PATH`
  #
  # Used by `bookmark` and `nb` for testing.
  export _NB_PATH="${_NB}"

  # `$_BOOKMARK`
  #
  # The location of the `bookmark` script being tested.
  export _BOOKMARK="${BATS_TEST_DIRNAME}/../bin/bookmark"

  # `$_NOTES`
  #
  # The location of the `notes` script being tested.
  export _NOTES="${BATS_TEST_DIRNAME}/../bin/notes"

  export _TMP_DIR
  _TMP_DIR="$(mktemp -d /tmp/nb_test.XXXXXX)" || exit 1

  export NB_DIR="${_TMP_DIR}/notebooks"
  export _NOTEBOOK_PATH="${NB_DIR}/home"
  export NBRC_PATH="${_TMP_DIR}/.notesrc"
  export NB_HIGHLIGHT_COLOR=3
  export NB_AUTO_SYNC=0

  export _GIT_REMOTE_PATH="${_TMP_DIR}/remote"
  export _GIT_REMOTE_URL="file://${_GIT_REMOTE_PATH}"

  export _BOOKMARK_URL="file://${BATS_TEST_DIRNAME}/fixtures/example.com.html"

  if [[ -z "${EDITOR:-}" ]] || [[ ! "${EDITOR:-}" =~ mock_editor ]]
  then
    export EDITOR="${BATS_TEST_DIRNAME}/fixtures/bin/mock_editor"
  fi

  # Use empty `nb` script in environment to avoid depending on `nb`
  # being available in `$PATH`.
  export PATH="${BATS_TEST_DIRNAME}/fixtures/bin:${PATH}"

  if [[ ! "${NB_DIR}"         =~ ^/tmp/nb_test ]] ||
     [[ ! "${_NOTEBOOK_PATH}" =~ ^/tmp/nb_test ]] ||
     [[ ! "${NBRC_PATH}"      =~ ^/tmp/nb_test ]]
  then
    exit 1
  fi
}

teardown() {
  if [[ -n "${_TMP_DIR:-}" ]] &&
     [[ -e "${_TMP_DIR}"   ]] &&
     [[ "${_TMP_DIR}" =~ ^/tmp/nb_test ]]
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

# _highlight()
#
# Usage:
#   _highlight <string> [--underline]
export _TPUT_HIGHLIGHT_COLOR
_TPUT_HIGHLIGHT_COLOR="$(tput setaf 3)"
export _TPUT_SGR0= && _TPUT_SGR0="$(tput sgr0)"
export _TPUT_SMUL= && _TPUT_SMUL="$(tput smul)"
_highlight() {
  local _input="${1:-}"
  if [[ -z "${_input}" ]]
  then
    _die printf "Usage: _highlight <string>"
  fi

  if [[ "${2:-}" == "--underline" ]]
  then
    printf \
      "${_TPUT_SGR0}${_TPUT_SMUL}${_TPUT_HIGHLIGHT_COLOR}%s${_TPUT_SGR0}\\n" \
      "${_input}"
  else
    printf \
      "${_TPUT_SGR0}${_TPUT_HIGHLIGHT_COLOR}%s${_TPUT_SGR0}\\n" \
      "${_input}"
  fi
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
  local _pwd="${PWD}"
  if [[ -n "${_GIT_REMOTE_PATH}" ]] &&
     [[ "${_GIT_REMOTE_PATH}" =~ ^/tmp/nb_test ]]
  then
    mkdir "${_GIT_REMOTE_PATH}" &&
      cd "${_GIT_REMOTE_PATH}"  &&
      git init                  &&
      touch '.index'            &&
      git add --all             &&
      git commit -a -m "Initial commit."

      cd "${_pwd}" || exit
  fi
}
