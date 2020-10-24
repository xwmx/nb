#!/usr/bin/env bats
# shellcheck disable=SC2089,SC2090

load test_helper

@test "\`help\` with no arguments exits with status 0." {
  run "${_NB}" help

  [[ "${status}" -eq 0 ]]
}

@test "\`help\` with no arguments prints default help." {
  run "${_NB}" help

  [[ "${output}" =~ nb\ help\ \<subcommand\>  ]]
  [[ "${output}" =~ nb\ edit                  ]]
}

@test "\`-h\` prints default help." {
  run "${_NB}" -h

  [[ "${output}" =~ nb\ help\ \<subcommand\>  ]]
  [[ "${output}" =~ nb\ edit                  ]]
}

@test "\`--help\` prints default help." {
  run "${_NB}" --help

  [[ "${output}" =~ nb\ help\ \<subcommand\>  ]]
  [[ "${output}" =~ nb\ edit                  ]]
}

@test "\`help help\` prints \`help\` subcommand usage." {
  run "${_NB}" help help

  [[ "${output}" =~ Shortcut\ Alias\:\ \`h\` ]]
}
