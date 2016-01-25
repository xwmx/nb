#!/usr/bin/env bats

# `$_NOTES`
#
# The location of the `notes` script being tested.
export _NOTES="${BATS_TEST_DIRNAME}/../notes"

@test "when no arguments are passed print help" {
  run "$_NOTES"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = '             _'              ]
  [ "${lines[1]}" = ' _ __   ___ | |_ ___  ___'   ]
}
