#!/usr/bin/env bats

load test_helper

# error handling ##############################################################

@test "'open' with no selector with exits with 1 and prints help." {
  {
    "${_NB}" init
  }

  run "${_NB}" open

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"    -eq  1         ]]

  [[    "${lines[0]}"   =~  Usage     ]]
  [[    "${lines[1]}"   =~  nb\ open  ]]
}
