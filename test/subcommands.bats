#!/usr/bin/env bats

load test_helper

@test "\`subcommands\` exits with 0 and prints subcommands." {
  {
    "${_NB}" init
  }

  run "${_NB}" subcommands

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0            ]]
  [[ "${output}" =~ "bookmark"  ]]
  [[ "${output}" =~ "status"    ]]
}
