#!/usr/bin/env bash
###############################################################################
# test_helper.bash
#
# Test helper for Bats: Bash Automated Testing System.
#
# https://github.com/sstephenson/bats
###############################################################################

setup() {
  # Set terminal width.
  #
  # The number of lines with wrapped output depends on terminal width.
  export _COLUMNS_ORIGINAL
  _COLUMNS_ORIGINAL="$(tput cols)"

  stty cols 81

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

  export NB_NOTEBOOK_PATH="${NB_DIR}/home"
# Assign legacy $_NOTEBOOK_PATH. TODO: global search and replace.
  export _NOTEBOOK_PATH="${NB_NOTEBOOK_PATH}"

  export NBRC_PATH="${_TMP_DIR}/.nbrc"
  export NB_COLOR_PRIMARY=3
  export NB_AUTO_SYNC=0

  export _GIT_REMOTE_PATH="${_TMP_DIR}/remote"
  export _GIT_REMOTE_URL="file://${_GIT_REMOTE_PATH}"

  export _BOOKMARK_URL="file://${BATS_TEST_DIRNAME}/fixtures/example.com.html"

  # `$_ERROR_PREFIX`
  #
  # The color string added to error messages by `_exit_1` and `_return_1`.
  export _ERROR_PREFIX=
  _ERROR_PREFIX="$(tput setaf 1)!$(tput sgr0)"

  if [[ -z "${EDITOR:-}" ]] || [[ ! "${EDITOR:-}" =~ mock_editor ]]
  then
    export EDITOR="${BATS_TEST_DIRNAME}/fixtures/bin/mock_editor"
  fi

  # Use empty `nb` script in environment to avoid depending on `nb`
  # being available in `$PATH`.
  export PATH="${BATS_TEST_DIRNAME}/fixtures/bin:${PATH}"

  # $_NEWLINE
  #
  # Assign newline with ANSI-C quoting for string building.
  export _NEWLINE=$'\n'

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

  stty cols "${_COLUMNS_ORIGINAL}"
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

# _get_hash()
#
# Usage:
#   _get_hash <path>
#
# Description:
#   Generate a hash for the file or directory at <path>.
_get_hash() {
  # Usage: _get_hash_with_command <path> <command>
  _get_hash_with_command() {
    local _command=
    IFS=' ' read -ra _command <<< "${2:-}"

    local _path="${1:-}"

    [[ -n "${_command[*]:-}" ]] && [[ -n "${_path}" ]] || return 1

    if [[ -d "${_path}" ]]
    then
      tar -P -cf - "${_path}"     \
        | "${_command[@]}"        \
        | awk '{ print $1 }'
    else
      "${_command[@]}" "${_path}" \
        | awk '{print $1}'
    fi
  }

  local _path="${1:-}"
  [[ -n "${_path:-}" ]] || return 1

  if hash "shasum" 2>/dev/null
  then
    _get_hash_with_command "${_path}" "shasum -a 256"
  elif hash "md5sum" 2>/dev/null
  then
    _get_hash_with_command "${_path}" "md5sum"
  elif hash "md5" 2>/dev/null
  then
    _get_hash_with_command "${_path}" "md5 -q"
  else
    printf "No hashing tool found.\\n"
    exit 1
  fi
}

# _color_primary()
#
# Usage:
#   _color_primary <string> [--underline]
export _TPUT_COLOR_PRIMARY
_TPUT_COLOR_PRIMARY="$(tput setaf 3)"
export _TPUT_SGR0= && _TPUT_SGR0="$(tput sgr0)"
export _TPUT_SMUL= && _TPUT_SMUL="$(tput smul)"
_color_primary() {
  local _input="${1:-}"
  if [[ -z "${_input}" ]]
  then
    _die printf "Usage: _color_primary <string>"
  fi

  if [[ "${2:-}" == "--underline" ]]
  then
    printf \
      "${_TPUT_SGR0}${_TPUT_SMUL}${_TPUT_COLOR_PRIMARY}%s${_TPUT_SGR0}\\n" \
      "${_input}"
  else
    printf \
      "${_TPUT_SGR0}${_TPUT_COLOR_PRIMARY}%s${_TPUT_SGR0}\\n" \
      "${_input}"
  fi
}

# _sed_i()
#
# `sed -i` takes an extension on macOS, but that extension can cause errors in
# GNU `sed`.
#
# https://stackoverflow.com/q/43171648
# https://stackoverflow.com/a/16746032
_sed_i() {
  if sed --help >/dev/null 2>&1
  then # GNU
    sed -i "${@}"
  else # BSD
    sed -i '' "${@}"
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
    mkdir "${_GIT_REMOTE_PATH}.setup"     &&
      cd "${_GIT_REMOTE_PATH}.setup"      &&
      git init                            &&
      touch '.index'                      &&
      git add --all                       &&
      git commit -a -m "Initial commit."  &&
      git clone --bare "${_GIT_REMOTE_PATH}.setup" "${_GIT_REMOTE_PATH}"

      cd "${_pwd}" || exit
  fi
}
