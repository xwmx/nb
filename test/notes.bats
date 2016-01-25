#!/usr/bin/env bats

load test_helper

@test "\`notes\` with no arguments exits with status 0." {
  run "$_NOTES"
  [ "$status" -eq 0 ]
}

@test "\`notes\` with no arguments prints default help." {
  run "$_NOTES"
  _expected="\
             _
 _ __   ___ | |_ ___  ___
| '_ \ / _ \| __/ _ \/ __|
| | | | (_) | ||  __/\__ \\
|_| |_|\___/ \__\___||___/"
  [[ "$(IFS=$'\n'; echo "${lines[*]:0:5}")" == "$_expected" ]]
}
