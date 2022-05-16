#!/usr/bin/env bats

load test_helper

# help ########################################################################

@test "'help w' exits with status 0 and prints usage." {
  {
    "${_NB}" init
    "${_NB}" plugins install "${NB_TEST_BASE_PATH}/../plugins/weather.nb-plugin"
  }

  run "${_NB}" help w

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0               ]]
  [[ "${lines[0]}"  =~  Usage.*\:       ]]
  [[ "${lines[1]}"  =~  nb\ weather     ]]
}

@test "'help weather' exits with status 0 and prints usage." {
  {
    "${_NB}" init
    "${_NB}" plugins install "${NB_TEST_BASE_PATH}/../plugins/weather.nb-plugin"
  }

  run "${_NB}" help weather

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    -eq 0               ]]
  [[ "${lines[0]}"  =~  Usage.*\:       ]]
  [[ "${lines[1]}"  =~  nb\ weather     ]]
}
