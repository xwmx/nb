#!/usr/bin/env bats

load test_helper

@test "\`commands\` exits with status 0." {
  run "${_NOTES}" commands
  [ ${status} -eq 0 ]
}

@test "\`commands\` prints subcommands." {
  run "${_NOTES}" commands
  printf "\${lines[*]}: %s\\n" "${lines[*]}"
  [[ "${lines[0]}" =~ add ]]
  [[ "${lines[35]}" =~ version ]]
}
