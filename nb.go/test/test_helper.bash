#!/usr/bin/env bash
###############################################################################
# nb.go/test/test_helper.bash
#
# Test helper for Bats: Bash Automated Testing System.
#
# https://github.com/bats-core/bats-core
# https://github.com/sstephenson/bats
###############################################################################

source "${BATS_TEST_DIRNAME}/../../test/test_helper.bash"

setup() {
  _setup "${BATS_TEST_DIRNAME}/../../test"

  # $_NBGO
  #
  # The location of the `nb.go` executable being tested.
  export _NBGO
  _NBGO="$(which nb.go)"
  export _NB="${_NBGO}"

  if [[ -z "${_NBGO:-}" ]] || [[ ! -e "${_NBGO}" ]]
  then
    printf "nb.go executable not found\\n." 1>&2
    return 1
  fi
}
