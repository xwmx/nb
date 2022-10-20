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

  # $_NB_ZSH
  #
  # The location of the `nb.zsh` executable being tested.
  export _NB_ZSH
  _NB_ZSH="${BATS_TEST_DIRNAME}/../nb"
  export _NB="${_NB_ZSH}"
}
