#!/usr/bin/env bash
###############################################################################
# test_helper.bash
#
# Test helper for Bats: Bash Automated Testing System.
#
# https://github.com/bats-core/bats-core
# https://github.com/sstephenson/bats
###############################################################################

# bats_require_minimum_version
#
# https://github.com/bats-core/bats-core/blob/master/docs/source/writing-tests.md
if hash "bats_require_minimum_version" &>/dev/null
then
  bats_require_minimum_version 1.5.0
fi

# _setup()
#
# Usage:
#   _setup [<bats-base-path>]
#
# Description:
#   Set up the test environment.
_setup() {
  IFS=$'\n\t'

  # Allow clobber. More info: https://stackoverflow.com/a/6762399
  set +o noclobber

  # Allow globbing.
  set +o noglob

  #############################################################################

  # $NB_TEST_BASE_PATH
  #
  # The base directory for the test suite.
  export NB_TEST_BASE_PATH="${1:-"${BATS_TEST_DIRNAME}"}"

  # $_ME
  #
  # The name of the program.
  export _ME="nb"

  # $_NB
  #
  # The location of the `nb` script being tested.
  export _NB="${NB_TEST_BASE_PATH}/../nb"

  # $_TMP_DIR
  #
  # The temp directory for the test run.
  export _TMP_DIR=
  _TMP_DIR="$(mktemp -d /tmp/nb_test.XXXXXX)" || exit 1

  #############################################################################

  # $EDITOR
  #
  # Set to mock_editor when unassigned.
  if [[ -z "${EDITOR:-}" ]] || [[ ! "${EDITOR:-}" =~ mock_editor ]]
  then
    export EDITOR="${NB_TEST_BASE_PATH}/fixtures/bin/mock_editor"
  fi

  # $NBRC_PATH
  #
  # The location of the .nbrc configuration file.
  export NBRC_PATH="${_TMP_DIR}/.nbrc"

  # $NB_AUTO_SYNC
  #
  # Turn off auto-sync.
  export NB_AUTO_SYNC=0

  # $NB_COLOR_PRIMARY
  #
  # Set to a value compatible with CI terminals.
  export NB_COLOR_PRIMARY=3

  # $NB_DIR
  #
  # The location of the directory that contains the notebooks.
  export NB_DIR="${_TMP_DIR}/notebooks"

  # $NB_PINNED_PATTERN
  #
  # Pattern for tag-based pinning.
  export NB_PINNED_PATTERN="#pinned"

  # $NB_SERVER_PORT
  #
  # The port used for the `browse` server.
  export NB_SERVER_PORT=6789

  #############################################################################

  # $_BOOKMARK
  #
  # The location of the `bookmark` script being tested.
  export _BOOKMARK="${NB_TEST_BASE_PATH}/../bin/bookmark"

  # $_BOOKMARK_URL
  #
  # A URL for an HTML file.
  export _BOOKMARK_URL="file://${NB_TEST_BASE_PATH}/fixtures/example.com.html"

  # $_BOOKMARK_OG_URL
  #
  # A URL for an HTML file with open graph tags.
  export _BOOKMARK_OG_URL="file://${NB_TEST_BASE_PATH}/fixtures/example.com-og.html"

  # $_BOOKMARK_TITLES_URL
  #
  # A URL for an HTML file with multiple title tags with unicode characters.
  export _BOOKMARK_TITLES_URL="file://${NB_TEST_BASE_PATH}/fixtures/example.com-titles.html"

  # $_BOOKMARK_TITLES_NEWLINES_URL
  #
  # A URL for an HTML file with <title> tags separated from content by newlines.
  export _BOOKMARK_TITLES_NEWLINES_URL="file://${NB_TEST_BASE_PATH}/fixtures/example.com-titles-newlines.html"

  # $_ERROR_PREFIX
  #
  # The color string added to error messages by `_exit_1` and `_return_1`.
  export _ERROR_PREFIX=
  _ERROR_PREFIX="$(tput setaf 1)!$(tput sgr0)"

  # $_GIT_REMOTE_PATH
  #
  # Path to use for a git remote repository within the temp directory.
  export _GIT_REMOTE_PATH="${_TMP_DIR}/remote"

  # $_GIT_REMOTE_URL
  #
  # URL to use for a git remote repository within the temp directory.
  export _GIT_REMOTE_URL="file://${_GIT_REMOTE_PATH}"

  # $_NB_PATH
  #
  # Used by `bookmark` and `notes` for testing.
  export _NB_PATH="${_NB}"

  # $_NOTES
  #
  # The location of the `notes` script being tested.
  export _NOTES="${NB_TEST_BASE_PATH}/../bin/notes"

  #############################################################################
  # verify that NB_DIR and NBRC_PATH are in the temp directory

  if [[ ! "${NB_DIR}"         =~ ^/tmp/nb_test ]] ||
     [[ ! "${NBRC_PATH}"      =~ ^/tmp/nb_test ]]
  then
    exit 1
  fi
}

###############################################################################
# setup() and teardown()
#
# https://bats-core.readthedocs.io/en/stable/writing-tests.html
###############################################################################

setup() {
  _setup

  # Use empty `nb` script in environment to avoid depending on `nb`
  # being available in `$PATH`.
  export PATH="${NB_TEST_BASE_PATH}/fixtures/bin:${PATH}"
}

teardown() {
  if [[ -n  "${_TMP_DIR:?}"                   ]] &&
     [[ -e  "${_TMP_DIR:?}"                   ]] &&
     [[     "${_TMP_DIR:?}" =~ ^/tmp/nb_test  ]]
  then
    rm -rf  "${_TMP_DIR:?}"
  fi
}

###############################################################################
# Helpers
###############################################################################

# $_AMP
#
# Ampersand configurable as escaped &amp; or &.
export _AMP="&"

# $_BT
#
# Backtick with ANSI-C quoting for string building.
_BT=$'`'

# $_IMOGI
#
# A character representing an image.
export _IMOGI="🌄"

# $_NBSP
#
# Non-breaking space. See also: $_S
export _NBSP=" "

# $_NEWLINE
#
# Newline with ANSI-C quoting for string building.
export _NEWLINE=$'\n'

# $_S
#
# Non-breaking space. See also: $_NBSP
export _S=" "

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

  printf "expected:\\n%s\\n"  "${_expected}"
  printf "actual:\\n%s\\n"    "${_actual}"
}

# _contains()
#
# Usage:
#   _contains <query> <list-item>...
#
# Exit / Error Status:
#   0 (success, true)  If the item is included in the list.
#   1 (error,  false)  If not.
#
# Example:
#   _contains "${_query}" "${_list[@]}"
_contains() {
  local _query="${1:-}"

  shift

  if [[ -z "${_query}"  ]] ||
     [[ -z "${*:-}"     ]]
  then
    return 1
  fi

  local __element=
  for   __element in "${@}"
  do
    [[ "${__element}" == "${_query}" ]] && return 0
  done

  return 1
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

    if [[ -z "${_command[*]:-}"   ]] ||
       [[ -z "${_path}"           ]]
    then
      return 1
    fi

    if [[ -d "${_path}"           ]]
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

# color variables

export _TPUT_COLOR_PRIMARY=   && _TPUT_COLOR_PRIMARY="$(tput setaf 3)"
export _TPUT_SETAF_8=         && _TPUT_SETAF_8="$(tput setaf 8)"
export _TPUT_SGR0=            && _TPUT_SGR0="$(tput sgr0)"
export _TPUT_SMUL=            && _TPUT_SMUL="$(tput smul)"

# _color_muted()
#
# Usage:
#   _color_muted <string>
#
# Print the given string with the muted color.
_color_muted() {
  printf "%s%s%s%s"     \
    "${_TPUT_SGR0}"     \
    "${_TPUT_SETAF_8}"  \
    "${1:-}"            \
    "${_TPUT_SGR0}"
}

# _color_primary()
#
# Usage:
#   _color_primary <string> [--underline]
_color_primary() {
  local _input="${1:-}"

  if [[ -z "${_input:-}"          ]]
  then
    printf "Usage: _color_primary <string>" 1>&2
    exit 1
  fi

  if [[ "${2:-}" == "--underline" ]]
  then
    printf                                                                  \
      "${_TPUT_SGR0}${_TPUT_SMUL}${_TPUT_COLOR_PRIMARY}%s${_TPUT_SGR0}\\n"  \
      "${_input}"
  else
    printf                                                                  \
      "${_TPUT_SGR0}${_TPUT_COLOR_PRIMARY}%s${_TPUT_SGR0}\\n"               \
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
#   _setup_remote_repo [<branch-name>]
#
# Description:
#   Initialize and add initial commit to a git repository at
#   `$_GIT_REMOTE_URL`.
_setup_remote_repo() {
  local _branch_name="${1:-"master"}"
  local _pwd="${PWD}"

  if [[ -n "${_GIT_REMOTE_PATH}"                  ]] &&
     [[    "${_GIT_REMOTE_PATH}" =~ ^/tmp/nb_test ]]
  then
    mkdir "${_GIT_REMOTE_PATH}.setup"     &&
      cd "${_GIT_REMOTE_PATH}.setup"      &&
      git init                            &&
      git checkout -b "${_branch_name}"   &&
      touch '.index'                      &&
      git add --all                       &&
      git commit -a -m "Initial commit."  &&
      git clone --bare "${_GIT_REMOTE_PATH}.setup" "${_GIT_REMOTE_PATH}" &&
      cd "${_GIT_REMOTE_PATH}"            &&
      git remote rm "origin"

      cd "${_pwd}" || exit
  fi
}
