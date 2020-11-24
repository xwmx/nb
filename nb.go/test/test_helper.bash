#!/usr/bin/env bash
###############################################################################
# nb.go/test/test_helper.bash
#
# Test helper for Bats: Bash Automated Testing System.
#
# https://github.com/sstephenson/bats
###############################################################################

setup() {
  # $_NB
  #
  # The location of the `nb` script being tested.
  export _NB="${BATS_TEST_DIRNAME}/../../nb"

  # $_NBGO
  #
  # The location of the `nb.go` executable being tested.
  export _NBGO
  _NBGO="$(which nb.go)"

  if [[ -z "${_NBGO:-}" ]] || [[ ! -e "${_NBGO}" ]]
  then
    printf "nb.go executable not found\\n." 1>&2
    return 1
  fi

  # $_TMP_DIR
  #
  # Temp directory path.
  export _TMP_DIR
  _TMP_DIR="$(mktemp -d /tmp/nb_test.XXXXXX)" || exit 1

  # $NB_DIR
  export NB_DIR="${_TMP_DIR}/nbdir"
}
