#!/usr/bin/env bats

load test_helper

# `example` ###################################################################

@test "'nb example' prints output." {
  {
    "${_NB}" init
    "${_NB}" plugins install "${NB_TEST_BASE_PATH}/../plugins/example.nb-plugin"
  }

  run "${_NB}" example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0               ]]
  [[ "${output}" == "Hello, World!" ]]
}

# help ########################################################################

@test "'help example' exits with status 0 and prints usage." {
  {
    "${_NB}" init
    "${_NB}" plugins install "${NB_TEST_BASE_PATH}/../plugins/example.nb-plugin"
  }

  run "${_NB}" help example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                ]]
  [[ "${lines[0]}" =~ Usage.*\:     ]]
  [[ "${lines[1]}" =~ nb\ example   ]]
}

