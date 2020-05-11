#!/usr/bin/env bats

load test_helper

@test "\`commands\` exits with status 0." {
  run "${_NB}" commands
  [ ${status} -eq 0 ]
}

@test "\`commands\` prints subcommands." {
  run "${_NB}" commands
  printf "\${lines[*]}: %s\\n" "${lines[*]}"
  printf "\${#lines[@]}: %s\\n" "${#lines[@]}"
  [[ "${lines[0]}" =~ ^a$ ]]
}
