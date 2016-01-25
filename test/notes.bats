#!/usr/bin/env bats

load test_helper

@test "when no arguments are passed print help" {
  run "$_NOTES"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = '             _'              ]
  [ "${lines[1]}" = ' _ __   ___ | |_ ___  ___'   ]
}
