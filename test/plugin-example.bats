#!/usr/bin/env bats

load test_helper

# `ebook new <name>` ##########################################################

@test "\`nb example\` prints output." {
  {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/example.nb-plugin"

    [[ "${status}" == 0 ]]
  }

  run "${_NB}" example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}" == 0               ]]
  [[ "${output}" == "Hello, World!" ]]
}

# help ########################################################################

@test "\`help example\` exits with status 0 and prints usage." {
  {
    run "${_NB}" init
    run "${_NB}" plugins install "${BATS_TEST_DIRNAME}/../plugins/example.nb-plugin"

    [[ "${status}" == 0 ]]
  }

  run "${_NB}" help example

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0                ]]
  [[ "${lines[0]}" =~ Usage\:       ]]
  [[ "${lines[1]}" =~ nb\ example   ]]
}

